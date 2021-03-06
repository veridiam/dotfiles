local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local lain = require("lain")
local html = require("html")
local applications = require("applications")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end


-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. 
"/.config/awesome/themes/adwaita/theme.lua")


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, false)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { "main" , "chat" , "files", "media" , "games", "dev" , "mail" , "misc" },
	layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu

powermenu = {
          { "Reboot" , "systemctl reboot" },
          { "Shut Down", "systemctl poweroff" },
}

mymainmenu = awful.menu({ items = { { "Browser", browser },
                                    { "Files", filemanager },
                                    { "Mail", mailclient },
                                    { "Terminal", terminal },
                                    { "-----------" },
                                    { "Applications", myappmenu },
                                    { "Settings", settingsmenu },
                                    { "-----------" },
                                    { "Reload" , awesome.restart },
                                    { "Lock Screen" , lock_cmd },
                                    { "Power" , powermenu },
                                    { "Log Out" , awesome.quit }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
local awesompd = require("awesompd/awesompd")
  musicwidget = awesompd:create() -- Create awesompd widget
  musicwidget.font = "Source Sans Pro" -- Set widget font 
  musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
  musicwidget.output_size = 30 -- Set the size of widget in symbols
  musicwidget.update_interval = 10 -- Set the update interval in seconds
  -- Set the folder where icons are located (change username to your login name)
  musicwidget.path_to_icons = "/home/alex/.config/awesome/awesompd/icons" 
  -- Set the default music format for Jamendo streams. You can change
  -- this option on the fly in awesompd itself.
  -- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
  musicwidget.jamendo_format = awesompd.FORMAT_MP3
  -- If true, song notifications for Jamendo tracks and local tracks will also contain
  -- album cover image.
  musicwidget.show_album_cover = true
  -- Specify how big in pixels should an album cover be. Maximum value
  -- is 100.
  musicwidget.album_cover_size = 50
  -- This option is necessary if you want the album covers to be shown
  -- for your local tracks.
  musicwidget.mpd_config = "/home/alex/.config/mpd/mpd.conf"
  -- Specify the browser you use so awesompd can open links from
  -- Jamendo in it.
  musicwidget.browser = "firefox"
  -- Specify decorators on the left and the right side of the
  -- widget. Or just leave empty strings if you decorate the widget
  -- from outside.
  musicwidget.ldecorator = "♬ "
  musicwidget.rdecorator = " ♬"
  -- Set all the servers to work with (here can be any servers you use)
  musicwidget.servers = {
     { server = "localhost",
          port = 6600 }}
  -- Set the buttons of the widget
  musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_playpause() },
      			         { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
 			         { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
 			         { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
 			         { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
 			         { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
                                 { modkey, "Pause", musicwidget:command_playpause() } })
  musicwidget:run() -- After all configuration is done, run the widget

-- Initialize clock widget
datewidget = wibox.widget.textbox()
-- Register clock widget
vicious.register(datewidget, vicious.widgets.date, "%b %d - %I:%M ", 60)
-- Calendar
lain.widgets.calendar:attach(datewidget, { font_size = 9 })
-- Separator
separator = wibox.widget.textbox()
separator:set_text(" || ")
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                                  mymainmenu:hide()
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                                  mymainmenu:hide()
                                              end
                                          end),
                     awful.button({ modkey }, 1, function (c)
                                              awful.client.setmaster(c)
                                          end),
                     awful.button({}, 2, function (c)
                                              c:kill()
                                         end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))



for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ prompt = " ▶ Run: " })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "22", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(separator)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
    if s == 1 then 
                   -- Container for systray
                   local systray = wibox.widget.systray()
                   local container = wibox.layout.margin()
                   container:set_margins(3)
                   container:set_widget(systray)
                   
                   right_layout:add(musicwidget.widget)
                   right_layout:add(separator)
                   right_layout:add(container)
                   right_layout:add(separator)
                   end
    right_layout:add(datewidget)
    right_layout:add(separator)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ modkey }, 4, awful.tag.viewnext),
    awful.button({ modkey }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ "Mod1",           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ "Mod1", "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "`", function () mymainmenu:toggle({keygrabber=true}) end),

    -- Print Screen
    awful.key({        }, "Print", function () awful.util.spawn("xfce4-screenshooter -f") end),
    awful.key({"Shift" }, "Print", function () awful.util.spawn("xfce4-screenshooter -w") end),
    awful.key({"Mod1"  }, "Print", function () awful.util.spawn("xfce4-screenshooter -r") end),

    -- Launch Applications
    awful.key({ modkey,           }, "e",      function () awful.util.spawn(filemanager)  end),
    awful.key({ modkey,           }, "b",      function () awful.util.spawn(browser)      end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.tag.viewnext()
        end),
    awful.key({ modkey, "Shift" }, "Tab",
        function ()
            awful.tag.viewprev()
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.util.spawn(lock_cmd) end),
    
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = " ▶ Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "w",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "s",      awful.titlebar.toggle                            ),
    awful.key({ modkey,           }, "a",      function (c) c.size_hints_honor = not c.size_hints_honor end),
    awful.key({ modkey,           }, "d",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "y",      function (c) c.below = not c.below            end),
    awful.key({ modkey,           }, "h",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "-",      function (c) c.opacity = c.opacity - 0.2      end),
    awful.key({ modkey,           }, "=",      function (c) c.opacity = c.opacity + 0.2      end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey,           }, "v",
        function (c)
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

-- Mouse buttons on windows
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() mymainmenu:hide() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ modkey, "Shift" }, 1, awful.mouse.client.resize),
    awful.button({ modkey }, 4, function ()
            awful.tag.viewnext()
        end),
    awful.button({ modkey }, 5, function ()
            awful.tag.viewprev()
        end) )
-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     switchtotag = true } },
    { rule = { class = "URxvt" },
      properties = { size_hints_honor = false } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Plugin-container" },
      properties = { floating = true } },
    { rule = { role = "buddy_list" },
      properties = { floating = true, switchtotag = false } },
    { rule = { class = "Wine" },
      properties = { floating = true } },
    { rule = { name = "Drop" },
      properties = { floating = true } },
    { rule = { class = "Geary" }, except = { instance = "Msgcompose" },
      properties = { below = true }},
    { rule = { class = "Venom" },
      properties = { tag = tags[1][2] } },
    { rule = { role = "conversation" },
      properties = { floating = true } },
    { rule = { class = "UE4Editor" },
      properties = { border_width=0,floating = true } },
    { rule = { class = "Pqiv" },
      properties = { border_width=0 } },
    { rule = { type = "desktop" },
      properties = { border_width=0, } },
	{ rule = { class = "Steam" },
      properties = { border_width=0, floating = true, tag = tags[1][5] } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
--    c:connect_signal("mouse::enter", function(c)
--      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--          and awful.client.focus.filter(c) then
--          client.focus = c
--      end
--  end)


    -- {{{ Title Bars
    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, {size = "16"}):set_widget(layout)
    end

    -- {{ Placement
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        --awful.client.setslave(c)
        
        -- Transient clients
        if c.transient_for then
            c.screen = c.transient_for.screen
            c:tags(c.transient_for:tags())
        end
        
        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            --awful.placement.under_mouse(c)
            awful.placement.centered(c)
            
            if c.type == "normal" then
              awful.placement.no_overlap(c)
            end
        end
    end
    awful.placement.no_offscreen(c)
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--- Strips out HTML ---
naughty.config.notify_callback = function(args)
	if(args.icon) == "gtk-dialog-info" then
		args.text = HTML_ToText(args.text)
	elseif(args.icon) == "gtk-edit" then
		args.text = HTML_ToText(args.text)
	end
	return args
end
-- }}}

for i, command in ipairs(autorun) do
        run_once(command)
end

