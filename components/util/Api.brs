' Shared helpers for render-thread components. Included by every screen.
' Saved data lives in the registry section "Marquee" (the app's working
' name) so sign-ins from earlier versions keep working after the rename.

' ================= Network =================

function authHeader() as string
    q = Chr(34)
    h = "MediaBrowser Client=" + q + "Matinee" + q + ", Device=" + q + "Roku" + q
    h = h + ", DeviceId=" + q + m.global.deviceId + q + ", Version=" + q + "2.2.0" + q
    if m.global.token <> ""
        h = h + ", Token=" + q + m.global.token + q
    end if
    return h
end function

' Jellyfin request. The callback receives an event whose data is
' { ok, code, data, error, tag, cookie }.
sub apiRequest(path as string, query as object, callback as string, method = "GET" as string, body = invalid as dynamic, tag = invalid as dynamic)
    startRequest(m.global.serverUrl, path, query, callback, method, body, tag, authHeader(), {})
end sub

' Seerr request, authenticated with this User's Seerr session cookie.
sub seerrRequest(path as string, query as object, callback as string, method = "GET" as string, body = invalid as dynamic, tag = invalid as dynamic)
    headers = {}
    if m.global.seerrCookie <> "" then headers["Cookie"] = m.global.seerrCookie
    startRequest(m.global.seerrUrl + "/api/v1", path, query, callback, method, body, tag, "", headers)
end sub

sub startRequest(base as string, path as string, query as object, callback as string, method as string, body as dynamic, tag as dynamic, auth as string, headers as object)
    task = CreateObject("roSGNode", "ApiTask")
    bodyJson = ""
    if body <> invalid then bodyJson = FormatJson(body)
    task.request = {
        path: path,
        query: query,
        method: method,
        bodyJson: bodyJson,
        tag: tag,
        server: base,
        auth: auth,
        headers: headers
    }
    task.observeField("response", callback)
    task.control = "RUN"
    if m.apiTasks = invalid then m.apiTasks = []
    m.apiTasks.Push(task)
    if m.apiTasks.Count() > 48 then m.apiTasks.Shift()
end sub

sub onIgnore(event as object)
end sub

' ================= Values =================

function isValid(v as dynamic) as boolean
    t = type(v)
    return not (t = "Invalid" or t = "roInvalid" or t = "<uninitialized>")
end function

function isTrue(v as dynamic) as boolean
    t = type(v)
    if t = "Boolean" or t = "roBoolean" then return v
    return false
end function

function safeStr(v as dynamic) as string
    if not isValid(v) then return ""
    t = type(v)
    if t = "String" or t = "roString" then return v
    return v.ToStr()
end function

function safeInt(v as dynamic) as integer
    if not isValid(v) then return 0
    t = type(v)
    if t = "String" or t = "roString" then return v.ToInt()
    return Int(v)
end function

' ================= Theme =================

function th() as object
    return m.global.theme
end function

function accentColors() as object
    return {
        amber: "0xE8A33DFF",
        red: "0xE5484DFF",
        teal: "0x2EC4B6FF",
        violet: "0xA78BFAFF",
        blue: "0x5B9BFFFF",
        white: "0xFFFFFFFF"
    }
end function

function defaultPrefs() as object
    return {
        theme: "midnight",
        accent: "",
        bigHero: false,
        miniCards: false,
        navStyle: "rail",
        reduceMotion: false
    }
end function

' Every color, shape and size the screens use comes from here.
function themeTokens(prefs as object) as object
    name = safeStr(prefs.theme)
    if name = "void"
        t = {
            name: "void", label: "Void",
            bg: "0x000000FF", text: "0xFFFFFFFF", textDim: "0xA8A8B0FF", textFaint: "0x66666EFF",
            surface: "0xFFFFFFFF", surfaceOpacity: 0.07, surfaceHiOpacity: 0.16,
            accent: "0xFFFFFFFF", shape: "square", frosted: false, cardFocusScale: 1.05, focusWithAccent: false
        }
    else if name = "classic"
        t = {
            name: "classic", label: "Amber",
            bg: "0x0B0B0FFF", text: "0xFFFFFFFF", textDim: "0xC9C9D1FF", textFaint: "0x8E8E99FF",
            surface: "0xFFFFFFFF", surfaceOpacity: 0.10, surfaceHiOpacity: 0.20,
            accent: "0xE8A33DFF", shape: "square", frosted: false, cardFocusScale: 1.05, focusWithAccent: false
        }
    else
        t = {
            name: "midnight", label: "Midnight Glass",
            bg: "0x000000FF", text: "0xFFFFFFFF", textDim: "0xB9B9C6FF", textFaint: "0x70707CFF",
            surface: "0xFFFFFFFF", surfaceOpacity: 0.08, surfaceHiOpacity: 0.17,
            accent: "0xA78BFAFF", shape: "round", frosted: true, cardFocusScale: 1.06, focusWithAccent: true
        }
    end if

    accent = safeStr(prefs.accent)
    colors = accentColors()
    if accent <> "" and colors.DoesExist(accent) then t.accent = colors[accent]
    t.onAccent = "0x0B0B0FFF"

    t.focusColor = "0xFFFFFFFF"
    if t.focusWithAccent then t.focusColor = t.accent

    if t.shape = "round"
        t.fillUri = "pkg:/images/fill_round.9.png"
        t.pillUri = "pkg:/images/pill.9.png"
        t.ringUri = "pkg:/images/ring_round.9.png"
        t.cornerUri = "pkg:/images/corners_round.9.png"
        t.ringInset = 2   ' transparent margin around the stroke in ring_round.9.png
    else
        t.fillUri = "pkg:/images/fill_square.9.png"
        t.pillUri = "pkg:/images/fill_square.9.png"
        t.ringUri = "pkg:/images/ring_square.9.png"
        t.cornerUri = ""
        t.ringInset = 0
    end if
    ' The focus ring: its stroke width in the ring images, and the gap between it and the Card.
    t.ringStroke = 4
    t.ringGap = 3

    ' Layout Add-ons, Navigation Style and Reduce Motion
    t.reduceMotion = isTrue(prefs.reduceMotion)
    t.bigHero = isTrue(prefs.bigHero)
    t.miniCards = isTrue(prefs.miniCards)
    t.navStyle = "rail"
    if safeStr(prefs.navStyle) = "top" then t.navStyle = "top"
    if t.reduceMotion then t.cardFocusScale = 1.0

    if t.navStyle = "rail"
        t.leftPad = 160
        t.heroTop = 120
    else
        t.leftPad = 96
        t.heroTop = 165
    end if
    t.contentWidth = 1920 - t.leftPad
    ' Each Card sits in a padded cell so it can grow from its centre
    ' without being clipped. Cells touch, so the visible gap is 2 x pad.
    t.cellPadX = 20
    t.cellPadY = 20

    if t.miniCards
        t.posterW = 160
        t.posterH = 240
        t.landW = 320
        t.landH = 180
    else
        t.posterW = 220
        t.posterH = 330
        t.landW = 400
        t.landH = 225
    end if

    if t.bigHero
        t.rowsTop = 700
    else
        t.rowsTop = 560
    end if
    return t
end function

' Apply a User's preferences: updates the theme everyone reads.
sub applyPrefs(prefs as object)
    full = defaultPrefs()
    if prefs <> invalid then full.Append(prefs)
    m.global.prefs = full
    m.global.theme = themeTokens(full)
    m.global.prefsVersion = m.global.prefsVersion + 1
end sub

function readPrefs(userId as string) as object
    reg = CreateObject("roRegistrySection", "Marquee")
    key = "prefs_" + userId
    p = defaultPrefs()
    if userId <> "" and reg.Exists(key)
        saved = ParseJson(reg.Read(key))
        if saved <> invalid then p.Append(saved)
    end if
    return p
end function

sub savePrefs(prefs as object)
    reg = CreateObject("roRegistrySection", "Marquee")
    reg.Write("prefs_" + m.global.userId, FormatJson(prefs))
    reg.Flush()
end sub

' ================= Drawing =================

function makeFont(size as integer, bold = false as boolean) as object
    f = CreateObject("roSGNode", "Font")
    if bold
        f.uri = "font:BoldSystemFontFile"
    else
        f.uri = "font:SystemFontFile"
    end if
    f.size = size
    return f
end function

function makeLabel(parent as object, text as string, size as integer, bold as boolean, color as string) as object
    l = parent.CreateChild("Label")
    l.font = makeFont(size, bold)
    l.text = text
    l.color = color
    return l
end function

' A tinted shape from one of the white 9-patch images.
function makeShape(parent as object, uri as string, w as float, h as float, color as string, opacity = 1.0 as float) as object
    p = parent.CreateChild("Poster")
    p.uri = uri
    p.width = w
    p.height = h
    p.blendColor = color
    p.opacity = opacity
    return p
end function

' A themed button: { group, bg, label, width }
function makeButton(parent as object, text as string, minWidth = 0 as integer) as object
    t = th()
    g = parent.CreateChild("Group")
    w = measureText(text, 30, true) + 96
    if w < minWidth then w = minWidth
    bg = makeShape(g, t.pillUri, w, 72, t.surface, t.surfaceHiOpacity)
    l = g.CreateChild("Label")
    l.font = makeFont(30, true)
    l.text = text
    l.width = w
    l.height = 72
    l.horizAlign = "center"
    l.vertAlign = "center"
    l.color = t.text
    return { group: g, bg: bg, label: l, width: w }
end function

sub paintButton(b as object, focused as boolean)
    t = th()
    if focused
        b.bg.blendColor = "0xFFFFFFFF"
        b.bg.opacity = 1.0
        b.label.color = "0x0B0B0FFF"
    else
        b.bg.blendColor = t.surface
        b.bg.opacity = t.surfaceHiOpacity
        b.label.color = t.text
    end if
end sub

' Hero/backdrop shading tinted to the Theme background: dark on the
' left for text, solid below "solidFrom" so Cards sit on a clean base.
sub addBackdropShade(parent as object, solidFrom as integer)
    t = th()
    leftShade = parent.CreateChild("Poster")
    leftShade.uri = "pkg:/images/grad_left.png"
    leftShade.width = 1300
    leftShade.height = 1080
    leftShade.loadDisplayMode = "scaleToFill"
    leftShade.blendColor = t.bg
    leftShade.opacity = 0.96
    fade = parent.CreateChild("Poster")
    fade.uri = "pkg:/images/grad_up.png"
    fade.translation = [0, solidFrom - 300]
    fade.width = 1920
    fade.height = 300
    fade.loadDisplayMode = "scaleToFill"
    fade.blendColor = t.bg
    solid = parent.CreateChild("Rectangle")
    solid.translation = [0, solidFrom]
    solid.width = 1920
    solid.height = 1080 - solidFrom
    solid.color = t.bg
    veil = parent.CreateChild("Rectangle")
    veil.width = 1920
    veil.height = solidFrom
    veil.color = t.bg
    veil.opacity = 0.2
end sub

' ================= Jellyfin data =================

function imageUrl(itemId as string, imgType as string, width as integer) as string
    return m.global.serverUrl + "/Items/" + itemId + "/Images/" + imgType + "?fillWidth=" + width.ToStr() + "&quality=85"
end function

' A soft, pre-blurred copy of a backdrop for frosted panels.
function blurredUrl(sharpUrl as string) as string
    if sharpUrl = "" then return ""
    if Left(sharpUrl, 8) = "https://" and Instr(1, sharpUrl, "image.tmdb.org") > 0
        return sharpUrl.Replace("/w1280/", "/w300/")
    end if
    return sharpUrl.Replace("fillWidth=1920", "fillWidth=320") + "&blur=24"
end function

function imageTag(item as object, name as string) as string
    tags = item.ImageTags
    if not isValid(tags) then return ""
    return safeStr(tags[name])
end function

function hasBackdrop(item as object) as boolean
    bt = item.BackdropImageTags
    if not isValid(bt) then return false
    return bt.Count() > 0
end function

function ticksToSeconds(t as dynamic) as integer
    if not isValid(t) then return 0
    return Int(t / 10000000)
end function

function formatRuntime(ticks as dynamic) as string
    mins = ticksToSeconds(ticks) \ 60
    if mins <= 0 then return ""
    if mins < 60 then return mins.ToStr() + "m"
    return (mins \ 60).ToStr() + "h " + (mins mod 60).ToStr() + "m"
end function

function pad2(n as integer) as string
    if n < 10 then return "0" + n.ToStr()
    return n.ToStr()
end function

function formatClock(secs as integer) as string
    h = secs \ 3600
    mnt = (secs mod 3600) \ 60
    sec = secs mod 60
    if h > 0 then return h.ToStr() + ":" + pad2(mnt) + ":" + pad2(sec)
    return mnt.ToStr() + ":" + pad2(sec)
end function

function epCode(item as object) as string
    if isValid(item.ParentIndexNumber) and isValid(item.IndexNumber)
        return "S" + item.ParentIndexNumber.ToStr() + ":E" + item.IndexNumber.ToStr()
    end if
    return ""
end function

function episodeLabel(item as object) as string
    code = epCode(item)
    if code <> "" then return code + "  " + safeStr(item.Name)
    return safeStr(item.Name)
end function

function dot() as string
    return "   " + Chr(8226) + "   "
end function

function ratingText(r as dynamic) as string
    if not isValid(r) then return ""
    x = Int(r * 10 + 0.5)
    if x <= 0 then return ""
    return (x \ 10).ToStr() + "." + (x mod 10).ToStr() + " / 10"
end function

function metaLine(item as object) as string
    parts = []
    if isValid(item.ProductionYear) then parts.Push(item.ProductionYear.ToStr())
    if isValid(item.OfficialRating) then parts.Push(safeStr(item.OfficialRating))
    if safeStr(item.Type) <> "Series" and isValid(item.RunTimeTicks)
        r = formatRuntime(item.RunTimeTicks)
        if r <> "" then parts.Push(r)
    end if
    rt = ratingText(item.CommunityRating)
    if rt <> "" then parts.Push(rt)
    if isValid(item.Genres)
        n = 0
        for each g in item.Genres
            if n < 2 then parts.Push(safeStr(g))
            n = n + 1
        end for
    end if
    return parts.Join(dot())
end function

function newContent() as object
    return CreateObject("roSGNode", "MediaContent")
end function

sub setCardSize(c as object, landscape as boolean)
    t = th()
    if landscape
        c.cardW = t.landW
        c.cardH = t.landH
    else
        c.cardW = t.posterW
        c.cardH = t.posterH
    end if
end sub

' Convert a Jellyfin item into a Card.
function itemToContent(item as object, landscape as boolean) as object
    c = newContent()
    id = safeStr(item.Id)
    c.itemId = id
    c.itemType = safeStr(item.Type)
    c.seriesId = safeStr(item.SeriesId)
    c.seasonId = safeStr(item.SeasonId)
    if c.itemType = "Episode"
        c.heading = safeStr(item.SeriesName)
        c.subtitle = episodeLabel(item)
    else
        c.heading = safeStr(item.Name)
    end if
    c.title = c.heading
    c.description = safeStr(item.Overview)
    c.meta = metaLine(item)

    if hasBackdrop(item)
        c.backdropUrl = imageUrl(id, "Backdrop", 1920)
    else if isValid(item.ParentBackdropItemId) and isValid(item.ParentBackdropImageTags)
        if item.ParentBackdropImageTags.Count() > 0
            c.backdropUrl = imageUrl(safeStr(item.ParentBackdropItemId), "Backdrop", 1920)
        end if
    end if

    setCardSize(c, landscape)
    img = ""
    if landscape
        if c.itemType = "Episode" and imageTag(item, "Primary") <> ""
            img = imageUrl(id, "Primary", 480)
        else if imageTag(item, "Thumb") <> ""
            img = imageUrl(id, "Thumb", 480)
        else if isValid(item.ParentThumbItemId)
            img = imageUrl(safeStr(item.ParentThumbItemId), "Thumb", 480)
        else if hasBackdrop(item)
            img = imageUrl(id, "Backdrop", 480)
        else if c.backdropUrl <> ""
            img = c.backdropUrl.Replace("fillWidth=1920", "fillWidth=480")
        else
            img = imageUrl(id, "Primary", 480)
        end if
    else
        if c.itemType = "Episode" and c.seriesId <> ""
            img = imageUrl(c.seriesId, "Primary", 300)
        else
            img = imageUrl(id, "Primary", 300)
        end if
    end if
    c.HDPosterUrl = img

    ud = item.UserData
    if isValid(ud)
        if isValid(ud.PlayedPercentage) then c.progress = ud.PlayedPercentage / 100.0
        c.resumeSeconds = ticksToSeconds(ud.PlaybackPositionTicks)
        c.played = isTrue(ud.Played)
    end if
    return c
end function

' ================= Seerr data =================

function tmdbImage(path as dynamic, size as string) as string
    p = safeStr(path)
    if p = "" then return ""
    return "https://image.tmdb.org/t/p/" + size + p
end function

' Seerr's media status number as a short badge, or "" for none.
function requestStatusLabel(status as integer) as string
    if status = 2 then return "Requested"
    if status = 3 then return "Downloading"
    if status = 4 then return "Partly available"
    if status = 5 then return "Available"
    return ""
end function

function seerrStatus(result as object) as integer
    mi = result.mediaInfo
    if not isValid(mi) then return 0
    return safeInt(mi.status)
end function

' Convert a Seerr movie or show result into a Card.
function seerrToContent(r as object) as object
    c = newContent()
    mediaType = safeStr(r.mediaType)
    c.itemType = "seerr-" + mediaType
    c.itemId = safeStr(r.id)
    name = safeStr(r.title)
    if name = "" then name = safeStr(r.name)
    c.heading = name
    c.title = name
    c.description = safeStr(r.overview)
    dateStr = safeStr(r.releaseDate)
    if dateStr = "" then dateStr = safeStr(r.firstAirDate)
    parts = []
    if Len(dateStr) >= 4 then parts.Push(Left(dateStr, 4))
    if mediaType = "tv"
        parts.Push("Series")
    else
        parts.Push("Movie")
    end if
    rt = ratingText(r.voteAverage)
    if rt <> "" then parts.Push(rt)
    c.meta = parts.Join(dot())
    c.backdropUrl = tmdbImage(r.backdropPath, "w1280")
    c.HDPosterUrl = tmdbImage(r.posterPath, "w342")
    setCardSize(c, false)
    c.requestStatus = seerrStatus(r)
    c.badge = requestStatusLabel(c.requestStatus)
    return c
end function

' ================= Server address & saved sign-ins =================

function normalizeUrl(raw as string) as string
    url = raw.Trim()
    if url = "" then return ""
    if LCase(Left(url, 4)) <> "http" then url = "http://" + url
    while Right(url, 1) = "/"
        url = Left(url, Len(url) - 1)
    end while
    return url
end function

' "http://192.168.1.50:8096" -> "http://192.168.1.50"
function hostBase(url as string) as string
    sep = Instr(1, url, "://")
    if sep = 0 then return url
    rest = Mid(url, sep + 3)
    cut = Len(rest) + 1
    colon = Instr(1, rest, ":")
    slash = Instr(1, rest, "/")
    if colon > 0 and colon < cut then cut = colon
    if slash > 0 and slash < cut then cut = slash
    return Left(url, sep + 2) + Left(rest, cut - 1)
end function

' Saved sign-ins for the current server: { userId: { token, name, imageTag } }
function readSessions() as object
    reg = CreateObject("roRegistrySection", "Marquee")
    if reg.Exists("sessions")
        s = ParseJson(reg.Read("sessions"))
        if s <> invalid then return s
    end if
    return {}
end function

sub writeSessions(sessions as object)
    reg = CreateObject("roRegistrySection", "Marquee")
    reg.Write("sessions", FormatJson(sessions))
    reg.Flush()
end sub

' ================= Avatars =================

function avatarColor(name as string) as string
    colors = ["0x8E5BD1FF", "0x2A9D8FFF", "0xE07A3FFF", "0x3D7DD8FF", "0xC9475AFF", "0x6A994EFF"]
    total = 0
    for i = 1 to Len(name)
        total = total + Asc(Mid(name, i, 1))
    end for
    return colors[total mod colors.Count()]
end function

' A round avatar: colored circle with an initial, the User's picture on
' top if they have one, and a mask that rounds the corners.
function makeAvatar(userId as string, name as string, imageTag as string, size as integer, symbol = "" as string) as object
    g = CreateObject("roSGNode", "Group")
    bg = g.CreateChild("Rectangle")
    bg.width = size
    bg.height = size
    bg.color = avatarColor(name)
    initial = g.CreateChild("Label")
    initial.width = size
    initial.height = size
    initial.horizAlign = "center"
    initial.vertAlign = "center"
    initial.color = "0xFFFFFFFF"
    initial.font = makeFont(Int(size * 0.42), true)
    if symbol <> ""
        initial.text = symbol
        bg.color = "0x2A2A33FF"
    else
        initial.text = UCase(Left(name, 1))
    end if
    if userId <> "" and imageTag <> ""
        pic = g.CreateChild("Poster")
        pic.width = size
        pic.height = size
        pic.loadWidth = size
        pic.loadHeight = size
        pic.loadDisplayMode = "scaleToZoom"
        pic.uri = m.global.serverUrl + "/Users/" + userId + "/Images/Primary?tag=" + imageTag + "&fillWidth=" + size.ToStr() + "&fillHeight=" + size.ToStr() + "&quality=90"
    end if
    mask = g.CreateChild("Poster")
    mask.width = size
    mask.height = size
    mask.loadDisplayMode = "scaleToFill"
    mask.uri = "pkg:/images/avatar_mask.png"
    mask.blendColor = th().bg
    return g
end function

function measureText(text as string, size as integer, bold as boolean) as integer
    l = CreateObject("roSGNode", "Label")
    l.font = makeFont(size, bold)
    l.text = text
    w = l.boundingRect().width
    if w <= 0 then w = Len(text) * size * 0.55
    return Int(w)
end function

' A pill-shaped chip: { group, bg, label, width }
function makeChip(parent as object, text as string) as object
    t = th()
    g = parent.CreateChild("Group")
    w = measureText(text, 28, true) + 56
    bg = makeShape(g, t.pillUri, w, 56, t.surface, 0)
    l = g.CreateChild("Label")
    l.font = makeFont(28, true)
    l.text = text
    l.width = w
    l.height = 56
    l.horizAlign = "center"
    l.vertAlign = "center"
    l.color = t.textFaint
    return { group: g, bg: bg, label: l, width: w }
end function

' The size of the cell a Card sits in (the Card plus room to grow).
function cellSize(landscape as boolean) as object
    t = th()
    if landscape then return [t.landW + t.cellPadX * 2, t.landH + t.cellPadY * 2]
    return [t.posterW + t.cellPadX * 2, t.posterH + t.cellPadY * 2]
end function
