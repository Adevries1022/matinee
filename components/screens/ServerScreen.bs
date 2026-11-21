sub init()
    m.top.findNode("brand").color = th().accent
    m.status = m.top.findNode("status")
    m.list = m.top.findNode("list")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.items = []
    m.rows = []
    m.index = 0
    m.panel = invalid
    m.busy = false
    m.found = []
    scan()
end sub

sub onMessage()
    if m.top.message <> "" then m.status.text = m.top.message
end sub

sub scan()
    if m.top.message = "" then m.status.text = "Looking for Jellyfin servers on your network..."
    m.found = []
    renderList()
    m.disc = CreateObject("roSGNode", "DiscoveryTask")
    m.disc.observeField("servers", "onServers")
    m.disc.control = "RUN"
end sub

sub onServers()
    m.found = m.disc.servers
    if m.found = invalid then m.found = []
    n = m.found.Count()
    if m.top.message = ""
        if n = 0
            m.status.text = "No servers found automatically. Make sure the TV and the server are on the same network, or enter the address yourself."
        else if n = 1
            m.status.text = "Found your server. Press OK to connect."
        else
            m.status.text = "Found " + n.ToStr() + " servers. Pick one."
        end if
    end if
    m.index = 0
    renderList()
end sub

sub renderList()
    m.items = []
    for each s in m.found
        m.items.Push({ kind: "server", name: s.name, url: normalizeUrl(s.address) })
    end for
    reg = CreateObject("roRegistrySection", "Marquee")
    if reg.Exists("server")
        saved = reg.Read("server")
        known = false
        for each it in m.items
            if it.url = saved then known = true
        end for
        if not known and saved <> ""
            savedName = "Last used server"
            if reg.Exists("serverName") then savedName = reg.Read("serverName")
            m.items.Push({ kind: "server", name: savedName, url: saved })
        end if
    end if
    m.items.Push({ kind: "manual", name: "Enter address manually", url: "" })
    m.items.Push({ kind: "rescan", name: "Search again", url: "" })

    m.list.removeChildrenIndex(m.list.getChildCount(), 0)
    m.rows = []
    for i = 0 to m.items.Count() - 1
        it = m.items[i]
        g = m.list.CreateChild("Group")
        g.translation = [0, i * 124]
        r = g.CreateChild("Rectangle")
        r.width = 1100
        r.height = 108
        n = g.CreateChild("Label")
        n.translation = [36, 0]
        n.width = 1030
        n.font = makeFont(34, true)
        n.text = it.name
        u = g.CreateChild("Label")
        u.translation = [36, 62]
        u.width = 1030
        u.font = makeFont(24)
        u.text = it.url
        if it.url = ""
            n.height = 108
            n.vertAlign = "center"
        else
            n.translation = [36, 14]
        end if
        m.rows.Push({ rect: r, name: n, url: u })
    end for
    if m.index >= m.items.Count() then m.index = 0
    paint()
end sub

sub paint()
    for i = 0 to m.rows.Count() - 1
        row = m.rows[i]
        if i = m.index
            row.rect.color = "0xFFFFFFFF"
            row.name.color = "0x0B0B0FFF"
            row.url.color = "0x55555FFF"
        else
            row.rect.color = "0xFFFFFF14"
            row.name.color = "0xFFFFFFFF"
            row.url.color = "0x9A9AA5FF"
        end if
    end for
end sub

sub choose()
    it = m.items[m.index]
    if it.kind = "server"
        connect(it.url, it.name)
    else if it.kind = "manual"
        openPanel()
    else if it.kind = "rescan"
        m.top.message = ""
        scan()
    end if
end sub

sub connect(url as string, name as string)
    if m.busy or url = "" then return
    m.busy = true
    m.pendingUrl = url
    m.pendingName = name
    m.global.serverUrl = url
    m.global.token = ""
    m.status.text = "Connecting to " + name + "..."
    apiRequest("/System/Info/Public", {}, "onInfo")
end sub

sub onInfo(event as object)
    m.busy = false
    res = event.getData()
    if res.ok and isValid(res.data)
        name = safeStr(res.data.ServerName)
        if name = "" then name = m.pendingName
        m.top.navigate = { action: "serverChosen", url: m.pendingUrl, name: name }
    else
        m.status.text = "Couldn't connect to " + m.pendingUrl + ". Check that Jellyfin is running and the address is right."
    end if
end sub

sub openPanel()
    p = CreateObject("roSGNode", "TextEntryPanel")
    p.title = "Server address"
    p.hint = "Include the port. For example: http://192.168.1.50:8096"
    p.buttonText = "Connect"
    p.text = "http://"
    p.observeField("submitted", "onManual")
    p.observeField("cancelled", "closePanel")
    m.top.appendChild(p)
    m.panel = p
    p.setFocus(true)
end sub

sub onManual()
    url = normalizeUrl(m.panel.submitted)
    closePanel()
    if url = "" or url = "http:" then return
    connect(url, url)
end sub

sub closePanel()
    if m.panel = invalid then return
    m.top.removeChild(m.panel)
    m.panel = invalid
    m.top.setFocus(true)
end sub

sub onFocusChanged()
    if m.top.hasFocus() and m.panel <> invalid then m.panel.setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press or m.panel <> invalid then return false
    if key = "up"
        if m.index > 0 then m.index = m.index - 1
        paint()
        return true
    else if key = "down"
        if m.index < m.items.Count() - 1 then m.index = m.index + 1
        paint()
        return true
    else if key = "OK"
        choose()
        return true
    end if
    return false
end function
