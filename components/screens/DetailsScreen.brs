' Movie or show details. Shows get a season picker and an episode row.
sub init()
    m.backdrop = m.top.findNode("backdrop")
    m.title = m.top.findNode("title")
    m.meta = m.top.findNode("meta")
    m.overview = m.top.findNode("overview")
    m.cast = m.top.findNode("cast")
    m.btnGroup = m.top.findNode("buttons")
    m.seasonBar = m.top.findNode("seasonBar")
    m.episodes = m.top.findNode("episodes")
    m.epInfo = m.top.findNode("epInfo")
    m.status = m.top.findNode("status")
    m.fadeIn = m.top.findNode("fadeIn")

    t = th()
    x = t.leftPad
    addBackdropShade(m.top.findNode("shadeLayer"), 760)
    setupTrailer(m.top, 1, 620)
    m.top.findNode("info").translation = [x, 110]
    m.title.color = t.text
    m.meta.color = t.textDim
    m.overview.color = t.textDim
    m.cast.color = t.textFaint
    m.btnGroup.translation = [x, 600]
    m.seasonBar.translation = [x, 700]
    m.episodes.translation = [x - t.cellPadX, 784 - t.cellPadY]
    m.episodes.itemSize = [t.contentWidth + t.cellPadX, t.landH + t.cellPadY * 2]
    m.episodes.rowItemSize = [cellSize(true)]
    m.episodes.rowItemSpacing = [[0, 0]]
    m.epInfo.translation = [x, 1020]
    m.epInfo.color = t.textDim
    if t.miniCards then m.epInfo.translation = [x, 990]
    m.status.translation = [x, 500]
    m.status.color = t.textDim
    m.episodes.observeField("rowItemSelected", "onEpisodeSelected")
    m.episodes.observeField("rowItemFocused", "onEpisodeFocused")
    m.backdrop.observeField("loadStatus", "onBackdropStatus")
    m.top.observeField("focusedChild", "onFocusChanged")

    m.area = "buttons"
    m.btnIndex = 0
    m.buttons = []
    m.btnNodes = []
    m.seasons = []
    m.seasonLabels = []
    m.seasonIndex = 0
    m.playTarget = invalid
    m.nextUpSeasonId = ""
    m.epGen = 0
    m.restoreEp = -1
    m.isSeries = false
    m.played = false
    m.item = invalid
    m.seenVersion = m.global.watchVersion
end sub

sub load()
    id = m.top.itemId
    if id = "" then return
    apiRequest("/Items/" + id, { "userId": m.global.userId, "Fields": "Overview,Genres,People" }, "onItem")
end sub

sub onItem(event as object)
    res = event.getData()
    if not res.ok or not isValid(res.data)
        m.status.text = "Couldn't load this title."
        m.status.visible = true
        return
    end if
    item = res.data

    ' Episodes open their show, on the right season.
    if safeStr(item.Type) = "Episode" and isValid(item.SeriesId)
        m.top.seasonId = safeStr(item.SeasonId)
        m.top.itemId = safeStr(item.SeriesId)
        return
    end if

    m.item = item
    m.status.visible = false
    m.title.text = safeStr(item.Name)
    m.meta.text = metaLine(item)
    m.overview.text = safeStr(item.Overview)

    m.cast.text = ""
    if isValid(item.People)
        names = []
        for each p in item.People
            if safeStr(p.Type) = "Actor" and names.Count() < 4 then names.Push(safeStr(p.Name))
        end for
        if names.Count() > 0 then m.cast.text = "Starring  " + names.Join(", ")
    end if

    if hasBackdrop(item)
        uri = imageUrl(safeStr(item.Id), "Backdrop", 1920)
        if uri <> m.backdrop.uri
            m.backdrop.opacity = 0
            m.backdrop.uri = uri
        end if
    end if

    m.isSeries = (safeStr(item.Type) = "Series")
    trailerScheduleId(safeStr(item.Id))
    m.played = false
    if isValid(item.UserData) then m.played = isTrue(item.UserData.Played)

    if m.isSeries
        m.playTarget = invalid
        m.nextUpSeasonId = ""
        apiRequest("/Shows/NextUp", { "userId": m.global.userId, "seriesId": safeStr(item.Id), "Limit": "1", "EnableTotalRecordCount": "false" }, "onNextUp")
    else
        resume = 0
        if isValid(item.UserData) then resume = ticksToSeconds(item.UserData.PlaybackPositionTicks)
        m.playTarget = { itemId: safeStr(item.Id), startSeconds: resume, code: "" }
    end if
    buildButtons()
    if m.top.isInFocusChain() then restoreFocus()
end sub

sub onBackdropStatus()
    if m.backdrop.loadStatus = "ready" then m.fadeIn.control = "start"
end sub

' ---------- Shows: next up, seasons, episodes ----------

sub onNextUp(event as object)
    res = event.getData()
    if res.ok and isValid(res.data)
        if isValid(res.data.Items)
            if res.data.Items.Count() > 0
                ep = res.data.Items[0]
                resume = 0
                if isValid(ep.UserData) then resume = ticksToSeconds(ep.UserData.PlaybackPositionTicks)
                m.playTarget = { itemId: safeStr(ep.Id), startSeconds: resume, code: epCode(ep) }
                m.nextUpSeasonId = safeStr(ep.SeasonId)
                buildButtons()
            end if
        end if
    end if
    apiRequest("/Shows/" + safeStr(m.item.Id) + "/Seasons", { "userId": m.global.userId }, "onSeasons")
end sub

sub onSeasons(event as object)
    res = event.getData()
    m.seasons = []
    if res.ok and isValid(res.data)
        if isValid(res.data.Items) then m.seasons = res.data.Items
    end if

    pref = m.top.seasonId
    if pref = "" then pref = m.nextUpSeasonId
    m.seasonIndex = 0
    for i = 0 to m.seasons.Count() - 1
        if safeStr(m.seasons[i].Id) = pref then m.seasonIndex = i
    end for

    m.seasonBar.removeChildrenIndex(m.seasonBar.getChildCount(), 0)
    m.seasonLabels = []
    x = 0
    for each season in m.seasons
        chip = makeChip(m.seasonBar, safeStr(season.Name))
        chip.group.translation = [x, 0]
        x = x + chip.width + 14
        m.seasonLabels.Push(chip)
    end for
    paintAll()
    loadEpisodes()
end sub

sub loadEpisodes()
    if m.seasons.Count() = 0 then return
    s = m.seasons[m.seasonIndex]
    m.top.seasonId = safeStr(s.Id)
    m.epGen = m.epGen + 1
    apiRequest("/Shows/" + safeStr(m.item.Id) + "/Episodes", { "userId": m.global.userId, "seasonId": safeStr(s.Id), "Fields": "Overview", "EnableTotalRecordCount": "false" }, "onEpisodes", "GET", invalid, m.epGen)
end sub

sub onEpisodes(event as object)
    res = event.getData()
    if res.tag <> m.epGen then return
    items = []
    if res.ok and isValid(res.data)
        if isValid(res.data.Items) then items = res.data.Items
    end if

    root = CreateObject("roSGNode", "ContentNode")
    row = root.CreateChild("ContentNode")
    targetIndex = -1
    for i = 0 to items.Count() - 1
        ep = items[i]
        c = itemToContent(ep, true)
        num = ""
        if isValid(ep.IndexNumber) then num = ep.IndexNumber.ToStr() + ".  "
        c.heading = num + safeStr(ep.Name)
        row.appendChild(c)
        if m.playTarget <> invalid
            if safeStr(ep.Id) = m.playTarget.itemId then targetIndex = i
        end if
    end for

    m.episodes.content = root
    m.episodes.visible = items.Count() > 0
    m.epInfo.text = ""

    if m.playTarget = invalid and items.Count() > 0
        first = items[0]
        m.playTarget = { itemId: safeStr(first.Id), startSeconds: 0, code: epCode(first) }
        buildButtons()
    end if

    if items.Count() > 0
        jump = 0
        if m.restoreEp >= 0
            jump = m.restoreEp
            if jump > items.Count() - 1 then jump = items.Count() - 1
            m.restoreEp = -1
        else if targetIndex >= 0
            jump = targetIndex
        end if
        m.episodes.jumpToRowItem = [0, jump]
    end if

    if m.area = "episodes"
        if items.Count() = 0 then m.area = "seasons"
        if m.top.isInFocusChain() then restoreFocus()
        paintAll()
    end if
end sub

sub onEpisodeFocused(event as object)
    idx = event.getData()
    if m.episodes.content = invalid then return
    row = m.episodes.content.getChild(0)
    if row = invalid then return
    c = row.getChild(idx[1])
    if c = invalid then return
    text = c.subtitle
    if c.description <> "" then text = text + "   " + Chr(8212) + "   " + c.description
    m.epInfo.text = text
end sub

sub onEpisodeSelected(event as object)
    idx = event.getData()
    row = m.episodes.content.getChild(0)
    c = row.getChild(idx[1])
    if c = invalid then return
    m.restoreEp = idx[1]
    m.top.navigate = { action: "play", itemId: c.itemId, startSeconds: c.resumeSeconds }
end sub

' ---------- Buttons ----------

sub buildButtons()
    m.buttons = []
    t = m.playTarget
    if m.isSeries
        lbl = "Play"
        if t <> invalid
            if t.startSeconds > 0
                lbl = "Resume"
            end if
            if t.code <> "" then lbl = lbl + " " + t.code
        end if
        m.buttons.Push({ label: lbl, action: "play" })
    else
        resume = 0
        if t <> invalid then resume = t.startSeconds
        if resume > 0
            m.buttons.Push({ label: "Resume from " + formatClock(resume), action: "play" })
            m.buttons.Push({ label: "Play from Start", action: "start" })
        else
            m.buttons.Push({ label: "Play", action: "play" })
        end if
    end if
    if m.played
        m.buttons.Push({ label: "Watched", action: "unwatch" })
    else
        m.buttons.Push({ label: "Mark as Watched", action: "watch" })
    end if
    renderButtons()
end sub

sub renderButtons()
    m.btnGroup.removeChildrenIndex(m.btnGroup.getChildCount(), 0)
    m.btnNodes = []
    x = 0
    for each b in m.buttons
        btn = makeButton(m.btnGroup, b.label, 180)
        btn.group.translation = [x, 0]
        m.btnNodes.Push(btn)
        x = x + btn.width + 20
    end for
    if m.btnIndex >= m.buttons.Count() then m.btnIndex = 0
    paintAll()
end sub

sub paintAll()
    t = th()
    for i = 0 to m.btnNodes.Count() - 1
        paintButton(m.btnNodes[i], m.area = "buttons" and i = m.btnIndex)
    end for
    for i = 0 to m.seasonLabels.Count() - 1
        chip = m.seasonLabels[i]
        if i = m.seasonIndex and m.area = "seasons"
            chip.bg.blendColor = "0xFFFFFFFF"
            chip.bg.opacity = 1.0
            chip.label.color = "0x0B0B0FFF"
        else if i = m.seasonIndex
            chip.bg.blendColor = t.surface
            chip.bg.opacity = t.surfaceHiOpacity
            chip.label.color = t.text
        else
            chip.bg.opacity = 0
            chip.label.color = t.textFaint
        end if
    end for
end sub

sub doButton()
    if m.buttons.Count() = 0 then return
    b = m.buttons[m.btnIndex]
    t = m.playTarget
    if b.action = "play"
        if t <> invalid then m.top.navigate = { action: "play", itemId: t.itemId, startSeconds: t.startSeconds }
    else if b.action = "start"
        if t <> invalid then m.top.navigate = { action: "play", itemId: t.itemId, startSeconds: 0 }
    else if b.action = "watch"
        apiRequest("/UserPlayedItems/" + safeStr(m.item.Id), { "userId": m.global.userId }, "onPlayedChanged", "POST")
    else if b.action = "unwatch"
        apiRequest("/UserPlayedItems/" + safeStr(m.item.Id), { "userId": m.global.userId }, "onPlayedChanged", "DELETE")
    end if
end sub

sub onPlayedChanged(event as object)
    m.global.watchVersion = m.global.watchVersion + 1
    m.seenVersion = m.global.watchVersion
    reloadKeepingPlace()
end sub

sub reloadKeepingPlace()
    if m.isSeries and m.episodes.content <> invalid
        f = m.episodes.rowItemFocused
        if f <> invalid then m.restoreEp = f[1]
    end if
    load()
end sub

sub onRefresh()
    if m.global.watchVersion <> m.seenVersion
        m.seenVersion = m.global.watchVersion
        reloadKeepingPlace()
    end if
end sub

' ---------- Focus & keys ----------

sub restoreFocus()
    if m.area = "episodes" and m.episodes.visible
        m.episodes.setFocus(true)
    else if not m.top.hasFocus()
        m.top.setFocus(true)
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then restoreFocus()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if m.area = "buttons"
        if key = "left"
            if m.btnIndex > 0 then m.btnIndex = m.btnIndex - 1
            paintAll()
            return true
        else if key = "right"
            if m.btnIndex < m.buttons.Count() - 1 then m.btnIndex = m.btnIndex + 1
            paintAll()
            return true
        else if key = "OK" or key = "play"
            ' Play turns the Trailer Preview's sound on and off while it runs.
            if key = "play"
                if toggleTrailerSound() then return true
            end if
            doButton()
            return true
        else if key = "down"
            if m.isSeries and m.seasons.Count() > 0
                m.area = "seasons"
                paintAll()
            end if
            return true
        else if key = "up"
            return true
        end if
    else if m.area = "seasons"
        if key = "left"
            if m.seasonIndex > 0
                m.seasonIndex = m.seasonIndex - 1
                paintAll()
                loadEpisodes()
            end if
            return true
        else if key = "right"
            if m.seasonIndex < m.seasons.Count() - 1
                m.seasonIndex = m.seasonIndex + 1
                paintAll()
                loadEpisodes()
            end if
            return true
        else if key = "up"
            m.area = "buttons"
            paintAll()
            return true
        else if key = "down" or key = "OK"
            if m.episodes.visible
                m.area = "episodes"
                paintAll()
                m.episodes.setFocus(true)
            end if
            return true
        end if
    else if m.area = "episodes"
        if key = "up"
            m.area = "seasons"
            paintAll()
            m.top.setFocus(true)
            return true
        end if
    end if
    return false
end function
