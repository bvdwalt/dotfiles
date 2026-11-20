rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

-- Ghostty
rex.bind("shift+insert", "pane.paste")
rex.bind("ctrl+insert", "pane.copy")

-- zellij: modes
rex.mode("locked", { exclusive = true })
rex.mode("pane", { exclusive = true })
rex.mode("tab", { exclusive = true })
rex.mode("resize", { exclusive = true })
rex.mode("move", { exclusive = true })

-- zellij: normal mode and keys shared by every unlocked mode
rex.bind("ctrl+space", "client.mode.enter", { name = "tmux", once = true })
rex.bind("ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("alt+i", "client.tab.move", { direction = "backward" })
rex.bind("alt+o", "client.tab.move", { direction = "forward" })
rex.bind("alt+n", "pane.split", { direction = "auto" })

-- zellij: locked
rex.bind("locked/ctrl+g", "client.mode.exit_all")

-- zellij: tmux (acts once)
rex.bind("tmux/left", "pane.focus", { direction = "left" })
rex.bind("tmux/down", "pane.focus", { direction = "down" })
rex.bind("tmux/up", "pane.focus", { direction = "up" })
rex.bind("tmux/right", "pane.focus", { direction = "right" })
rex.bind("tmux/h", "pane.focus", { direction = "left" })
rex.bind("tmux/j", "pane.focus", { direction = "down" })
rex.bind("tmux/k", "pane.focus", { direction = "up" })
rex.bind("tmux/l", "pane.focus", { direction = "right" })
rex.bind("tmux/g", "client.mode.enter", { name = "locked" })
rex.bind("tmux/p", "client.mode.enter", { name = "pane" })
rex.bind("tmux/t", "client.mode.enter", { name = "tab" })
rex.bind("tmux/n", "client.mode.enter", { name = "resize" })
rex.bind("tmux/m", "client.mode.enter", { name = "move" })
rex.bind("tmux/x", "pane.close")
rex.bind("tmux/enter", "client.mode.exit_all")
rex.bind("tmux/esc", "client.mode.exit_all")

-- zellij: pane
rex.bind("pane/left", "pane.focus", { direction = "left" })
rex.bind("pane/down", "pane.focus", { direction = "down" })
rex.bind("pane/up", "pane.focus", { direction = "up" })
rex.bind("pane/right", "pane.focus", { direction = "right" })
rex.bind("pane/h", "pane.focus", { direction = "left" })
rex.bind("pane/j", "pane.focus", { direction = "down" })
rex.bind("pane/k", "pane.focus", { direction = "up" })
rex.bind("pane/l", "pane.focus", { direction = "right" })
rex.bind("pane/c", "then_normal", { action = "pane.rename" })
rex.bind("pane/d", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/f", "then_normal", { action = "pane.zoom" })
rex.bind("pane/n", "then_normal", { action = "pane.split", args = { direction = "auto" } })
rex.bind("pane/r", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("pane/x", "then_normal", { action = "pane.close" })

-- zellij: tab
rex.bind("tab/left", "client.tab.previous")
rex.bind("tab/down", "client.tab.next")
rex.bind("tab/up", "client.tab.previous")
rex.bind("tab/right", "client.tab.next")
rex.bind("tab/h", "client.tab.previous")
rex.bind("tab/j", "client.tab.next")
rex.bind("tab/k", "client.tab.previous")
rex.bind("tab/l", "client.tab.next")
for i = 1, 9 do
  rex.bind("tab/" .. i, "then_normal", { action = "client.tab.goto", args = { index = i } })
end
rex.bind("tab/b", "then_normal", { action = "pane.move_to_new_tab" })
rex.bind("tab/n", "then_normal", { action = "client.tab.new" })
rex.bind("tab/r", "then_normal", { action = "client.tab.rename" })
rex.bind("tab/x", "then_normal", { action = "client.tab.close" })

-- zellij: resize
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })

-- zellij: move
rex.bind("move/left", "pane.move", { direction = "left" })
rex.bind("move/down", "pane.move", { direction = "down" })
rex.bind("move/up", "pane.move", { direction = "up" })
rex.bind("move/right", "pane.move", { direction = "right" })
rex.bind("move/h", "pane.move", { direction = "left" })
rex.bind("move/j", "pane.move", { direction = "down" })
rex.bind("move/k", "pane.move", { direction = "up" })
rex.bind("move/l", "pane.move", { direction = "right" })

-- zellij: keys that apply in every unlocked mode, repeated for the exclusive ones
for _, m in ipairs({ "pane", "tab", "resize", "move" }) do
  rex.bind(m .. "/ctrl+space", "client.mode.enter", { name = "tmux", once = true })
  rex.bind(m .. "/ctrl+g", "client.mode.enter", { name = "locked" })
  rex.bind(m .. "/alt+i", "client.tab.move", { direction = "backward" })
  rex.bind(m .. "/alt+o", "client.tab.move", { direction = "forward" })
  rex.bind(m .. "/alt+n", "pane.split", { direction = "auto" })
  rex.bind(m .. "/enter", "client.mode.exit_all")
  rex.bind(m .. "/esc", "client.mode.exit_all")
end
