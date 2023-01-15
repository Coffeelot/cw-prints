local Translations = {
    info = {
        itemReceived = "Sie haben %{value_amount}x %{value_lable} von %{value_firstname} %{value_lastname} erhalten",
        gaveItem = "Sie gaben %{value_firstname} %{value_lastname} %{value_amount}x %{value_lable}",
        openBook = "Drücken Sie zum Blättern auf die Seiten. Drücken Sie ESC zum Schließen"
    },
    error = {
        otherInventoryFull = "Das Inventar des anderen Spielers ist voll!",
        inventoryFull = "Ihr Inventar ist voll!",
        notEnoughItems = "Sie haben nicht genug von dem Gegenstand",
        noItem = "Sie haben kein %{value_type} bei sich.",
        noOneNearby = "Es ist niemand in der Nähe!",
        betterJob = "Machen Sie Ihren Job besser!",

    },
    command = {
        makecardAdmin = "Eine Karte erstellen (nur für Admin)",
        business = "Für welches Unternehmen ist die Karte?",
        link = "Link zur Karte",
        amount = "Anzahl der Karten",
        type = "Welche Art von Karte",
    },
    text = {
        targetEnterBuilding = "Gebäude betreten",
        targetExitBuilding = "Gebäude verlassen",
        targetPrintCards = "Karten drucken",
        targetPrintBook = "Bücher drucken",
        type = "Art",
        businessName = "Name des Unternehmens",
        cardURL = "Kartendesign (URL)",
        cardAmount = "Anzahl der Karten",
        pageURL = "URL für Seite #",
        bookName = "Buchname",
        pagesAmount = "Wie viele Seiten?",
        printAmount = "Wie viele Ausdrucke?"
    }
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
