# cw-prints 🖨
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐

This script enables player created business cards. Comes with a warp to an interior but this can easily be ignored if you want to use it in any other fashion. Easilyconfigured in the *Config.Lua*.
In the future we plan to make it support any type of printable item (flyers etc)

# Preview 📽
[![YOUTUBE VIDEO](http://img.youtube.com/vi/CSYWQ2pf2a4/0.jpg)](https://youtu.be/CSYWQ2pf2a4)

# Links
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐


### [More free scripts](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

### Support, updates and script previews:

<a href="https://discord.gg/FJY4mtjaKr"> <img src="https://media.discordapp.net/attachments/1202695794537537568/1285652389080334337/discord.png?ex=66eb0c97&is=66e9bb17&hm=b1b2c17715f169f57cf646bb9785b0bf833b2e4037ef47609100ec8e902371df&=&format=webp" width="200"></a>


### If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )


# Config 🔧

> MAKE SURE TO REMOVE -main from the folder name or the script won't work!

**JobIsRequired**: Set to *true* if you want to lock this behind a job. Default is*false*\
**AllowedJob**: The job you want to be able to use it. Only needed if JobIsRequired is*true*\
**Locations**: Vectors for the warps and the interaction point\
**Texts**: Strings for the interaction point\
**Item**: The item that is created and added to your inventory\
**Cost**: Cost per card\

## Dynamic pages
If you want to have pages that you can edit via config so they can change over time you can use dynamic pages
These are defined in Config.DynamicPages

The script does not support creating these from the menu, so these need to be done in code. To add these, set the info/metadata field "useDynamicPages" to whatever name you want to use from your list of dynamic pages.

So, in a server file where you want to add a dynamic print you can do this:
```lua
    info = {}
    info.type = "book"
    info.name = "Example Book With Dynamic Pages"
    info.label = "Example Book With Dynamic Pages" -- Needed cause it's not handled automatically
    info.useDynamicPages = 'example' -- this will pull pages from Config.DynamicPages.example

    Player.Functions.AddItem('book', 1, false, info)
```

## Changing interaction shake
If you don't want to use the current warp and interior then all you need to do is add this event to wherever you want to call it: `"cw-prints:client:openInteraction"` This will open the interaction menu for the script. 
# Add to qb-core ❗
Items to add to qb-core>shared>items.lua if you want to used the included item

> NOTE: Currently the field `["unique"]` is set to `true` on all objects. This means after you get the initial stack, if you split it you can't restack again! Change these to `false` if you rather want them to stack but risk losing some, as stacking different kinds will make them all one of a kind.

> Ox Note: If you got ox, you dont need to bother with this since Ox can stack depending on metadata.

Basically:
false:
+ can restack
- will overwrite if placed in stack with different ones

true:
+ Wont overwrite
- can't restack

```
["business_card"] 					 = {["name"] ="business_card", 			  	  		["label"] = "A business card", 			["weight"] = 0, 		["type"] = "item", 		["image"] = "bctest.png", 			["unique"] = true,	 	["useable"] = true,			["created"] = nil,		["decay"] =nil, 	["shouldClose"] = false, ["combinable"] = nil,   ["description"] = "A businesscard"},
["coupon"] 					 = {["name"] = "coupon", 			  	  		["label"] ="Coupon", 				["weight"] = 0, 		["type"] = "item", 		["image"] ="coupon.png", 				["unique"] = true,	 	["useable"] = true,		["created"] = nil,		["decay"] = nil, 	["shouldClose"] = false, ["combinable"] =nil,   ["description"] = "A Coupon"},
["flyer"] 					 = {["name"] = "flyer", 			  	  		["label"] ="Flyer", 				["weight"] = 0, 		["type"] = "item", 		["image"] ="flyer.png", 				["unique"] = true,	 	["useable"] = true,		["created"] = nil,		["decay"] = nil, 	["shouldClose"] = false, ["combinable"] =nil,   ["description"] = "A Flyer"},
["menu"] 					 = {["name"] = "menu", 			  	  		["label"] ="Menu", 				["weight"] = 0, 		["type"] = "item", 		["image"] ="menu.png", 				["unique"] = true,	 	["useable"] = true,		["created"] = nil,		["decay"] = nil, 	["shouldClose"] = false, ["combinable"] =nil,   ["description"] = "A Menu"},
["book"] 					 = {["name"] = "book", 			  	  		["label"] = "Book", 				["weight"] = 0, 		["type"] = "item", 		["image"] = "book.png", 				["unique"] = true,	 	["useable"] = true,			["created"] = nil,		["decay"] = nil, 	["shouldClose"] = false, ["combinable"] = nil,   ["description"] = "A book"},
["newspaper"] 					 = {["name"] = "newspaper", 			  	  		["label"] = "newspaper", 				["weight"] = 0, 		["type"] = "item", 		["image"] = "newspaper.png", 				["unique"] = true,	 	["useable"] = true,			["created"] = nil,		["decay"] = nil, 	["shouldClose"] = false, ["combinable"] = nil,   ["description"] = "A newspaper"},

```
Also make sure the images are in qb-inventory>html>images

## Adding print actions (to instantly give items) to QB-radialmenu:
If you want to have the options to hand over business cards etc to nearest player then add this where you want it in the `config.lua` for `qb-radialmenu` (suggestion: after interactions, at line 95 for us at least). Any new item you add to the `config.lua` for `cw-prints` needs to be added here also if you want it to show up. Just set the `id` to the same thing as what you name your item and it should work!
```
{
    id = 'prints',
    title = 'Prints',
    icon = 'address-card',
    items = {
        {
            id = 'business_card',
            title = 'Give Business Card',
            icon = 'address-card',
            type = 'client',
            event = 'cw-prints:client:GivePrint',
            shouldClose = true
        }, {
            id = 'flyer',
            title = 'Give Flyer',
            icon = 'scroll',
            type = 'client',
            event = 'cw-prints:client:GivePrint',
            shouldClose = true
        }, {
            id = 'coupon',
            title = 'Give Coupon',
            icon = 'percent',
            type = 'client',
            event = 'cw-prints:client:GivePrint',
            shouldClose = true
        }, {
            id = 'menu',
            title = 'Give Menu',
            icon = 'file-alt',
            type = 'client',
            event = 'cw-prints:client:GivePrint',
            shouldClose = true
        }
    }
}
``` 

## Adding text to QB-inventory
If you want to make the bussiness name show up in QB-Inventory:
Open `app.js` in `qb-inventory`. In the function `FormatItemInfo` you will find several if statements. Head to the bottom of these and add this before the second to last `else` statement (after the `else if` that has `itemData.name == "labkey"`). Then add this between them:
```
else if (itemData.name == "coupon" || itemData.name == "business_card" || itemData.name == "flyer") {
            $(".item-info-title").html("<p>" + itemData.label + "</p>");
            $(".item-info-description").html("<p>Business: " + itemData.info.business + "</p>");
        }
```
## Adding text to Ox_Inventory
Kudos to [Khatrie](https://github.com/Khatrie) for this 🙏
If you want to use ox_inventory you can toggle it in the Config.Lua. Simply set Config.Inv to 'ox' if you want to use that rather than qb-inventory!
# Dependencies
* qb-target - https://github.com/BerkieBb/qb-target
