sub init()
    m.card = m.top.findNode("card")
    m.ring = m.top.findNode("ring")
    m.placeholder = m.top.findNode("placeholder")
    m.fallback = m.top.findNode("fallback")
    m.poster = m.top.findNode("poster")
    m.shade = m.top.findNode("shade")
    m.caption = m.top.findNode("caption")
    m.trackBg = m.top.findNode("trackBg")
    m.track = m.top.findNode("track")
    m.corners = m.top.findNode("corners")
    m.badge = m.top.findNode("badge")
    m.badgeBg = m.top.findNode("badgeBg")
    m.badgeText = m.top.findNode("badgeText")
    m.fadeIn = m.top.findNode("fadeIn")
    m.poster.observeField("loadStatus", "onPosterStatus")

    t = th()
    ' Read once: these are used on every focus step.
    m.focusScale = t.cardFocusScale
    m.reduceMotion = t.reduceMotion
    m.padX = t.cellPadX
    m.padY = t.cellPadY
    m.ringOut = t.ringInset + t.ringStroke + t.ringGap
    m.w = 0
    m.h = 0
    m.placeholder.uri = t.fillUri
    m.placeholder.blendColor = t.surface
    m.placeholder.opacity = t.surfaceOpacity * 1.6
    m.fallback.color = t.textFaint
    m.caption.color = "0xFFFFFFFF"
    m.track.color = t.accent
    m.ring.uri = t.ringUri
    m.ring.blendColor = t.focusColor
    if t.cornerUri <> ""
        m.corners.uri = t.cornerUri
        m.corners.blendColor = t.bg
        m.corners.visible = true
    end if
    m.badgeBg.uri = t.fillUri
    m.badgeBg.blendColor = t.accent
    m.badgeText.color = t.onAccent
end sub

sub showContent()
    c = m.top.itemContent
    if c = invalid then return
    if m.poster.uri = c.HDPosterUrl and m.poster.loadStatus = "ready"
        m.poster.opacity = 1
    else
        m.fadeIn.control = "stop"
        m.poster.opacity = 0
        m.poster.uri = c.HDPosterUrl
    end if
    m.fallback.text = c.heading
    m.caption.text = c.heading
    m.badgeText.text = c.badge
    layout()
end sub

sub onPosterStatus()
    if m.poster.loadStatus = "ready"
        if m.reduceMotion
            m.poster.opacity = 1
        else
            m.fadeIn.control = "start"
        end if
    end if
end sub

sub layout()
    c = m.top.itemContent
    if c = invalid then return
    w = c.cardW
    h = c.cardH
    if w = 0 or h = 0 then return
    m.card.translation = [m.padX, m.padY]
    m.w = w
    m.h = h
    m.placeholder.width = w
    m.placeholder.height = h
    m.poster.width = w
    m.poster.height = h
    m.poster.loadWidth = w
    m.poster.loadHeight = h
    m.corners.width = w
    m.corners.height = h
    m.fallback.translation = [12, 0]
    m.fallback.width = w - 24
    m.fallback.height = h

    landscape = w > h
    showCap = false
    if c <> invalid
        showCap = landscape and c.heading <> ""
    end if
    m.shade.visible = showCap
    m.caption.visible = showCap
    m.shade.translation = [0, h - 90]
    m.shade.width = w
    m.shade.height = 90
    m.shade.opacity = 0.9
    m.caption.translation = [18, h - 56]
    m.caption.width = w - 36
    m.caption.height = 44

    showTrack = false
    if c <> invalid
        showTrack = c.progress > 0.01 and c.progress < 0.97
    end if
    m.trackBg.visible = showTrack
    m.track.visible = showTrack
    m.trackBg.translation = [0, h - 6]
    m.trackBg.width = w
    m.trackBg.height = 6
    m.track.translation = [0, h - 6]
    m.track.height = 6
    if showTrack then m.track.width = w * c.progress

    hasBadge = false
    if c <> invalid then hasBadge = (c.badge <> "")
    m.badge.visible = hasBadge
    if hasBadge
        bw = Len(c.badge) * 11 + 28
        if bw > w - 16 then bw = w - 16
        m.badge.translation = [10, 10]
        m.badgeBg.width = bw
        m.badgeBg.height = 34
        m.badgeText.width = bw
        m.badgeText.height = 34
    end if

    m.card.scaleRotateCenter = [w / 2, h / 2]
    updateFocus()
end sub

sub updateFocus()
    pct = 0
    if m.top.rowListHasFocus or m.top.gridHasFocus
        pct = m.top.focusPercent * m.top.rowFocusPercent
    end if
    m.ring.opacity = pct
    if m.w = 0 or m.h = 0 then return
    ' Grow by whole pixels on each side, so the Card's rounded corners and the
    ' ring line up exactly instead of landing on fractional pixels.
    gx = Int((m.focusScale - 1) * m.w / 2 * pct + 0.5)
    gy = Int((m.focusScale - 1) * m.h / 2 * pct + 0.5)
    m.card.scale = [(m.w + gx * 2) / m.w, (m.h + gy * 2) / m.h]
    ' The focus ring sits just outside the grown Card with a small, even gap.
    ox = gx + m.ringOut
    oy = gy + m.ringOut
    m.ring.translation = [m.padX - ox, m.padY - oy]
    m.ring.width = m.w + ox * 2
    m.ring.height = m.h + oy * 2
end sub
