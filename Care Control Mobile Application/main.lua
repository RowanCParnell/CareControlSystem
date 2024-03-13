--Things to note:
--Outstanding values are in red
--Due values are in orange



-- dependencies
local display = display
local system = system
local unpack = unpack
local native = native
local widget = require("widget")
local config = require("config")
local application = application
local json = require("json")
local string = string
local stringfind = string.find
local stringgsub = string.gsub
local stringlower = string.lower

local filename = system.pathForFile("data.json", system.ResourceDirectory)
local jsondata, pos, msg = json.decodeFile(filename)

-- Styling

local elementcornerradius = 10

local bodywidth = application.content.height --1024
local bodyheight = application.content.width --768
local bodyelementstyle = {0, 0, bodywidth, bodyheight, elementcornerradius}

local colours = {
    white = {255, 255, 255},
    black = {0, 0, 0},

    darkgrey = {180, 180, 180},
    grey = {200, 200, 200},
    lightgrey = {220, 220, 220},

    darkblue = {2, 54, 89},
    blue = {9, 102, 164},
    teal = {25, 186, 178},

    pink = {255, 229, 232},
    red = {255, 55, 67},
    peach = {255, 240, 230},
    orange = {254, 155, 47},
}

local colourscheme = {
    -- defaults are white
    -- background colour, text colour, border colour
    body = {colours.darkgrey},

    bar_nav = {colours.white},
    title = {false, colours.darkblue},
    button_back = {colours.blue},
    button_help = {colours.teal},
    button_finish = {colours.teal},
    button_home = {colours.blue},


    bar_filter = {colours.white},
    filter_sort = {colours.blue},

    filter_id_title = {colours.grey, colours.darkblue},
    filter_id = {},
    filter_name_title = {colours.grey, colours.darkblue},
    filter_name = {},
    filter_room_title = {colours.grey, colours.darkblue},
    filter_room = {},

    button_clear = {false, colours.teal, colours.teal},
    button_update = {colours.teal},

    container_occupants = {colours.darkgrey},

    occupantbox = {colours.white},
    occupantname = {false, colours.darkblue},
    occupantroom = {false, colours.darkblue},

    outstandingwidget = {colours.pink, colours.red},
    duewidget = {colours.peach, colours.orange},

    occupantimage = {},
    outstandingcircle = {colours.red},
    duecircle = {colours.orange},
    goodstandingcircle = {colours.teal},
}

local elementstyles = {
    -- values are percentages
    -- values are relative to their parent's position
    -- x, y, width, height
    body = {0, 0, 100, 100},

    bar_nav = {0, 0, 100, 10},
    button_back = {2.5, 20, 4, 50},
    logo = {7, 20, 6, 50},
    title = {13, 30, 15, 50},
    button_help = {62, 20, 10, 50},
    button_finish = {75, 20, 10, 50},
    button_home = {88, 20, 10, 50},


    bar_filter = {0, 10.25, 100, 8},

    filter_sort = {1, 25, 16, 50},

    filter_id_title = {18, 25, 6, 50},
    filter_id = {24, 25, 13, 50},

    filter_name_title = {38, 25, 8, 50},
    filter_name = {46, 25, 13, 50},

    filter_room_title = {60, 25, 8, 50},
    filter_room = {68, 25, 13, 50},

    button_clear = {82, 25, 6, 50},
    button_update = {89, 25, 10, 50},


    container_occupants = {0, 18.5, 100, 80},

    occupantbox = {2, -20, 23, 17},

    occupantname = {32, 30, 65, 19},
    occupantroom = {32, 55, 65, 15},

    duewidget = {80, 3, 15, 20},
    outstandingwidget = {90, 6, 15, 20},

    occupantimage = {1, 15, 15, 20},
    outstandingcircle = {1, 15, 15, 20},
    duecircle = {1, 15, 15, 20},
    goodstandingcircle = {1, 15, 15, 20},
}

local fonts = {
    font_size_title = 24,
    font_size_large = 18,
    font_size_small = 14,
}

local elementfonts = {
    button_back = fonts.font_size_title,
    title = fonts.font_size_title,
    button_help = fonts.font_size_large,
    button_finish = fonts.font_size_large,
    button_home = fonts.font_size_large,


    filter_sort = fonts.font_size_small,

    filter_id_title = fonts.font_size_small,
    filter_id = fonts.font_size_small,
    filter_name_title = fonts.font_size_small,
    filter_name = fonts.font_size_small,
    filter_room_title = fonts.font_size_small,
    filter_room = fonts.font_size_small,

    button_clear = fonts.font_size_small,
    button_update = fonts.font_size_small,


    occupantname = fonts.font_size_large,
    occupantroom = fonts.font_size_small,

    duewidget = fonts.font_size_small,
    occupantwidget = fonts.font_size_small,
}

local imagesources = {
    logo = "icon.png",
    help = "icon.png",
    finish = "icon.png",
    home = "icon.png",
    sort = "icon.png",
    clear = "icon.png",
    update = "icon.png",
    outstanding = "icon.png",
    due = "icon.png",
}

local occupantimageprefix = ""
local occupantimagesuffix = ".png"

local elementtree = {
    bar_nav = {
        button_back = 1,
        logo = 1,
        title = 1,
        button_help = 1,
        button_finish = 1,
        button_home = 1,
    },
    bar_filter = {
        filter_sort = 1,
        filter_id_title = 1,
        filter_id = 1,
        filter_name_title = 1,
        filter_name = 1,
        filter_room_title = 1,
        filter_room = 1,
        button_clear = 1,
        button_update = 1,
    },
    container_occupants = {
        occupantbox = {
            occupantname = 1,
            occupantroom = 1,
            occupantimage = 1,
            duewidget = 1,
            outstandingwidget = 1,
            duecircle = 1,
            outstandingcircle = 1,
            goodstandingcircle = 1,
        }
    }
}

local sortoptions = {"Most Outstanding Issues", "Least Outstanding Issues", "Most Due Issues", "Least Due Issues"}

-- Variables

local convertedjsondata = {}
local occupantdata = {}

local scrollbox

local currentsortoption = 1
local idflag, nameflag, roomflag

-- common functions

local function ValueToDecimal(value)
    if value == nil then
        return 1
    else
        return 1 / 255 * value
    end
end

local function PercentageToPixel(percentage, pixelamount)
    return pixelamount * percentage / 100
end

local function GetPositionAndSizeOfBarElement(id)
    local style = elementstyles[id]
    if style then
        local px, py, pw, ph = unpack(style)

        local isparent = elementtree[id]
        if isparent then
            local x, y, w, h = PercentageToPixel(px, bodywidth), PercentageToPixel(py, bodyheight), PercentageToPixel(pw, bodywidth), PercentageToPixel(ph, bodyheight)
            return x, y, w, h
        else
            for parentname, elements in pairs(elementtree) do
                if elements[id] then
                    local parentstyle = elementstyles[parentname]
                    local parentpx, parentpy, parentpw, parentph = unpack(parentstyle)

                    local parentx, parenty = PercentageToPixel(parentpx, bodywidth), PercentageToPixel(parentpy, bodyheight)
                    local parentw, parenth = PercentageToPixel(parentpw, bodywidth), PercentageToPixel(parentph, bodyheight)

                    local x, y = PercentageToPixel(px, parentw), PercentageToPixel(py, parenth)
                    local w, h = PercentageToPixel(pw, parentw), PercentageToPixel(ph, parenth)

                    x, y = x + parentx, y + parenty

                    return x, y, w, h
                end
            end
        end
    end
end

local function GetPositionAndSizeOfOccupantBox(id)
    local style = elementstyles[id]
    if style then
        local containerpx, containerpy, containerpw, containerph = unpack(elementstyles["container_occupants"])
        local boxpx, boxpy, boxpw, boxph = unpack(elementstyles["occupantbox"])
        local px, py, pw, ph = unpack(style)

        local containerx, containery = PercentageToPixel(containerpx, bodywidth), PercentageToPixel(containerpy, bodyheight)
        local containerw, containerh = PercentageToPixel(containerpw, bodywidth), PercentageToPixel(containerph, bodyheight)

        local boxx, boxy = PercentageToPixel(boxpx, containerw), PercentageToPixel(boxpy, containerh)
        local boxw, boxh = PercentageToPixel(boxpw, containerw), PercentageToPixel(boxph, containerh)

        local x, y = PercentageToPixel(px, boxw), PercentageToPixel(py, boxh)
        local w, h = PercentageToPixel(pw, boxw), PercentageToPixel(ph, boxh)

        x, y = x + boxx + containerx, y + boxy + containery

        return x, y, w, h
    end
end

local function StyleElement(element, id)
    local style = colourscheme[id]
    if style then
        local background, text, border = unpack(style)
        if background then
            local r, g, b, a = unpack(background)
            r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)
            element:setFillColor(r, g, b, a)
        else
            element:setFillColor(1, 1, 1, 1)
        end
        if text then
            local r, g, b, a = unpack(text)
            r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)
            element:setFillColor(r, g, b, a)
        end
        if border then
            local r, g, b, a, width = unpack(border)
            r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)
            element:setStrokeColor(r, g, b, a)
            element.strokeWidth = 4
        end
    end
    return element
end

local function CreateRectangle(id)
    local style = elementstyles[id]
    if style then
        local element = display.newRect(GetPositionAndSizeOfBarElement(id))
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateRectangleRounded(id)
    local style = elementstyles[id]
    if style then
        local x, y, w, h = GetPositionAndSizeOfBarElement(id)
        local element = display.newRoundedRect(x, y, w, h, elementcornerradius)
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateFilter(id)
    local style = elementstyles[id]
    if style then
        local element = native.newTextField(GetPositionAndSizeOfBarElement(id))
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateFilterTextBox(id, text)
    local style = elementstyles[id]
    if style then
        local x, y, w, h = GetPositionAndSizeOfBarElement(id)
        local r, g, b, a = unpack(colourscheme[id][2])
        r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)
        local element = widget.newButton({
            labelColor = {default={r, g, b, a}},
            fontSize = fonts.font_size_small,
            label = text,
            x = x,
            y = y,
            width = w,
            height = h,
            emboss = false,
            shape = "roundedRect",
            cornerRadius = elementcornerradius,
        })
        r, g, b, a = unpack(colourscheme[id][1])
        r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)
        element:setFillColor(r, g, b, a)
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end


local function CreateButton(id, text)
    local style = elementstyles[id]
    if style then
        local x, y, w, h = GetPositionAndSizeOfBarElement(id)
        local element = widget.newButton({
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            fontSize = fonts.font_size_small,
            label = text,
            x = x,
            y = y,
            width = w,
            height = h,
            emboss = false,
            shape = "roundedRect",
            cornerRadius = elementcornerradius,
        })
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateText(id, text)
    local style = elementstyles[id]
    if style then
        local x, y, w, h = GetPositionAndSizeOfBarElement(id)
        local font = elementfonts[id]
        local element = display.newText({text = text, x = x, y = y, width = w, height = h, fontSize = font, align = "left"})
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateCircleForOccupantBox(id)
    local style = elementstyles[id]
    if style then
        local element = display.newCircle(GetPositionAndSizeOfOccupantBox(id))
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

local function CreateTextForOccupantBox(id, text)
    local style = elementstyles[id]
    if style then
        local x, y, w, h = GetPositionAndSizeOfOccupantBox(id)
        local font = elementfonts[id]
        local element = display.newText({text = text, x = x, y = y, width = w, height = h, fontSize = font, align = "left"})
        element.anchorX = 0
        element.anchorY = 0
        return element
    end
end

-- main

local function GenerateOccupantBox(data, columncount, rowcount, ychange, xchange)
    local name, room, outstanding, due = data["name"], data["room"], data["outstanding"], data["due"]

    local occupantbox = StyleElement(CreateRectangleRounded("occupantbox"), "occupantbox")

    local occupantname = StyleElement(CreateTextForOccupantBox("occupantname", name), "occupantname")
    local occupantroom = StyleElement(CreateTextForOccupantBox("occupantroom", room), "occupantroom")

    local outstandingcircle, outstandingwidget, duecircle, duewidget, goodstandingcircle

    if outstanding > 0 then
        outstandingcircle = StyleElement(CreateCircleForOccupantBox("outstandingcircle"), "outstandingcircle")
        outstandingwidget = StyleElement(CreateTextForOccupantBox("outstandingwidget", outstanding), "outstandingwidget")
    end
    if due > 0 then
        if outstandingcircle == nil then
            duecircle = StyleElement(CreateCircleForOccupantBox("duecircle"), "duecircle")
        end
        duewidget = StyleElement(CreateTextForOccupantBox("duewidget", due), "duewidget")
    end
    if outstandingwidget == nil and duewidget == nil then
        goodstandingcircle = StyleElement(CreateCircleForOccupantBox("goodstandingcircle"), "goodstandingcircle")
    end

    occupantbox.y = occupantbox.y + (ychange * rowcount)
    occupantname.y = occupantname.y + (ychange * rowcount)
    occupantroom.y = occupantroom.y + (ychange * rowcount)

    occupantbox.x = occupantbox.x + (xchange * columncount)
    occupantname.x = occupantname.x + (xchange * columncount)
    occupantroom.x = occupantroom.x + (xchange * columncount)

    scrollbox:insert(occupantbox)
    scrollbox:insert(occupantname)
    scrollbox:insert(occupantroom)

    if outstandingcircle then
        outstandingcircle.y = outstandingcircle.y + (ychange * rowcount)
        outstandingcircle.x = outstandingcircle.x + (xchange * columncount)
        scrollbox:insert(outstandingcircle)
    end
    if duecircle then
        duecircle.y = duecircle.y + (ychange * rowcount)
        duecircle.x = duecircle.x + (xchange * columncount)
        scrollbox:insert(duecircle)
    end
    if goodstandingcircle then
        goodstandingcircle.y = goodstandingcircle.y + (ychange * rowcount)
        goodstandingcircle.x = goodstandingcircle.x + (xchange * columncount)
        scrollbox:insert(goodstandingcircle)
    end

    if outstandingwidget then
        outstandingwidget.y = outstandingwidget.y + (ychange * rowcount)
        outstandingwidget.x = outstandingwidget.x + (xchange * columncount)
        scrollbox:insert(outstandingwidget)
    end
    if duewidget then
        duewidget.y = duewidget.y + (ychange * rowcount)
        duewidget.x = duewidget.x + (xchange * columncount)
        scrollbox:insert(duewidget)
    end

end

local function UpdateOccupantBoxList()
    local scrollboxx, scrollboxy, scrollboxw, scrollboxh = GetPositionAndSizeOfBarElement("container_occupants")
    local style = colourscheme["container_occupants"]
    local background = unpack(style)
    local r, g, b, a = unpack(background)
    r, g, b, a = ValueToDecimal(r), ValueToDecimal(g), ValueToDecimal(b), ValueToDecimal(a)

    if scrollbox then
        scrollbox:removeSelf()
        scrollbox = nil
    end
    scrollbox = widget.newScrollView({
        top = scrollboxy,
        left = scrollboxx,
        width = scrollboxw,
        height = scrollboxh,
        horizontalScrollDisabled = true,
        backgroundColor = {r, g, b, a}
    })

    local columncount = -1
    local rowcount = 0
    local xchange = 250
    local ychange = 120

    local totalcount = 0

    for i = 1, #jsondata, 1 do
        totalcount = totalcount + 1
        for id, data in pairs(occupantdata) do
            if totalcount == data["filterposition"] then
                columncount = columncount + 1
                GenerateOccupantBox(data, columncount, rowcount, ychange, xchange)
                if columncount == 3 then
                    columncount = -1
                    rowcount = rowcount + 1
                end
            end
        end
    end

    local blankspace = StyleElement(CreateRectangle("occupantbox"), "occupantbox")
    blankspace.y = blankspace.y + (ychange * (rowcount + 1))
    scrollbox:insert(blankspace)
    blankspace.isVisible = false
end

local function FilterAndSortData()
    local filteredoccupantdata = {}

    -- filter
    for id, value in pairs(convertedjsondata) do
        local numberofflags, numberofmetflags = 0, 0
        if idflag then
            numberofflags = numberofflags + 1
            local changedid = stringgsub(stringlower(id), "-", "")
            if stringfind(changedid, idflag) then
                numberofmetflags = numberofmetflags + 1
            end
        end
        if nameflag then
            numberofflags = numberofflags + 1
            if stringfind(value["name"], nameflag) then
                numberofmetflags = numberofmetflags + 1
            end
        end
        if roomflag then
            numberofflags = numberofflags + 1
            if stringfind(value["room"], roomflag) then
                numberofmetflags = numberofmetflags + 1
            end
        end
        if numberofflags == numberofmetflags then
            filteredoccupantdata[id] = value
        end
    end

    --sort

    if currentsortoption == 1 then -- "Most Outstanding Issues"

        for id, value in pairs(filteredoccupantdata) do
            local outstanding = value["outstanding"]
            value["filterposition"] = 0
            if outstanding > 0 then
                for id2, value2 in pairs(filteredoccupantdata) do
                    local outstanding2 = value2["outstanding"]
                    if outstanding <= outstanding2 then
                        value["filterposition"] = value["filterposition"] + 1
                    end
                end
            else
                value["filterposition"] = #jsondata
            end
        end

    elseif currentsortoption == 2 then -- "Least Outstanding Issues"

        for id, value in pairs(filteredoccupantdata) do
            local outstanding = value["outstanding"]
            value["filterposition"] = 0
            if outstanding > 0 then
                for id2, value2 in pairs(filteredoccupantdata) do
                    local outstanding2 = value2["outstanding"]
                    if outstanding > outstanding2 then
                        value["filterposition"] = value["filterposition"] + 1
                    end
                end
            else
                value["filterposition"] = 1
            end
        end

    elseif currentsortoption == 3 then -- "Most Due Issues"

        for id, value in pairs(filteredoccupantdata) do
            local due = value["due"]
            value["filterposition"] = 0
            if due > 0 then
                for id2, value2 in pairs(filteredoccupantdata) do
                    local due2 = value2["due"]
                    if due <= due2 then
                        value["filterposition"] = value["filterposition"] + 1
                    end
                end
            else
                value["filterposition"] = #jsondata
            end
        end

    elseif currentsortoption == 4 then -- "Least Due Issues"

        for id, value in pairs(filteredoccupantdata) do
            local due = value["due"]
            value["filterposition"] = 0
            if due > 0 then
                for id2, value2 in pairs(filteredoccupantdata) do
                    local due2 = value2["due"]
                    if due > due2 then
                        value["filterposition"] = value["filterposition"] + 1
                    end
                end
            else
                value["filterposition"] = 1
            end
        end

    end

    occupantdata = filteredoccupantdata
    UpdateOccupantBoxList()
end

local function CreateApp()
    -- Sorting data by id
    for index, value in ipairs(jsondata) do
        local id, name, room, outstanding, due = value["id"], value["name"], value["room"], value["oustanding"], value["due"]
        convertedjsondata[id] = {name = name, room = room, outstanding = outstanding, due = due, filterposition = 0}
    end

    -- Building

    local body = StyleElement(display.newRoundedRect(unpack(bodyelementstyle)), "body")
    body.anchorX = 0
    body.anchorY = 0

    local bar_nav = StyleElement(CreateRectangle("bar_nav"), "bar_nav")

    local button_back = StyleElement(CreateButton("button_back", "<"), "button_back")
    local logo = StyleElement(CreateRectangle("logo"), "logo")
    local title = StyleElement(CreateText("title", "Multi Record"), "title")
    local button_help = StyleElement(CreateButton("button_help", "Get Help"), "button_help")
    local button_finish = StyleElement(CreateButton("button_finish", "Finish"), "button_finish")
    local button_home = StyleElement(CreateButton("button_home", "Home"), "button_home")

    local bar_filter = StyleElement(CreateRectangle("bar_filter"), "bar_filter")

    local filter_sort = StyleElement(CreateButton("filter_sort"), "filter_sort")

    filter_sort:setLabel(sortoptions[currentsortoption])
    filter_sort:addEventListener("touch", function(event)
        if ("ended" == event.phase) then
            currentsortoption = currentsortoption + 1
            if currentsortoption > #sortoptions then
                currentsortoption = 1
            end
            filter_sort:setLabel(sortoptions[currentsortoption])
            FilterAndSortData()
        end
    end)

    local filter_id_title = CreateFilterTextBox("filter_id_title", "Filter ID:")
    local filter_id = CreateFilter("filter_id")

    filter_id:addEventListener("userInput", function(event)
        if (event.phase == "editing") then
            local text = event.text
            if text then
                if text == "" then
                    idflag = nil
                else
                    idflag = stringgsub(stringlower(text), "-", "")
                end
            end
        end
    end)

    local filter_name_title = CreateFilterTextBox("filter_name_title", "Filter Name:")
    local filter_name = CreateFilter("filter_name")

    filter_name:addEventListener("userInput", function(event)
        if (event.phase == "editing") then
            local text = event.text
            if text then
                if text == "" then
                    nameflag = nil
                else
                    nameflag = text
                end
            end
        end
    end)

    local filter_room_title = CreateFilterTextBox("filter_room_title", "Filter Room:")
    local filter_room = CreateFilter("filter_room")

    filter_room:addEventListener("userInput", function(event)
        if (event.phase == "editing") then
            local text = event.text
            if text then
                if text == "" then
                    roomflag = nil
                else
                    roomflag = text
                end
            end
        end
    end)

    local button_clear = StyleElement(CreateButton("button_clear"), "button_clear")

    button_clear:setLabel("Clear")
    button_clear:addEventListener("touch", function(event)
        if ("ended" == event.phase) then
            filter_id.text = ""
            filter_name.text = ""
            filter_room.text = ""
            idflag = nil
            nameflag = nil
            roomflag = nil
            FilterAndSortData()
        end
    end)

    local button_update = StyleElement(CreateButton("button_update"), "button_update")

    button_update:setLabel("Update")
    button_update:addEventListener("touch", function(event)
        if ("ended" == event.phase) then
            FilterAndSortData()
        end
    end)

    FilterAndSortData()
end

CreateApp()