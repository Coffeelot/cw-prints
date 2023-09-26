Config = {}

Config.JobIsRequired = false
Config.AllowedJobs = {
    ['print'] = { doors = 1, print = 1},
    ['police'] = { doors = 2, print = 4},
    ['ambulance'] = { doors = 1},
    ['spongebob'] = { doors = 4},
}

-- Setup for the shop + interaction area
Config.UseInteractionPoint = true -- set this to false if you don't want to use the stock locations
Config.UseShop = true -- set this to false if you don't want to use the shop entrance/exit
Config.Inv = 'qb' -- Can used 'qb' for QB Inventory or 'ox' for Ox_inventory

Config.Locations = {
    shopEntranceCoords = vector3(-1335.18, -338.17, 36.69),
    shopExitCoords = vector3(1173.75, -3196.44, -39.01),
    interactionPoint = vector3(1163.63, -3197.35, -37.99)
}

-- Setup for making ALL printer props interactable
Config.UseAllPrinters = false -- set this to true if you want ALL printer props (defined in Config.PrinterProps) to be interactable
Config.PrinterProps = {
    "prop_printer_01",
    "prop_printer_02",
    "v_res_printer"
}

-- Setup for spawning printers
Config.UsePrinterSpawns = false -- set this to true if you want to spawn specific printers that are interactable
Config.PrinterSpawns = {
    { prop = "prop_printer_01", coords = vector4(1157.08, -3190.4, -38.16, 85.72)},
    { prop = "prop_printer_02", coords = vector4(1157.08, -3191.4, -38.16, 81.72)},
    { prop = "v_res_printer", coords = vector4(1157.08, -3192.1, -38.16, 82.72)},
}

-- General Setup
Config.Texts = {
    cardMakerHeader = "Business Card Maker 2000 (©1987)",
    cardMakerSubmit = "Create",
    bookMaker1Header = "Book Maker ELITE EDITION (©1982)",
    bookMaker1Submit = "Next",
    bookMaker2Header = "Book Maker ELITE EDITION (©1982)",
    bookMaker2Submit = "Create",
}

Config.Items = {
    { value = "business_card", text = "Business Card" },
    { value = "coupon", text = "Coupon" },
    { value = "flyer", text = "Flyer" },
    { value = "menu", text = "Menu" },
}

Config.BookItems = {
    { value = "book", text = "Book" },
 }

Config.PrintCost = {
    ["business_card"] = 150,
    ["coupon"] = 700,
    ["flyer"] = 600,
    ["menu"] = 300,
    ["book"] = 1000,
}

Config.DynamicPages = {
    example = {
        "https://wallpapercave.com/wp/wp9414303.jpg",
        "https://wallpapercave.com/wp/wp8802810.jpg",
        "https://wallpapercave.com/wp/wp8802809.jpg",
        "https://wallpapercave.com/dwp1x/wp8802815.jpg"
    }
}