' Search as you type. Results are one grid: library matches first, then
' (with Seerr) titles under "Not in your library" that can be Requested.
' An Info Line names the Focused title.
sub init()
    t = th()
    m.kb = m.top.findNode("kb")
    m.grid = m.top.findNode("grid")
    m.empty = m.top.findNode("empty")
    m.infoTitle = m.top.findNode("infoTitle")
    m.infoMeta = m.top.findNode("infoMeta")
    m.debounce = m.top.findNode("debounce")
    x = t.leftPad
    heading = m.top.findNode("heading")
    heading.translation = [x, 56]
    heading.color = t.text
    m.kb.translation = [x, 180]

    rx = x + 580
    cell = cellSize(false)
    cols = Int((1920 - rx - 40) / cell[0])
    if cols < 3 then cols = 3
    m.grid.translation = [rx - t.cellPadX, 150 - t.cellPadY]
    m.grid.itemSize = cell
    m.grid.itemSpacing = [0, 0]
    m.grid.numColumns = cols
    m.grid.sectionDividerFont = makeFont(30, true)
    m.grid.sectionDividerTextColor = t.text
    m.grid.sectionDividerHeight = 56
    m.grid.sectionDividerSpacing = 14

    m.empty.translation = [rx, 200]
    m.empty.color = t.textDim
    infoY = 150 + 56 + t.posterH * 2 + t.cellPadY * 2 + 30
    if infoY > 990 then infoY = 990
    m.infoTitle.translation = [rx, infoY]
    m.infoTitle.color = t.text
    m.infoMeta.translation = [rx, infoY + 42]
    m.infoMeta.color = t.textDim

    m.kb.observeField("text", "onText")
    m.debounce.observeField("fire", "doSearch")
    m.grid.observeField("itemFocused", "onItemFocused")
    m.grid.observeField("itemSelected", "onSelected")
    m.top.observeField("focusedChild", "onFocusChanged")

    m.query = ""
    m.area = "kb"
    m.libItems = []
    m.seerrItems = []
    m.flat = []
    setupMenu("search")
    showTip()
    loadPopular()
end sub

sub showTip()
    m.infoTitle.text = ""
    m.infoMeta.text = "Type to search. Press Right to move into the results."
end sub

sub restoreContentFocus()
    if m.area = "grid" and hasResults()
        m.grid.setFocus(true)
    else
        m.area = "kb"
        m.kb.setFocus(true)
        showTip()
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() and not menuIsOpen() then restoreContentFocus()
end sub

function hasResults() as boolean
    return m.flat.Count() > 0
end function

sub onText()
    m.debounce.control = "stop"
    m.debounce.control = "start"
end sub

sub loadPopular()
    m.seerrItems = []
    apiRequest("/Items", { "userId": m.global.userId, "Recursive": "true", "IncludeItemTypes": "Movie,Series", "SortBy": "Random", "Limit": "20", "Fields": "Overview,Genres", "EnableTotalRecordCount": "false" }, "onResults", "GET", invalid, "")
end sub

sub doSearch()
    q = m.kb.text.Trim()
    if q = m.query then return
    m.query = q
    m.seerrItems = []
    if q = ""
        loadPopular()
        return
    end if
    apiRequest("/Items", { "userId": m.global.userId, "searchTerm": q, "Recursive": "true", "IncludeItemTypes": "Movie,Series", "Limit": "40", "Fields": "Overview,Genres", "EnableTotalRecordCount": "false" }, "onResults", "GET", invalid, q)
    if m.global.seerrState = "ready"
        seerrRequest("/search", { "query": q, "page": "1" }, "onSeerrResults", "GET", invalid, q)
    end if
end sub

sub onResults(event as object)
    res = event.getData()
    if safeStr(res.tag) <> m.query then return
    m.libItems = []
    if res.ok and isValid(res.data)
        if isValid(res.data.Items) then m.libItems = res.data.Items
    end if
    render()
end sub

sub onSeerrResults(event as object)
    res = event.getData()
    if safeStr(res.tag) <> m.query then return
    m.seerrItems = []
    if res.ok and isValid(res.data)
        if isValid(res.data.results)
            for each r in res.data.results
                mt = safeStr(r.mediaType)
                ' Titles already fully in the library show up above.
                if (mt = "movie" or mt = "tv") and seerrStatus(r) <> 5 then m.seerrItems.Push(r)
            end for
        end if
    else if res.code = 401 or res.code = 403
        m.top.navigate = { action: "seerrSignedOut" }
    end if
    render()
end sub

sub render()
    root = CreateObject("roSGNode", "ContentNode")
    m.flat = []
    if m.libItems.Count() > 0
        section = root.CreateChild("ContentNode")
        if m.query = ""
            section.title = "Popular in your library"
        else
            section.title = "In your library"
        end if
        for each it in m.libItems
            c = itemToContent(it, false)
            section.appendChild(c)
            m.flat.Push(c)
        end for
    end if
    if m.query <> "" and m.seerrItems.Count() > 0
        section = root.CreateChild("ContentNode")
        section.title = "Not in your library"
        for each r in m.seerrItems
            c = seerrToContent(r)
            section.appendChild(c)
            m.flat.Push(c)
        end for
    else if m.query <> "" and m.global.seerrState = "signedOut"
        section = root.CreateChild("ContentNode")
        section.title = "Not in your library"
        c = newContent()
        c.itemType = "seerr-signin"
        c.heading = "Sign in to Seerr to request titles"
        c.meta = "Opens a Quick Connect code"
        setCardSize(c, false)
        section.appendChild(c)
        m.flat.Push(c)
    end if

    q = Chr(34)
    if m.flat.Count() = 0
        m.grid.content = invalid
        m.grid.visible = false
        m.empty.visible = true
        m.empty.text = "No matches for " + q + m.query + q + ". Try fewer letters or a different word."
        if m.grid.isInFocusChain()
            m.area = "kb"
            m.kb.setFocus(true)
        end if
        showTip()
        return
    end if
    m.empty.visible = false
    m.grid.visible = true
    m.grid.content = root
    if m.area <> "grid" then showTip()
end sub

function itemAt(index as integer) as object
    if index < 0 or index >= m.flat.Count() then return invalid
    return m.flat[index]
end function

' The Info Line: name on top; year, type and Request Status below.
sub onItemFocused(event as object)
    if m.area <> "grid" then return
    c = itemAt(event.getData())
    if c = invalid then return
    m.infoTitle.text = c.heading
    meta = c.meta
    if c.badge <> ""
        if meta <> ""
            meta = c.badge + dot() + meta
        else
            meta = c.badge
        end if
    end if
    m.infoMeta.text = meta
end sub

sub onSelected(event as object)
    c = itemAt(event.getData())
    if c = invalid then return
    if c.itemType = "seerr-signin"
        m.top.navigate = { action: "seerrSignIn" }
    else if Left(c.itemType, 6) = "seerr-"
        m.top.navigate = { action: "seerrDetails", tmdbId: c.itemId, mediaType: Mid(c.itemType, 7) }
    else
        m.top.navigate = { action: "details", itemId: c.itemId }
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press or menuIsOpen() then return false
    if key = "right" and m.kb.isInFocusChain() and hasResults()
        m.area = "grid"
        m.grid.setFocus(true)
        c = itemAt(m.grid.itemFocused)
        if c <> invalid
            m.infoTitle.text = c.heading
            m.infoMeta.text = c.meta
        end if
        return true
    else if key = "left" and m.grid.isInFocusChain()
        m.area = "kb"
        m.kb.setFocus(true)
        showTip()
        return true
    else if key = "left" and m.kb.isInFocusChain() and th().navStyle = "rail"
        openMenu()
        return true
    else if key = "up" and th().navStyle = "top" and m.kb.isInFocusChain()
        openMenu()
        return true
    end if
    return false
end function
