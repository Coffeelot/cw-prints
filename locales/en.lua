local Translations = {
    info = {
        itemReceived = "You Received %{value_amount} %{value_lable} from %{value_firstname} %{value_lastname}",
        gaveItem = "You gave %{value_firstname} %{value_lastname} %{value_amount} %{value_lable}",
        openBook = "Press pages to flip. Press ESC to close"
    },
    error = {
        otherInventoryFull = "The other players inventory is full!",
        inventoryFull = "Your inventory is full!",
        notEnoughItems = "You do not have enough of the item",
        noItem = "You do not have a %{value_type} on you.",
        noOneNearby = "No one nearby!",
        betterJob = "Do your job better!",

    },
    command = {
        makecardAdmin = "make a business card (admin only)",
        business = "What business is the card for",
        link = "link to the card",
        amount = "amount of cards",
        type = "what type of card",
    },
    text = {
        targetEnterBuilding = "Enter Building",
        targetExitBuilding = "Exit Building",
        targetPrintCards = "Print some cards",
        targetPrintBook = "Print a Book",
        type = "Type",
        businessName = "Business name",
        cardURL = "Card Design (URL)",
        cardAmount = "Amount of cards",
        pageURL = "URL for Page #",
        bookName = "Book name",
        pagesAmount = "How many pages?",
        printAmount = "How many prints?"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
