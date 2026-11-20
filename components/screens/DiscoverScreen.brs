sub init()
    t = th()
    m.status = m.top.findNode("status")
    m.rows = m.top.findNode("rows")
    m.signInBox = m.top.findNode("signInBox")
    m.status.color = t.textDim
    m.status.translation = [t.leftPad, t.rowsTop + 60]
    m.status.width = 1500
    setupHero()
    styleRows(m.rows, t.rowsTop)
    m.rows.observeField("rowItemFocused", "onItemFocused")
    m.rows.observeField("rowItemSelected", "onItemSelected")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.global.observeField("seerrState", "onSeerrState")
    m.gen = 0
    m.signInBtn = invalid
    m.seenVersion = m.global.watchVersion
end sub

sub load()
    setupMenu("discover")
    onSeerrState()
end sub

sub onSeerrState()
    state = m.global.seerrState
    if state = "ready"
        m.signInBox.visible = false
        fetchAll()
    else if state = "signedOut"
        showSignIn()
    else
        m.rows.visible = false
        m.status.visible = true
        m.status.text = "Seerr isn't connected. An administrator can set it up in Settings, under Connections."
    end if
end sub

sub showSignIn()
    t = th()
    m.rows.visible = false
    m.status.visible = false
    m.signInBox.removeChildrenIndex(m.signInBox.getChildCount(), 0)
    m.signInBox.translation = [t.leftPad, 380]
    m.signInBox.visible = true
    title = makeLabel(m.signInBox, "Request movies and shows", 56, true, t.text)
    body = makeLabel(m.signInBox, "Sign in to Seerr once with a Quick Connect code, and you can browse what's trending and ask for anything that isn't in the library yet.", 30, false, t.textDim)
    body.translation = [0, 90]
    body.width = 1100
    body.wrap = true
    m.signInBtn = makeButton(m.signInBox, "Sign in to Seerr", 320)
    m.signInBtn.group.translation = [0, 230]
    paintButton(m.signInBtn, true)
    if m.top.isInFocusChain() and not menuIsOpen() then m.top.setFocus(true)
end sub

sub fetchAll()
    m.gen = m.gen + 1
    m.defs = [
        { title: "Trending this week", path: "/discover/trending", query: { "page": "1" } },
        { title: "Popular movies", path: "/discover/movies", query: { "page": "1" } },
        { title: "Popular shows", path: "/discover/tv", query: { "page": "1" } },
        { title: "Coming soon", path: "/discover/movies/upcoming", query: { "page": "1" } }
    ]
    m.results = [invalid, invalid, invalid, invalid]
    m.pending = m.defs.Count()
    m.status.text = "Loading..."
    m.status.visible = true
    for i = 0 to m.defs.Count() - 1
        d = m.defs[i]
        seerrRequest(d.path, d.query, "onRow", "GET", invalid, m.gen * 1000 + i)
    end for
end sub

sub onRow(event as object)
    res = event.getData()
    tag = res.tag
    if tag \ 1000 <> m.gen then return
    i = tag mod 1000
    items = []
    if res.ok and isValid(res.data)
        if isValid(res.data.results)
            for each r in res.data.results
                mt = safeStr(r.mediaType)
                if mt = "movie" or mt = "tv" then items.Push(r)
            end for
        end if
    else if res.code = 401 or res.code = 403
        m.top.navigate = { action: "seerrSignedOut" }
    end if
    m.results[i] = items
    m.pending = m.pending - 1
    if m.pending <= 0 then build()
end sub

sub build()
    t = th()
    root = CreateObject("roSGNode", "ContentNode")
    sizes = []
    heights = []
    for i = 0 to m.defs.Count() - 1
        items = m.results[i]
        if items <> invalid
            if items.Count() > 0
                row = root.CreateChild("ContentNode")
                row.title = m.defs[i].title
                for each r in items
                    row.appendChild(seerrToContent(r))
                end for
                sizes.Push(cellSize(false))
                heights.Push(rowHeight(false))
            end if
        end if
    end for
    if root.getChildCount() = 0
        m.status.text = "Seerr didn't return anything to show right now."
        return
    end if
    m.status.visible = false
    m.rows.rowItemSize = sizes
    m.rows.rowHeights = heights
    m.rows.content = root
    m.rows.visible = true
    if m.top.isInFocusChain() and not menuIsOpen() then m.rows.setFocus(true)
    heroShow(root.getChild(0).getChild(0), true)
end sub

sub onItemFocused(event as object)
    idx = event.getData()
    if m.rows.content = invalid then return
    row = m.rows.content.getChild(idx[0])
    if row = invalid then return
    c = row.getChild(idx[1])
    if c <> invalid then heroShow(c)
end sub

sub onItemSelected(event as object)
    idx = event.getData()
    row = m.rows.content.getChild(idx[0])
    if row = invalid then return
    c = row.getChild(idx[1])
    if c = invalid then return
    m.top.navigate = { action: "seerrDetails", tmdbId: c.itemId, mediaType: Mid(c.itemType, 7) }
end sub

sub restoreContentFocus()
    if m.rows.visible and m.rows.content <> invalid
        m.rows.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() and not menuIsOpen()
        if m.rows.visible and m.rows.content <> invalid then m.rows.setFocus(true)
    end if
end sub

sub onRefresh()
    ' Request Status may have changed after a Request.
    if m.global.watchVersion = m.seenVersion then return
    m.seenVersion = m.global.watchVersion
    if m.global.seerrState = "ready" and m.rows.visible then fetchAll()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press or menuIsOpen() then return false
    if key = menuOpenKey()
        openMenu()
        return true
    else if key = "play" and not m.signInBox.visible
        return toggleTrailerSound()
    else if (key = "OK" or key = "play") and m.signInBox.visible
        m.top.navigate = { action: "seerrSignIn" }
        return true
    end if
    return false
end function
