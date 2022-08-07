Config = {}

Config.JobIsRequired = true
Config.AllowedJobs = {
    ['print'] = { doors = 1, print = 1}, -- example of a job that allows entrance from lvl 1 and printing from lvl 1
    ['police'] = { doors = 2, print = 4}, -- example of a job that allows entrance from lvl 2 and printing only for 4
    ['ambulance'] = { doors = 1}, -- example of job that allows entrance but no printing
    ['spongebob'] = { doors = 4},
}

Config.Locations = {
    shopEntranceCoords = vector3(-1335.18, -338.17, 36.69),
    shopExitCoords = vector3(1173.75, -3196.44, -39.01),
    interactionPoint = vector3(1163.63, -3197.35, -37.99)
}

Config.Texts = {
    cardMakerHeader = "Business Card Maker 2000 (©1987)",
    cardMakerSubmit = "Create"
}

Config.Items = {
    { value = "business_card", text = "Business Card" },
    { value = "coupon", text = "Coupon" },
    { value = "flyer", text = "Flyer" },
    { value = "menu", text = "Menu" },
}

Config.Cost = 1
