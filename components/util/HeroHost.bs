' Shared Hero: the large backdrop, title, details and description that
' follow the focused Card. Used by browse-style screens.
' The screen needs a Group with id "heroLayer".

sub setupHero()
    t = th()
    layer = m.top.findNode("heroLayer")
    layer.removeChildrenIndex(layer.getChildCount(), 0)

    m.heroBackdrop = layer.CreateChild("Poster")
    m.heroBackdrop.id = "heroBackdrop"
    m.heroBackdrop.width = 1920
    m.heroBackdrop.height = 1080
    m.heroBackdrop.loadWidth = 1920
    m.heroBackdrop.loadHeight = 1080
    m.heroBackdrop.loadDisplayMode = "scaleToZoom"
    m.heroBackdrop.opacity = 0
    m.heroBackdrop.observeField("loadStatus", "onHeroBackdropStatus")
    addBackdropShade(layer, t.rowsTop - 6)
    setupTrailer(layer, 1, t.rowsTop - 56)

    m.heroFade = layer.CreateChild("Animation")
    m.heroFade.duration = 0.45
    m.heroFade.easeFunction = "outQuad"
    interp = m.heroFade.CreateChild("FloatFieldInterpolator")
    interp.key = [0.0, 1.0]
    interp.keyValue = [0.0, 1.0]
    interp.fieldToInterp = "heroBackdrop.opacity"

    heroBox = layer.CreateChild("LayoutGroup")
    heroBox.layoutDirection = "vert"
    heroBox.itemSpacings = [14, 20]
    m.heroTitle = heroBox.CreateChild("Label")
    m.heroTitle.width = 1150
    m.heroTitle.wrap = true
    m.heroTitle.maxLines = 2
    m.heroTitle.color = t.text
    m.heroMeta = heroBox.CreateChild("Label")
    m.heroMeta.width = 1300
    m.heroMeta.color = t.textDim
    m.heroMeta.font = makeFont(28)
    m.heroOverview = heroBox.CreateChild("Label")
    m.heroOverview.width = 960
    m.heroOverview.wrap = true
    m.heroOverview.maxLines = 3
    m.heroOverview.lineSpacing = 6
    m.heroOverview.color = t.textDim
    m.heroOverview.font = makeFont(30)

    if t.bigHero
        ' Big Hero: the artwork leads, with just the title and details.
        m.heroTitle.font = makeFont(84, true)
        m.heroOverview.visible = false
        heroBox.translation = [t.leftPad, t.rowsTop - 290]
    else
        m.heroTitle.font = makeFont(70, true)
        heroBox.translation = [t.leftPad, t.heroTop + 45]
    end if

    m.heroTimer = layer.CreateChild("Timer")
    m.heroTimer.duration = 0.3
    m.heroTimer.repeat = false
    m.heroTimer.observeField("fire", "applyHero")
    m.heroItem = invalid
end sub

' Show a Card in the Hero after a short pause, so scrolling stays smooth.
sub heroShow(c as object, immediate = false as boolean)
    trailerStop()
    m.heroItem = c
    if immediate
        applyHero()
    else
        m.heroTimer.control = "stop"
        m.heroTimer.control = "start"
    end if
end sub

sub applyHero()
    c = m.heroItem
    if c = invalid then return
    m.heroTitle.text = c.heading
    meta = c.meta
    if c.subtitle <> ""
        if meta <> ""
            meta = c.subtitle + dot() + meta
        else
            meta = c.subtitle
        end if
    end if
    if c.badge <> ""
        if meta <> ""
            meta = c.badge + dot() + meta
        else
            meta = c.badge
        end if
    end if
    m.heroMeta.text = meta
    m.heroOverview.text = c.description
    trailerSchedule(c)
    if c.backdropUrl <> m.heroBackdrop.uri
        m.heroBackdrop.opacity = 0
        m.heroBackdrop.uri = c.backdropUrl
        if m.menu <> invalid then m.menu.backdropUri = c.backdropUrl
    end if
end sub

sub onHeroBackdropStatus()
    if m.heroBackdrop.loadStatus = "ready"
        if th().reduceMotion
            m.heroBackdrop.opacity = 1
        else
            m.heroFade.control = "start"
        end if
    end if
end sub

' Apply the Theme's sizes to a RowList of Cards.
sub styleRows(rows as object, top as integer)
    t = th()
    rows.translation = [t.leftPad - t.cellPadX, top]
    rows.itemSize = [t.contentWidth + t.cellPadX, t.posterH + t.cellPadY * 2 + 60]
    rows.rowItemSpacing = [[0, 0]]
    rows.itemSpacing = [0, 0]
    rows.rowLabelOffset = [[t.cellPadX, 10]]
    rows.rowLabelColor = t.text
    rows.rowLabelFont = makeFont(30, true)
end sub

' Height of one Row with its label.
function rowHeight(landscape as boolean) as integer
    t = th()
    if landscape then return t.landH + t.cellPadY * 2 + 60
    return t.posterH + t.cellPadY * 2 + 60
end function
