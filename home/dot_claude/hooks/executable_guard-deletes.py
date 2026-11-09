#!/usr/bin/env python3
"""PreToolUse guard for destructive deletes in Bash commands.

Covers `rm -r`, `find -delete` / `-exec rm`, `git clean -f`, the same inside `bash -c`,
`eval` and `trap` strings, and the commands a `just` recipe would run (via `just --dry-run`).

Allowed without a prompt: anything strictly inside a temp folder, and inside a git repo either
an ignored folder (build output) or a path whose contents are all committed and unchanged.
Refused: root, top-level folders, home and its parents, a temp root, the repo or folder you
are in and its parents. Everything else asks.
"""
import json
import os
import re
import shlex
import subprocess
import sys

ALLOW, ASK, DENY = 0, 1, 2
HOME = os.path.realpath(os.path.expanduser("~"))
TEMP_ROOTS = {
    os.path.realpath(p)
    for p in ("/tmp", "/private/tmp", "/var/folders", "/private/var/folders", os.environ.get("TMPDIR", ""))
    if p
}
DANGER_RE = re.compile(r"\brm\b|-delete\b|\bgit\b.*\bclean\b|\bjust\b")
SEPARATORS = {";", "&&", "||", "|", "&", "(", ")", "\n", "|&", ";;"}
WRAPPERS = {"sudo", "command", "env", "nohup", "time", "exec", "nice", "builtin"}
# Commands whose string arguments are themselves shell code.
SCRIPT_RUNNERS = {"bash", "sh", "zsh", "fish", "dash", "eval", "trap", "watch"}
JUST_INFO_FLAGS = {"-n", "--dry-run", "-l", "--list", "-s", "--show", "--summary", "--evaluate",
                   "--dump", "-h", "--help", "-V", "--version", "--choose", "--variables", "--fmt"}


class Verdict:
    def __init__(self):
        self.level = ALLOW
        self.reasons = []

    def add(self, level, reason):
        if level > ALLOW:
            self.reasons.append(reason)
        self.level = max(self.level, level)


def run(args, cwd=None, timeout=5):
    try:
        out = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return out.returncode, out.stdout + out.stderr
    except (OSError, subprocess.TimeoutExpired):
        return 1, ""


def inside(path, root):
    return path != root and path.startswith(root.rstrip("/") + "/")


def at_or_above(path, other):
    """True when path is other itself or one of its parents."""
    return path == other or inside(other, path)


def expand(token):
    token = re.sub(r"^~(?=/|$)", HOME, token)
    token = re.sub(r"\$\{?HOME\}?", HOME, token)
    tmp = os.environ.get("TMPDIR")
    if tmp:
        token = re.sub(r"\$\{?TMPDIR\}?", tmp.rstrip("/"), token)
    return token


def resolve(token, cwd):
    """Absolute real path for a target, or None when it can't be known statically."""
    token = expand(token)
    if "$" in token or "`" in token:
        return None
    if not os.path.isabs(token):
        if cwd is None:
            return None
        token = os.path.join(cwd, token)
    return os.path.realpath(token)


def existing_ancestor(path):
    while path and not os.path.exists(path):
        path = os.path.dirname(path)
    return path or "/"


def protected(path, cwd):
    """Reason a path must never be deleted, or None."""
    if path == "/" or path.count("/") == 1:
        return f"{path} is a top-level folder"
    if at_or_above(path, HOME):
        return f"{path} is your home folder or above it"
    if any(at_or_above(path, root) for root in TEMP_ROOTS):
        return f"{path} is a temp root"
    if cwd and at_or_above(path, cwd) and not any(inside(cwd, root) for root in TEMP_ROOTS):
        return f"{path} is the folder this command runs in, or a parent of it"
    return None


def classify_path(target, cwd, verdict, what="rm -r"):
    if target in ("*", "/*", "~/*", ".", "./", "..", "../"):
        verdict.add(DENY, f"{what} {target}")
        return
    glob = re.search(r"[*?\[]", target)
    if glob:
        # Judge a glob by the folder it expands in.
        base = target[:glob.start()].rsplit("/", 1)[0] if "/" in target[:glob.start()] else "."
        path = resolve(base, cwd)
        if path is None:
            verdict.add(ASK, f"{what} {target}: can't tell where the glob expands")
            return
        reason = protected(path, cwd)
        if reason or path == cwd:
            verdict.add(DENY if reason and path != cwd else ASK, f"{what} {target}: deletes the contents of {path}")
            return
        target = base
    path = resolve(target, cwd)
    if path is None:
        verdict.add(ASK, f"{what} {target}: path depends on a variable or an unknown folder")
        return
    reason = protected(path, cwd)
    if reason:
        verdict.add(DENY, f"{what} {target}: {reason}")
        return
    if any(inside(path, root) for root in TEMP_ROOTS):
        return
    code, top = run(["git", "-C", existing_ancestor(os.path.dirname(path)), "rev-parse", "--show-toplevel"])
    top = os.path.realpath(top.strip()) if code == 0 else None
    if top and inside(path, top):
        if inside(path, os.path.join(top, ".git")) or path == os.path.join(top, ".git"):
            verdict.add(ASK, f"{what} {target}: inside .git")
            return
        if not os.path.lexists(path):
            return
        if os.path.isdir(path) and run(["git", "-C", top, "check-ignore", "-q", path])[0] == 0:
            return  # ignored folder, e.g. build output
        _, status = run(["git", "-C", top, "status", "--porcelain", "--ignored", "--", path])
        _, tracked = run(["git", "-C", top, "ls-files", "--", path])
        if not status.strip() and tracked.strip():
            return  # everything in it is committed, so git can restore it
        verdict.add(ASK, f"{what} {target}: has uncommitted, untracked or ignored files")
        return
    if path == top:
        verdict.add(DENY, f"{what} {target}: the whole repository")
        return
    verdict.add(ASK, f"{what} {target}: outside a repo and outside temp folders")


def check_rm(args, cwd, verdict):
    recursive, targets, flags_done = False, [], False
    for arg in args:
        if not flags_done and arg == "--":
            flags_done = True
        elif not flags_done and arg.startswith("--"):
            recursive |= arg == "--recursive"
        elif not flags_done and arg.startswith("-") and len(arg) > 1:
            recursive |= "r" in arg or "R" in arg
        else:
            targets.append(arg)
    if recursive:
        for target in targets:
            classify_path(target, cwd, verdict)


def check_find(args, cwd, verdict):
    deletes = "-delete" in args or any(
        a in ("-exec", "-execdir", "-ok", "-okdir") and i + 1 < len(args) and os.path.basename(args[i + 1]) == "rm"
        for i, a in enumerate(args))
    if not deletes:
        return
    starts = []
    for arg in args:
        if arg in ("-H", "-L", "-P"):
            continue
        if arg.startswith("-") or arg in ("(", "!"):
            break
        starts.append(arg)
    for start in starts or ["."]:
        path = resolve(start, cwd)
        if path and any(inside(path, root) for root in TEMP_ROOTS):
            continue
        if path and (path == "/" or at_or_above(path, HOME)):
            verdict.add(DENY, f"find {start} -delete: {path} is home, root or above")
        else:
            verdict.add(ASK, f"find {start} with -delete or -exec rm")


def check_git(args, verdict):
    rest = [a for a in args if not a.startswith("-")]
    if rest[:1] != ["clean"]:
        return
    flags = "".join(a for a in args if a.startswith("-") and not a.startswith("--"))
    if ("f" in flags or "--force" in args) and "n" not in flags and "--dry-run" not in args:
        verdict.add(ASK, "git clean -f deletes untracked files")


def find_justfile_dir(cwd):
    path = cwd
    while path and path != "/":
        if any(os.path.exists(os.path.join(path, n)) for n in ("justfile", "Justfile", ".justfile")):
            return path
        path = os.path.dirname(path)
    return None


def check_just(args, cwd, verdict, depth):
    if cwd is None or depth > 2 or any(a.split("=")[0] in JUST_INFO_FLAGS for a in args):
        return
    workdir = find_justfile_dir(cwd)
    if not workdir:
        return
    code, output = run(["just", "--dry-run", *args], cwd=cwd, timeout=10)
    if code != 0:
        return
    inner = Verdict()
    analyze(output, workdir, inner, depth + 1)
    for reason in inner.reasons:
        verdict.reasons.append(f"just {' '.join(args)} runs {reason}")
    verdict.level = max(verdict.level, inner.level)


def split_commands(command):
    lexer = shlex.shlex(command.replace("\\\n", " "), posix=True, punctuation_chars=";&|()\n")
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    lexer.commenters = ""
    current = []
    for token in lexer:
        if token in SEPARATORS or set(token) <= set(";&|()\n"):
            if current:
                yield current
            current = []
        else:
            current.append(token)
    if current:
        yield current


def analyze(command, cwd, verdict, depth=0):
    if not DANGER_RE.search(command) and not re.search(r"\bcd\b", command):
        return
    try:
        commands = list(split_commands(command))
    except ValueError:
        if DANGER_RE.search(command) and re.search(r"\brm\b.*\s-\w*[rR]|-delete|clean\s.*-\w*f", command):
            verdict.add(ASK, "couldn't parse a command that looks like a recursive delete")
        return
    for words in commands:
        while words and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", words[0]):
            words = words[1:]
        while words and os.path.basename(words[0]) in WRAPPERS:
            words = words[1:]
            while words and words[0].startswith("-"):
                words = words[1:]
        if not words:
            continue
        name, args = os.path.basename(words[0]), words[1:]
        if name in SCRIPT_RUNNERS:
            for arg in args:
                if DANGER_RE.search(arg):
                    analyze(arg, cwd, verdict, depth + 1)
        if name == "cd":
            target = args[0] if args else HOME
            cwd = resolve(target, cwd) if target != "-" else None
        elif name == "xargs" and DANGER_RE.search(" ".join(args)):
            verdict.add(ASK, "xargs feeding a delete: targets come from input")
        elif name in ("rm", "grm"):
            check_rm(args, cwd, verdict)
        elif name == "find":
            check_find(args, cwd, verdict)
        elif name == "git":
            check_git(args, verdict)
        elif name == "just":
            check_just(args, cwd, verdict, depth)


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command") or ""
    cwd = os.path.realpath(data.get("cwd") or os.getcwd())
    verdict = Verdict()
    try:
        analyze(command, cwd, verdict)
    except Exception as error:  # a broken guard should ask, not wave things through
        if DANGER_RE.search(command):
            verdict.add(ASK, f"delete guard failed ({error})")
    if verdict.level == ALLOW:
        return
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny" if verdict.level == DENY else "ask",
        "permissionDecisionReason": "Delete guard: " + "; ".join(dict.fromkeys(verdict.reasons)),
    }}))


if __name__ == "__main__":
    main()
