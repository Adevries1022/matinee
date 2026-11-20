sub init()
    t = th()
    m.backdrop = m.top.findNode("backdrop")
    m.fadeIn = m.top.findNode("fadeIn")
    m.title = m.top.findNode("title")
    m.meta = m.top.findNode("meta")
    m.overview = m.top.findNode("overview")
    m.statusLine = m.top.findNode("statusLine")
    m.btnGroup = m.top.findNode("buttons")
    m.toast = m.top.findNode("toast")
    m.picker = m.top.findNode("picker")
    addBackdropShade(m.top.findNode("shadeLayer"), 900)
    x = t.leftPad
    m.top.findNode("info").translation = [x, 140]
    m.title.color = t.text
    m.meta.color = t.textDim
    m.overview.color = t.textDim
    m.statusLine.color = t.accent
    m.btnGroup.translation = [x, 700]
    m.toast.translation = [x, 800]
    m.toast.color = t.textDim
    m.title.text = "Loading..."
    m.backdrop.observeField("loadStatus", "onBackdropStatus")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.buttons = []
    m.btnNodes = []
    m.btnIndex = 0
    m.pickerOpen = false
    m.seasons = []
    m.details = invalid
end sub

sub load()
    md = m.top.media
    m.tmdbId = safeStr(md.tmdbId)
    m.mediaType = safeStr(md.mediaType)
    path = "/movie/" + m.tmdbId
    if m.mediaType = "tv" then path = "/tv/" + m.tmdbId
    seerrRequest(path, {}, "onDetails")
end sub

sub onBackdropStatus()
    if m.backdrop.loadStatus = "ready"
        if th().reduceMotion
            m.backdrop.opacity = 1
        else
            m.fadeIn.control = "start"
        end if
    end if
end sub

sub onDetails(event as object)
    res = event.getData()
    if not res.ok or not isValid(res.data)
        if res.code = 401 or res.code = 403 then m.top.navigate = { action: "seerrSignedOut" }
        m.title.text = "Couldn't load this title from Seerr."
        return
    end if
    d = res.data
    m.details = d
    name = safeStr(d.title)
    if name = "" then name = safeStr(d.name)
    m.title.text = name

    parts = []
    dateStr = safeStr(d.releaseDate)
    if dateStr = "" then dateStr = safeStr(d.firstAirDate)
    if Len(dateStr) >= 4 then parts.Push(Left(dateStr, 4))
    if m.mediaType = "tv"
        n = safeInt(d.numberOfSeasons)
        if n = 1 then parts.Push("1 season")
        if n > 1 then parts.Push(n.ToStr() + " seasons")
    else if safeInt(d.runtime) > 0
        mins = safeInt(d.runtime)
        if mins >= 60
            parts.Push((mins \ 60).ToStr() + "h " + (mins mod 60).ToStr() + "m")
        else
            parts.Push(mins.ToStr() + "m")
        end if
    end if
    rt = ratingText(d.voteAverage)
    if rt <> "" then parts.Push(rt)
    if isValid(d.genres)
        k = 0
        for each g in d.genres
            if k < 2 then parts.Push(safeStr(g.name))
            k = k + 1
        end for
    end if
    m.meta.text = parts.Join(dot())
    m.overview.text = safeStr(d.overview)

    uri = tmdbImage(d.backdropPath, "w1280")
    if uri <> m.backdrop.uri
        m.backdrop.opacity = 0
        m.backdrop.uri = uri
    end if

    m.status = 0
    m.jellyfinId = ""
    seasonStatus = {}
    mi = d.mediaInfo
    if isValid(mi)
        m.status = safeInt(mi.status)
        m.jellyfinId = safeStr(mi.jellyfinMediaId)
        if isValid(mi.seasons)
            for each ss in mi.seasons
                seasonStatus[safeInt(ss.seasonNumber).ToStr()] = safeInt(ss.status)
            end for
        end if
    end if
    ' Seasons already requested or downloaded can't be picked again.
    if isValid(d.requests)
        for each rq in d.requests
            if isValid(rq.seasons)
                for each rs in rq.seasons
                    key = safeInt(rs.seasonNumber).ToStr()
                    if not seasonStatus.DoesExist(key) then seasonStatus[key] = 2
                end for
            end if
        end for
    end if

    m.seasons = []
    if m.mediaType = "tv" and isValid(d.seasons)
        for each s in d.seasons
            num = safeInt(s.seasonNumber)
            if num > 0
                st = 0
                if seasonStatus.DoesExist(num.ToStr()) then st = seasonStatus[num.ToStr()]
                m.seasons.Push({ number: num, name: safeStr(s.name), episodes: safeInt(s.episodeCount), status: st, selected: false })
            end if
        end for
    end if

    label = requestStatusLabel(m.status)
    if label = "Requested" then label = "Requested, waiting for approval"
    m.statusLine.text = label
    buildButtons()
end sub

function openSeasons() as object
    open = []
    for each s in m.seasons
        if s.status < 2 then open.Push(s.number)
    end for
    return open
end function

sub buildButtons()
    m.buttons = []
    st = m.status
    if m.jellyfinId <> "" and (st = 5 or st = 4)
        m.buttons.Push({ label: "Watch in Matinee", action: "open" })
    end if
    if m.mediaType = "tv"
        remaining = openSeasons()
        if st < 2 or st = 6
            m.buttons.Push({ label: "Request all seasons", action: "requestAll" })
            m.buttons.Push({ label: "Choose seasons", action: "pick" })
        else if remaining.Count() > 0
            m.buttons.Push({ label: "Request remaining seasons", action: "requestRemaining" })
            m.buttons.Push({ label: "Choose seasons", action: "pick" })
        end if
    else if st < 2 or st = 6
        m.buttons.Push({ label: "Request", action: "requestMovie" })
    end if
    if m.buttons.Count() = 0
        m.buttons.Push({ label: "Back", action: "back" })
    end if

    m.btnGroup.removeChildrenIndex(m.btnGroup.getChildCount(), 0)
    m.btnNodes = []
    x = 0
    for each b in m.buttons
        btn = makeButton(m.btnGroup, b.label, 200)
        btn.group.translation = [x, 0]
        m.btnNodes.Push(btn)
        x = x + btn.width + 20
    end for
    m.btnIndex = 0
    paint()
end sub

sub paint()
    for i = 0 to m.btnNodes.Count() - 1
        paintButton(m.btnNodes[i], (not m.pickerOpen) and i = m.btnIndex)
    end for
end sub

sub doButton()
    if m.buttons.Count() = 0 then return
    a = m.buttons[m.btnIndex].action
    if a = "open"
        m.top.navigate = { action: "details", itemId: m.jellyfinId }
    else if a = "requestMovie"
        sendRequest({ "mediaType": "movie", "mediaId": m.tmdbId.ToInt() })
    else if a = "requestAll"
        sendRequest({ "mediaType": "tv", "mediaId": m.tmdbId.ToInt(), "seasons": "all" })
    else if a = "requestRemaining"
        sendRequest({ "mediaType": "tv", "mediaId": m.tmdbId.ToInt(), "seasons": openSeasons() })
    else if a = "pick"
        openPicker()
    else if a = "back"
        m.top.navigate = { action: "back" }
    end if
end sub

sub sendRequest(body as object)
    m.toast.text = "Sending your request..."
    seerrRequest("/request", {}, "onRequested", "POST", body)
end sub

sub onRequested(event as object)
    res = event.getData()
    if res.ok
        m.toast.text = "Requested. It'll show up in your library once it's ready."
        m.global.watchVersion = m.global.watchVersion + 1
        load()
    else if res.code = 403
        m.toast.text = "Your Seerr account isn't allowed to request this. Ask an administrator."
    else if res.code = 409
        m.toast.text = "Someone has already requested this."
        load()
    else if res.code = 401
        m.top.navigate = { action: "seerrSignedOut" }
        m.toast.text = "Your Seerr sign-in expired. Sign in again from Discover."
    else
        m.toast.text = "The request didn't go through (error " + res.code.ToStr() + ")."
    end if
end sub

' ---------- Season picker ----------

sub openPicker()
    if m.seasons.Count() = 0 then return
    for each s in m.seasons
        s.selected = false
    end for
    m.pickIndex = 0
    m.pickerOpen = true
    drawPicker()
    m.picker.visible = true
    paint()
end sub

sub closePicker()
    m.pickerOpen = false
    m.picker.visible = false
    paint()
end sub

function selectedSeasons() as object
    out = []
    for each s in m.seasons
        if s.selected then out.Push(s.number)
    end for
    return out
end function

sub drawPicker()
    t = th()
    p = m.picker
    p.removeChildrenIndex(p.getChildCount(), 0)
    veil = p.CreateChild("Rectangle")
    veil.width = 1920
    veil.height = 1080
    veil.color = t.bg
    veil.opacity = 0.6
    panelX = 1920 - 720
    panel = p.CreateChild("Rectangle")
    panel.translation = [panelX, 0]
    panel.width = 720
    panel.height = 1080
    panel.color = t.bg
    panel.opacity = 0.96
    head = makeLabel(p, "Choose seasons", 44, true, t.text)
    head.translation = [panelX + 60, 80]

    m.pickRows = []
    maxRows = 9
    first = 0
    if m.pickIndex >= maxRows then first = m.pickIndex - maxRows + 1
    total = m.seasons.Count() + 1
    for i = first to total - 1
        if i - first < maxRows + 1
            y = 180 + (i - first) * 84
            focused = (i = m.pickIndex)
            if focused
                hl = makeShape(p, t.pillUri, 600, 72, "0xFFFFFFFF", 1.0)
                hl.translation = [panelX + 40, y]
            end if
            textColor = t.text
            if focused then textColor = "0x0B0B0FFF"
            if i < m.seasons.Count()
                s = m.seasons[i]
                chk = makeShape(p, t.fillUri, 34, 34, t.surface, 0.25)
                chk.translation = [panelX + 64, y + 19]
                if s.selected
                    chk.blendColor = t.accent
                    chk.opacity = 1.0
                    tick = p.CreateChild("Poster")
                    tick.uri = "pkg:/images/check.png"
                    tick.width = 30
                    tick.height = 30
                    tick.translation = [panelX + 66, y + 21]
                    tick.blendColor = t.onAccent
                end if
                text = s.name
                if s.episodes > 0 then text = text + "  (" + s.episodes.ToStr() + " episodes)"
                if s.status >= 2
                    text = s.name + "  " + Chr(8212) + "  " + requestStatusLabel(s.status)
                    chk.opacity = 0.08
                end if
                lbl = makeLabel(p, text, 30, true, textColor)
                lbl.translation = [panelX + 120, y]
                lbl.height = 72
                lbl.width = 500
                lbl.vertAlign = "center"
                if s.status >= 2 and not focused then lbl.color = t.textFaint
            else
                n = selectedSeasons().Count()
                text = "Pick at least one season"
                if n = 1 then text = "Request 1 season"
                if n > 1 then text = "Request " + n.ToStr() + " seasons"
                lbl = makeLabel(p, text, 30, true, textColor)
                lbl.translation = [panelX + 64, y]
                lbl.height = 72
                lbl.width = 540
                lbl.vertAlign = "center"
                if not focused then lbl.color = t.accent
            end if
        end if
    end for
    tip = makeLabel(p, "OK selects. Back closes.", 24, false, t.textFaint)
    tip.translation = [panelX + 60, 1010]
end sub

function pickerKey(key as string) as boolean
    total = m.seasons.Count() + 1
    if key = "up"
        if m.pickIndex > 0 then m.pickIndex = m.pickIndex - 1
    else if key = "down"
        if m.pickIndex < total - 1 then m.pickIndex = m.pickIndex + 1
    else if key = "OK"
        if m.pickIndex < m.seasons.Count()
            s = m.seasons[m.pickIndex]
            if s.status < 2 then s.selected = not s.selected
        else
            chosen = selectedSeasons()
            if chosen.Count() > 0
                closePicker()
                sendRequest({ "mediaType": "tv", "mediaId": m.tmdbId.ToInt(), "seasons": chosen })
                return true
            end if
        end if
    else if key = "back"
        closePicker()
        return true
    end if
    drawPicker()
    return true
end function

' ---------- Keys ----------

sub onFocusChanged()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if m.pickerOpen then return pickerKey(key)
    if key = "left"
        if m.btnIndex > 0 then m.btnIndex = m.btnIndex - 1
        paint()
        return true
    else if key = "right"
        if m.btnIndex < m.buttons.Count() - 1 then m.btnIndex = m.btnIndex + 1
        paint()
        return true
    else if key = "OK" or key = "play"
        doButton()
        return true
    end if
    return false
end function
