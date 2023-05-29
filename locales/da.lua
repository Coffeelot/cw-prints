local Translations = {
    info = {
        itemReceived = "Du fik %{value_amount} %{value_lable} fra %{value_firstname} %{value_lastname}",
        gaveItem = "Du gav %{value_firstname} %{value_lastname} %{value_amount} %{value_lable}",
        openBook = "Tryk pages for at Flip. Tryk ESC for at lukke"
    },
    error = {
        otherInventoryFull = "Den anden spillers inventar er fuld!",
        inventoryFull = "Dit inventar er fuld!",
        notEnoughItems = "Du har ikke nok af itemet",
        noItem = "Du har ikke %{value_type} på dig.",
        noOneNearby = "Der er ingen i nærheden!",
        betterJob = "Gør dit job bedre!",

    },
    command = {
        makecardAdmin = "lav et firma kort (kun admins)",
        business = "hvilket firma er kortet til",
        link = "link til kortet",
        amount = "antal af kort",
        type = "hvilken slags kort er det",
    },
    text = {
        targetEnterBuilding = "Gå ind i Bygningen",
        targetExitBuilding = "Forlad Bygningen",
        targetPrintCards = "Print nogle Kort",
        targetPrintBook = "Print en Bog",
        type = "Type",
        businessName = "Firma Navn",
        cardURL = "Kort Design (URL)",
        cardAmount = "Antal af Kort",
        pageURL = "URL for Side #",
        bookName = "Bog navn",
        pagesAmount = "Hvor mange sider?",
        printAmount = "Hvor mange prints?"
    }
}

if GetConvar('qb_locale', 'en') == 'da' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
