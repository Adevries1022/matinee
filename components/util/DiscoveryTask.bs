' Jellyfin servers answer a UDP broadcast on port 7359 with a JSON
' description of themselves: { Address, Id, Name, ... }.
sub init()
    m.top.functionName = "discover"
end sub

sub discover()
    found = []
    seen = {}
    port = CreateObject("roMessagePort")
    udp = CreateObject("roDatagramSocket")
    udp.setMessagePort(port)
    target = CreateObject("roSocketAddress")
    target.setAddress("255.255.255.255:7359")
    udp.setSendToAddress(target)
    udp.setBroadcast(true)
    udp.notifyReadable(true)
    udp.sendStr("Who is JellyfinServer?")

    clock = CreateObject("roTimespan")
    clock.Mark()
    resent = false
    while clock.TotalMilliseconds() < 3500
        msg = wait(250, port)
        if type(msg) = "roSocketEvent"
            if udp.isReadable()
                text = udp.receiveStr(4096)
                if text <> invalid and text <> ""
                    j = ParseJson(text)
                    if j <> invalid
                        id = toStr(j.Id)
                        address = toStr(j.Address)
                        if address <> "" and not seen.DoesExist(id)
                            seen[id] = true
                            name = toStr(j.Name)
                            if name = "" then name = "Jellyfin"
                            found.Push({ id: id, name: name, address: address })
                        end if
                    end if
                end if
            end if
        end if
        ' Broadcasts can be dropped; ask a second time.
        if not resent and clock.TotalMilliseconds() > 1200
            udp.sendStr("Who is JellyfinServer?")
            resent = true
        end if
    end while
    udp.close()
    m.top.servers = found
end sub

function toStr(v as dynamic) as string
    t = type(v)
    if t = "String" or t = "roString" then return v
    if t = "Invalid" or t = "roInvalid" or t = "<uninitialized>" then return ""
    return v.ToStr()
end function
