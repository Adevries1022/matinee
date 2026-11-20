' Hero + Rows of Cards, with the main menu.
sub init()
    t = th()
    m.status = m.top.findNode("status")
    m.rows = m.top.findNode("rows")
    m.status.color = t.textDim
    m.status.translation = [t.leftPad, t.rowsTop + 60]
    m.status.width = 1700
    setupHero()
    styleRows(m.rows, t.rowsTop)

    m.rows.observeField("rowItemFocused", "onItemFocused")
    m.rows.observeField("rowItemSelected", "onItemSelected")
    m.top.observeField("focusedChild", "onFocusChanged")

    m.gen = 0
    m.views = []
    m.isLibrary = false
    m.seenVersion = m.global.watchVersion
    m.seenPrefs = m.global.prefsVersion
end sub

sub load()
    lib = m.top.library
    m.isLibrary = false
    if lib <> invalid
        if isValid(lib.id) then m.isLibrary = true
    end if
    key = "home"
    if m.isLibrary then key = "lib:" + lib.id
    setupMenu(key)
    m.status.text = "Loading..."
    m.status.visible = true
    apiRequest("/UserViews", { "userId": m.global.userId }, "onViews")
end sub

sub onViews(event as object)
    res = event.getData()
    views = []
    if res.ok and isValid(res.data)
        if isValid(res.data.Items)
            for each v in res.data.Items
                ct = safeStr(v.CollectionType)
                if ct = "movies" or ct = "tvshows"
                    views.Push({ id: safeStr(v.Id), name: safeStr(v.Name), collectionType: ct })
                end if
            end for
        end if
        m.global.views = views
    else if not res.ok
        m.status.text = "Couldn't reach your Jellyfin server (error " + res.code.ToStr() + ")."
        return
    end if
    m.views = views
    if m.isLibrary
        loadLibrary()
    else
        loadHome()
    end if
end sub

' ---------- Row definitions ----------

sub loadHome()
    uid = m.global.userId
    fields = "Overview,Genres"
    defs = []
    defs.Push({ title: "Continue Watching", path: "/UserItems/Resume", landscape: true, action: "play", query: { "userId": uid, "Limit": "24", "Fields": fields, "MediaTypes": "Video", "EnableTotalRecordCount": "false" } })
    defs.Push({ title: "Next Up", path: "/Shows/NextUp", landscape: true, action: "play", query: { "userId": uid, "Limit": "24", "Fields": fields, "EnableTotalRecordCount": "false" } })
    for each v in m.views
        defs.Push({ title: "New in " + v.name, path: "/Items/Latest", landscape: false, action: "details", query: { "userId": uid, "parentId": v.id, "Limit": "24", "Fields": fields } })
    end for
    defs.Push({ title: "Picked for You", path: "/Items", landscape: false, action: "details", query: { "userId": uid, "Recursive": "true", "IncludeItemTypes": "Movie,Series", "SortBy": "Random", "Limit": "24", "Fields": fields, "EnableTotalRecordCount": "false" } })
    defs.Push({ title: "Highly Rated", path: "/Items", landscape: false, action: "details", query: { "userId": uid, "Recursive": "true", "IncludeItemTypes": "Movie,Series", "SortBy": "CommunityRating", "SortOrder": "Descending", "Limit": "24", "Fields": fields, "EnableTotalRecordCount": "false" } })
    fetchRows(defs)
end sub

sub loadLibrary()
    lib = m.top.library
    m.libTypes = "Movie,Series"
    if lib.collectionType = "movies" then m.libTypes = "Movie"
    if lib.collectionType = "tvshows" then m.libTypes = "Series"
    apiRequest("/Genres", { "userId": m.global.userId, "parentId": lib.id, "SortBy": "SortName", "IncludeItemTypes": m.libTypes }, "onGenres")
end sub

function libQuery(extra as object) as object
    q = {
        "userId": m.global.userId,
        "parentId": m.top.library.id,
        "Recursive": "true",
        "IncludeItemTypes": m.libTypes,
        "Limit": "30",
        "Fields": "Overview,Genres",
        "EnableTotalRecordCount": "false"
    }
    q.Append(extra)
    return q
end function

sub onGenres(event as object)
    res = event.getData()
    defs = []
    defs.Push({ title: "Recently Added", path: "/Items", landscape: false, action: "details", query: libQuery({ "SortBy": "DateCreated", "SortOrder": "Descending" }) })
    defs.Push({ title: "Haven't Watched Yet", path: "/Items", landscape: false, action: "details", query: libQuery({ "Filters": "IsUnplayed", "SortBy": "Random" }) })
    if res.ok and isValid(res.data)
        if isValid(res.data.Items)
            n = 0
            for each g in res.data.Items
                if n < 18
                    defs.Push({ title: safeStr(g.Name), path: "/Items", landscape: false, action: "details", query: libQuery({ "GenreIds": safeStr(g.Id), "SortBy": "Random" }) })
                end if
                n = n + 1
            end for
        end if
    end if
    fetchRows(defs)
end sub

' ---------- Loading rows ----------

sub fetchRows(defs as object)
    m.gen = m.gen + 1
    m.rowDefs = defs
    m.rowResults = []
    for i = 0 to defs.Count() - 1
        m.rowResults.Push(invalid)
    end for
    m.pending = defs.Count()
    for i = 0 to defs.Count() - 1
        d = defs[i]
        apiRequest(d.path, d.query, "onRowData", "GET", invalid, m.gen * 1000 + i)
    end for
end sub

sub onRowData(event as object)
    res = event.getData()
    tag = res.tag
    if tag \ 1000 <> m.gen then return
    i = tag mod 1000
    items = []
    if res.ok and isValid(res.data)
        if type(res.data) = "roArray"
            items = res.data
        else if isValid(res.data.Items)
            items = res.data.Items
        end if
    end if
    m.rowResults[i] = items
    m.pending = m.pending - 1
    if m.pending <= 0 then buildRows()
end sub

sub buildRows()
    root = CreateObject("roSGNode", "ContentNode")
    sizes = []
    heights = []
    m.rowActions = []
    t = th()
    for i = 0 to m.rowDefs.Count() - 1
        items = m.rowResults[i]
        d = m.rowDefs[i]
        if items <> invalid
            if items.Count() > 0
                row = root.CreateChild("ContentNode")
                row.title = d.title
                for each it in items
                    row.appendChild(itemToContent(it, d.landscape))
                end for
                sizes.Push(cellSize(d.landscape))
                heights.Push(rowHeight(d.landscape))
                m.rowActions.Push(d.action)
            end if
        end if
    end for

    if root.getChildCount() = 0
        m.status.text = "Nothing here yet. Once Jellyfin has some movies or shows, they'll show up here."
        m.status.visible = true
        m.rows.visible = false
        return
    end if

    m.status.visible = false
    m.rows.rowItemSize = sizes
    m.rows.rowHeights = heights
    m.rows.content = root
    m.rows.visible = true
    if m.top.isInFocusChain() and not menuIsOpen() then m.rows.setFocus(true)
    first = root.getChild(0).getChild(0)
    heroShow(first, true)
    if not m.isLibrary then savePreview(root)
end sub

' A few Cards for the live preview in Settings.
sub savePreview(root as object)
    preview = []
    row = root.getChild(0)
    for i = 0 to row.getChildCount() - 1
        if preview.Count() < 6
            c = row.getChild(i)
            preview.Push({ heading: c.heading, meta: c.meta, backdrop: c.backdropUrl, image: c.HDPosterUrl, landscape: (c.cardW > c.cardH) })
        end if
    end for
    m.global.previewItems = preview
end sub

' ---------- Focus & selection ----------

sub onItemFocused(event as object)
    idx = event.getData()
    if idx = invalid or m.rows.content = invalid then return
    row = m.rows.content.getChild(idx[0])
    if row = invalid then return
    c = row.getChild(idx[1])
    if c = invalid then return
    m.focused = c
    heroShow(c)
end sub

sub onItemSelected(event as object)
    idx = event.getData()
    row = m.rows.content.getChild(idx[0])
    if row = invalid then return
    c = row.getChild(idx[1])
    if c = invalid then return
    openItem(c, m.rowActions[idx[0]])
end sub

sub openItem(c as object, action as string)
    if action = "play"
        m.top.navigate = { action: "play", itemId: c.itemId, startSeconds: c.resumeSeconds }
    else
        id = c.itemId
        if c.itemType = "Episode" and c.seriesId <> "" then id = c.seriesId
        m.top.navigate = { action: "details", itemId: id, seasonId: c.seasonId }
    end if
end sub

sub restoreContentFocus()
    if m.rows.content <> invalid and m.rows.visible
        m.rows.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() and not menuIsOpen()
        if m.rows.content <> invalid and m.rows.visible then m.rows.setFocus(true)
    end if
end sub

sub onRefresh()
    ' Appearance changed in Settings: rebuild with the new look.
    if m.global.prefsVersion <> m.seenPrefs
        m.seenPrefs = m.global.prefsVersion
        m.top.navigate = { action: "rebuildHome" }
        return
    end if
    if m.global.watchVersion <> m.seenVersion
        m.seenVersion = m.global.watchVersion
        if m.rowDefs <> invalid then fetchRows(m.rowDefs)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press or menuIsOpen() then return false
    if key = menuOpenKey()
        openMenu()
        return true
    else if key = "play"
        return toggleTrailerSound()
    else if key = "options"
        if m.focused <> invalid then openItem(m.focused, "details")
        return true
    else if key = "back" and not m.isLibrary
        ' Back from lower rows jumps to the top instead of exiting.
        f = m.rows.rowItemFocused
        if m.rows.content <> invalid and f <> invalid
            if f[0] > 0 or f[1] > 0
                m.rows.jumpToRowItem = [0, 0]
                return true
            end if
        end if
    end if
    return false
end function
