' Settings: opens to two tiles, Appearance and Connections.
' Each setting opens a short list of its options; moving through the list
' previews each option live, OK keeps it and Back cancels.
sub init()
    m.page = m.top.findNode("page")
    m.view = "home"
    m.homeIndex = 0
    m.index = 0
    m.optionsOpen = false
    m.optIndex = 0
    m.panel = invalid
    m.toastText = ""
    m.top.observeField("focusedChild", "onFocusChanged")
    m.global.observeField("seerrState", "render")
    render()
    rebuildMenu()
end sub

' ---------- What each page holds ----------

function themeChoices() as object
    return [{ v: "midnight", l: "Midnight Glass" }, { v: "void", l: "Void" }, { v: "classic", l: "Amber" }]
end function

function accentChoices() as object
    return [{ v: "", l: "Theme default" }, { v: "amber", l: "Amber" }, { v: "red", l: "Red" }, { v: "teal", l: "Teal" }, { v: "violet", l: "Violet" }, { v: "blue", l: "Blue" }, { v: "white", l: "White" }]
end function

function onOff() as object
    return [{ v: false, l: "Off" }, { v: true, l: "On" }]
end function

function appearanceRows() as object
    return [
        { key: "theme", label: "Theme", choices: themeChoices(), help: "The overall look: colors, corners and panels." },
        { key: "accent", label: "Accent", choices: accentChoices(), help: "The highlight color for focus, progress and badges." },
        { key: "bigHero", label: "Big Hero", choices: onOff(), help: "Taller artwork at the top, with just the title and details." },
        { key: "miniCards", label: "Mini Cards", choices: onOff(), help: "Smaller Cards, so more titles fit on screen." },
        { key: "navStyle", label: "Menu style", choices: [{ v: "rail", l: "Side Rail" }, { v: "top", l: "Top Bar" }], help: "Where the main menu lives." },
        { key: "reduceMotion", label: "Reduce Motion", choices: onOff(), help: "Turns off Card zoom, fades and Trailer Previews." }
    ]
end function

function connectionRows() as object
    reg = CreateObject("roRegistrySection", "Marquee")
    serverName = "Your server"
    if reg.Exists("serverName") then serverName = reg.Read("serverName")
    state = m.global.seerrState
    seerrValue = "Not found"
    if state = "ready" then seerrValue = "Connected"
    if state = "signedOut" then seerrValue = "Sign in"
    return [
        { key: "server", label: "Jellyfin server", value: serverName, admin: true, help: "Switch to a different Jellyfin server." },
        { key: "seerr", label: "Seerr", value: seerrValue, admin: false, help: "Requests. Sign in with a Quick Connect code; an administrator can change the address." },
        { key: "alwaysAsk", label: "Who's Watching", choices: [{ v: "false", l: "Only when needed" }, { v: "true", l: "Always ask" }], admin: true, help: "Show the Who's Watching screen every time Matinee opens, or only when there's more than one person." },
        { key: "signout", label: "Sign out", value: m.global.userName, admin: false, help: "Sign out of this account on this TV." }
    ]
end function

function currentRows() as object
    if m.view = "appearance" then return appearanceRows()
    return connectionRows()
end function

function valueKey(v as dynamic) as string
    t = type(v)
    if t = "Boolean" or t = "roBoolean"
        if v then return "true"
        return "false"
    end if
    return safeStr(v)
end function

function currentValue(r as object) as string
    if r.key = "alwaysAsk"
        reg = CreateObject("roRegistrySection", "Marquee")
        if reg.Exists("alwaysAsk") then return reg.Read("alwaysAsk")
        return "false"
    end if
    return valueKey(m.global.prefs[r.key])
end function

function choiceIndex(r as object) as integer
    cur = currentValue(r)
    for i = 0 to r.choices.Count() - 1
        if valueKey(r.choices[i].v) = cur then return i
    end for
    return 0
end function

' ---------- Drawing ----------

sub render()
    t = th()
    p = m.page
    p.removeChildrenIndex(p.getChildCount(), 0)
    x = t.leftPad
    if m.view = "home"
        renderHome(p, t, x)
    else
        renderPage(p, t, x)
    end if
    toast = makeLabel(p, m.toastText, 26, false, t.accent)
    toast.translation = [x, 1020]
    toast.width = 1600
end sub

sub renderHome(p as object, t as object, x as integer)
    head = makeLabel(p, "Settings", 56, true, t.text)
    head.translation = [x, 56]
    tiles = [
        { title: "Appearance", icon: "settings", body: "Theme, accent, layout and menu style. Just for " + m.global.userName + "." },
        { title: "Connections", icon: "switch", body: "Jellyfin server, Seerr requests and Who's Watching. For everyone on this TV." }
    ]
    for i = 0 to 1
        tile = tiles[i]
        focused = (i = m.homeIndex) and not menuIsOpen()
        g = p.CreateChild("Group")
        g.translation = [x + i * 640, 260]
        bgColor = t.surface
        bgOpacity = t.surfaceOpacity * 1.6
        textColor = t.text
        bodyColor = t.textDim
        if focused
            bgColor = "0xFFFFFFFF"
            bgOpacity = 1.0
            textColor = "0x0B0B0FFF"
            bodyColor = "0x3A3A44FF"
        end if
        makeShape(g, t.fillUri, 600, 340, bgColor, bgOpacity)
        ic = g.CreateChild("Poster")
        ic.uri = "pkg:/images/icon_" + tile.icon + ".png"
        ic.width = 56
        ic.height = 56
        ic.translation = [44, 44]
        ic.blendColor = t.accent
        if focused then ic.blendColor = "0x0B0B0FFF"
        tl = makeLabel(g, tile.title, 44, true, textColor)
        tl.translation = [44, 130]
        bl = makeLabel(g, tile.body, 28, false, bodyColor)
        bl.translation = [44, 196]
        bl.width = 512
        bl.wrap = true
        bl.lineSpacing = 4
    end for
    if not m.global.isAdmin
        note = makeLabel(p, "Connections can only be changed by a Jellyfin administrator.", 26, false, t.textFaint)
        note.translation = [x, 640]
    end if
end sub

sub renderPage(p as object, t as object, x as integer)
    rows = currentRows()
    m.rows = rows
    if m.index >= rows.Count() then m.index = 0
    title = "Appearance"
    note = "Just for " + m.global.userName
    if m.view = "connections"
        title = "Connections"
        note = "For everyone on this TV"
        if not m.global.isAdmin then note = "Only an administrator can change most of these"
    end if
    crumb = makeLabel(p, "Settings", 26, true, t.textFaint)
    crumb.translation = [x, 50]
    head = makeLabel(p, title, 56, true, t.text)
    head.translation = [x, 84]
    sub1 = makeLabel(p, note, 24, false, t.textFaint)
    sub1.translation = [x, 156]

    rowW = 560
    y = 220
    for i = 0 to rows.Count() - 1
        r = rows[i]
        focused = (i = m.index) and not m.optionsOpen and not menuIsOpen()
        opened = (i = m.index) and m.optionsOpen
        bg = makeShape(p, t.fillUri, rowW + 40, 72, t.surface, 0)
        bg.translation = [x - 20, y]
        textColor = t.text
        valueColor = t.textDim
        if focused
            bg.blendColor = "0xFFFFFFFF"
            bg.opacity = 1
            textColor = "0x0B0B0FFF"
            valueColor = "0x3A3A44FF"
        else if opened
            bg.opacity = t.surfaceHiOpacity
        end if
        locked = isTrue(r.admin) and not m.global.isAdmin
        if locked and not focused then textColor = t.textFaint
        lbl = makeLabel(p, r.label, 30, true, textColor)
        lbl.translation = [x, y]
        lbl.height = 72
        lbl.vertAlign = "center"
        value = ""
        if r.choices <> invalid
            value = r.choices[choiceIndex(r)].l
        else
            value = safeStr(r.value)
        end if
        v = makeLabel(p, value, 26, false, valueColor)
        v.translation = [x + 250, y]
        v.width = rowW - 250
        v.height = 72
        v.vertAlign = "center"
        v.horizAlign = "right"
        y = y + 84
    end for

    ' Help for the focused setting.
    help = makeLabel(p, safeStr(rows[m.index].help), 26, false, t.textDim)
    help.translation = [x, y + 20]
    help.width = rowW
    help.wrap = true
    help.lineSpacing = 4

    if m.optionsOpen then drawOptions(p, t, x + rowW + 60, 220)
    if m.view = "appearance" then drawPreview(p, t, 1160, 220, 680)
end sub

' The open setting's options. Themes are shown as picture cards.
sub drawOptions(p as object, t as object, ox as integer, oy as integer)
    r = m.rows[m.optIndexRow]
    y = oy
    for i = 0 to r.choices.Count() - 1
        c = r.choices[i]
        focused = (i = m.optIndex)
        if r.key = "theme"
            drawThemeCard(p, t, c, ox, y, focused)
            y = y + 150
        else
            bgColor = t.surface
            bgOpacity = t.surfaceOpacity
            color = t.text
            if focused
                bgColor = "0xFFFFFFFF"
                bgOpacity = 1
                color = "0x0B0B0FFF"
            end if
            bg = makeShape(p, t.pillUri, 340, 64, bgColor, bgOpacity)
            bg.translation = [ox, y]
            if r.key = "accent" and c.v <> ""
                palette = accentColors()
                dotShape = makeShape(p, t.fillUri, 26, 26, palette[c.v], 1)
                dotShape.translation = [ox + 26, y + 19]
            end if
            l = makeLabel(p, c.l, 28, focused, color)
            l.translation = [ox + 70, y]
            l.height = 64
            l.width = 260
            l.vertAlign = "center"
            y = y + 76
        end if
    end for
    tip = makeLabel(p, "OK keeps it. Back cancels.", 22, false, t.textFaint)
    tip.translation = [ox, y + 10]
end sub

' A small picture of a Theme: its background, a few Cards in its shape,
' and its Accent.
sub drawThemeCard(p as object, t as object, c as object, ox as integer, oy as integer, focused as boolean)
    other = themeTokens({ theme: c.v })
    g = p.CreateChild("Group")
    g.translation = [ox, oy]
    if focused
        ring = makeShape(g, t.ringUri, 352, 136, "0xFFFFFFFF", 1)
        ring.translation = [-6, -6]
    end if
    makeShape(g, other.fillUri, 340, 124, other.bg, 1)
    for k = 0 to 2
        cardShape = makeShape(g, other.fillUri, 64, 44, "0xFFFFFFFF", 0.22)
        cardShape.translation = [20 + k * 76, 20]
        if k = 0
            cardShape.blendColor = other.accent
            cardShape.opacity = 1
        end if
    end for
    bar = makeShape(g, other.fillUri, 140, 6, other.accent, 1)
    bar.translation = [20, 74]
    l = makeLabel(g, c.l, 26, true, "0xFFFFFFFF")
    l.translation = [20, 84]
end sub

' A scaled-down picture of the home screen in the current Appearance.
sub drawPreview(p as object, t as object, px as integer, py as integer, pw as integer)
    scale = pw / 1920.0
    ph = Int(1080 * scale)
    frame = p.CreateChild("Group")
    frame.translation = [px, py]
    border = makeShape(frame, t.fillUri, pw + 8, ph + 8, t.surface, t.surfaceHiOpacity)
    border.translation = [-4, -4]
    clip = frame.CreateChild("Group")
    clip.clippingRect = [0, 0, pw, ph]
    world = clip.CreateChild("Group")
    world.scale = [scale, scale]

    bg = world.CreateChild("Rectangle")
    bg.width = 1920
    bg.height = 1080
    bg.color = t.bg
    items = m.global.previewItems
    if items = invalid then items = []
    if items.Count() > 0
        bd = world.CreateChild("Poster")
        bd.width = 1920
        bd.height = 1080
        bd.loadWidth = 960
        bd.loadHeight = 540
        bd.loadDisplayMode = "scaleToZoom"
        bd.uri = items[0].backdrop
    end if
    addBackdropShade(world, t.rowsTop - 6)

    title = "Your next favorite"
    meta = "2026" + dot() + "Drama"
    if items.Count() > 0
        title = items[0].heading
        meta = items[0].meta
    end if
    tl = makeLabel(world, title, 70, true, t.text)
    if t.bigHero then tl.font = makeFont(84, true)
    ty = t.heroTop + 45
    if t.bigHero then ty = t.rowsTop - 290
    tl.translation = [t.leftPad, ty]
    tl.width = 1150
    ml = makeLabel(world, meta, 28, false, t.textDim)
    ml.translation = [t.leftPad, ty + 110]
    ml.width = 1300

    rl = makeLabel(world, "Continue Watching", 30, true, t.text)
    rl.translation = [t.leftPad, t.rowsTop + 14]
    cx = t.leftPad
    cy = t.rowsTop + 64
    for i = 0 to 5
        w = t.landW
        h = t.landH
        card = world.CreateChild("Group")
        card.translation = [cx, cy]
        makeShape(card, t.fillUri, w, h, t.surface, t.surfaceOpacity * 1.6)
        if i < items.Count()
            img = card.CreateChild("Poster")
            img.width = w
            img.height = h
            img.loadWidth = Int(w / 2)
            img.loadHeight = Int(h / 2)
            img.loadDisplayMode = "scaleToZoom"
            img.uri = items[i].image
        end if
        if t.cornerUri <> ""
            makeShape(card, t.cornerUri, w, h, t.bg, 1.0)
        end if
        if i = 0
            track = card.CreateChild("Rectangle")
            track.translation = [0, h - 6]
            track.width = w * 0.6
            track.height = 6
            track.color = t.accent
            makeShape(card, t.ringUri, w, h, t.focusColor, 1.0)
            card.scale = [t.cardFocusScale, t.cardFocusScale]
        end if
        cx = cx + w + 28
    end for

    if t.navStyle = "rail"
        strip = world.CreateChild("Poster")
        strip.uri = "pkg:/images/grad_left.png"
        strip.width = 300
        strip.height = 1080
        strip.loadDisplayMode = "scaleToFill"
        strip.blendColor = t.bg
        strip.opacity = 0.92
        mk = makeLabel(world, "M", 46, true, t.accent)
        mk.translation = [44, 52]
        icons = ["home", "search", "movies", "shows", "settings"]
        for i = 0 to icons.Count() - 1
            ic = world.CreateChild("Poster")
            ic.uri = "pkg:/images/icon_" + icons[i] + ".png"
            ic.width = 60
            ic.height = 60
            ic.translation = [40, 210 + i * 100]
            if i = 0
                ic.blendColor = t.accent
            else
                ic.blendColor = t.textDim
            end if
        end for
    else
        bar = world.CreateChild("LayoutGroup")
        bar.translation = [96, 56]
        bar.layoutDirection = "horiz"
        bar.itemSpacings = [52]
        makeLabel(bar, "MATINEE", 34, true, t.accent)
        makeLabel(bar, "Home", 30, true, t.text)
        makeLabel(bar, "Search", 30, true, t.textFaint)
        makeLabel(bar, "Movies", 30, true, t.textFaint)
        makeLabel(bar, "Shows", 30, true, t.textFaint)
    end if

    cap = makeLabel(p, "Live preview", 24, true, t.textFaint)
    cap.translation = [px, py + ph + 20]
    desc = makeLabel(p, themeDescription(t.name), 24, false, t.textDim)
    desc.translation = [px, py + ph + 56]
    desc.width = pw
    desc.wrap = true
end sub

function themeDescription(name as string) as string
    if name = "void" then return "Void: pure black and flat with sharp corners, so only the artwork has color."
    if name = "classic" then return "Amber: the original look, with square Cards and an amber Accent."
    return "Midnight Glass: a black base, rounded Cards and frosted panels that pick up the artwork behind them."
end function

' Rebuild the menu so a new Menu style or Theme shows straight away.
sub rebuildMenu()
    if m.menu <> invalid then m.top.removeChild(m.menu)
    m.menu = invalid
    setupMenu("settings")
end sub

' ---------- Options list ----------

sub openOptions()
    r = m.rows[m.index]
    m.toastText = ""
    if isTrue(r.admin) and not m.global.isAdmin
        m.toastText = "Only an administrator can change this."
        render()
        return
    end if
    if r.choices = invalid
        runAction(r)
        return
    end if
    m.optionsOpen = true
    m.optIndexRow = m.index
    m.optIndex = choiceIndex(r)
    m.savedPrefs = m.global.prefs
    render()
end sub

' Show the option under the highlight without saving it yet.
sub previewOption()
    r = m.rows[m.optIndexRow]
    if m.view = "appearance"
        prefs = m.global.prefs
        prefs[r.key] = r.choices[m.optIndex].v
        applyPrefs(prefs)
    end if
    render()
end sub

sub keepOption()
    r = m.rows[m.optIndexRow]
    choice = r.choices[m.optIndex]
    m.optionsOpen = false
    if m.view = "appearance"
        prefs = m.global.prefs
        prefs[r.key] = choice.v
        savePrefs(prefs)
        applyPrefs(prefs)
        rebuildMenu()
    else if r.key = "alwaysAsk"
        reg = CreateObject("roRegistrySection", "Marquee")
        reg.Write("alwaysAsk", choice.v)
        reg.Flush()
    end if
    render()
end sub

sub cancelOptions()
    m.optionsOpen = false
    if m.view = "appearance" and m.savedPrefs <> invalid then applyPrefs(m.savedPrefs)
    render()
end sub

sub runAction(r as object)
    if r.key = "server"
        m.top.navigate = { action: "changeServer" }
    else if r.key = "seerr"
        state = m.global.seerrState
        if state = "signedOut"
            m.top.navigate = { action: "seerrSignIn" }
        else if m.global.isAdmin
            openSeerrPanel()
        else if state = "ready"
            m.toastText = "You're signed in to Seerr."
            render()
        else
            m.toastText = "Seerr wasn't found. An administrator can set its address here."
            render()
        end if
    else if r.key = "signout"
        m.top.navigate = { action: "signout" }
    end if
end sub

sub openSeerrPanel()
    p = CreateObject("roSGNode", "TextEntryPanel")
    p.title = "Seerr address"
    p.hint = "Include the port. Seerr usually runs on port 5055, for example http://192.168.1.50:5055"
    p.buttonText = "Save"
    current = m.global.seerrUrl
    if current = "" then current = "http://"
    p.text = current
    p.observeField("submitted", "onSeerrAddress")
    p.observeField("cancelled", "closePanel")
    m.top.appendChild(p)
    m.panel = p
    p.setFocus(true)
end sub

sub onSeerrAddress()
    url = normalizeUrl(m.panel.submitted)
    closePanel()
    if url = "" or url = "http:" then return
    reg = CreateObject("roRegistrySection", "Marquee")
    reg.Write("seerrUrl", url)
    reg.Flush()
    m.toastText = "Checking Seerr..."
    render()
    m.top.navigate = { action: "seerrChanged" }
end sub

sub closePanel()
    if m.panel = invalid then return
    m.top.removeChild(m.panel)
    m.panel = invalid
    m.top.setFocus(true)
    render()
end sub

' ---------- Focus & keys ----------

sub restoreContentFocus()
    m.top.setFocus(true)
    render()
end sub

sub onFocusChanged()
    if m.top.hasFocus() and m.panel <> invalid then m.panel.setFocus(true)
end sub

sub onRefresh()
    render()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press or m.panel <> invalid or menuIsOpen() then return false

    if m.view = "home"
        if key = "right"
            if m.homeIndex < 1 then m.homeIndex = m.homeIndex + 1
        else if key = "left"
            if m.homeIndex > 0
                m.homeIndex = m.homeIndex - 1
            else if th().navStyle = "rail"
                openMenu()
            end if
        else if key = "up" and th().navStyle = "top"
            openMenu()
        else if key = "OK"
            m.view = "appearance"
            if m.homeIndex = 1 then m.view = "connections"
            m.index = 0
            m.toastText = ""
        else
            return false
        end if
        render()
        return true
    end if

    if m.optionsOpen
        r = m.rows[m.optIndexRow]
        if key = "up"
            if m.optIndex > 0
                m.optIndex = m.optIndex - 1
                previewOption()
            end if
        else if key = "down"
            if m.optIndex < r.choices.Count() - 1
                m.optIndex = m.optIndex + 1
                previewOption()
            end if
        else if key = "OK"
            keepOption()
        else if key = "back" or key = "left"
            cancelOptions()
        end if
        return true
    end if

    if key = "up"
        if m.index > 0 then m.index = m.index - 1
    else if key = "down"
        if m.index < m.rows.Count() - 1 then m.index = m.index + 1
    else if key = "OK" or key = "right"
        openOptions()
        return true
    else if key = "back" or key = "left"
        m.view = "home"
        m.toastText = ""
    else
        return false
    end if
    render()
    return true
end function
