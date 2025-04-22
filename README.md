-- Addition steps (these steps arent required if you are using the version from the roblox marketplace) 

(1). Insert a script, and name it what ever you like 
(2). Insert a module name it what you like, for this example I'll be referring to it as the "CommandHandler" 
(3). In that script add the following code 

`require(script.CommandHandler)`

(4). Insert a module name it what you like, for this example I'll be referring to it as the "CommandList" 

Inside the CommandHandler insert the code found in the github

Inside of the CommandList insert the code below:

```
 return {
    {
        Name = "kick",
        Aliases = { "boot" },
        Arguments = { "Player" },
        Loopable = false,
        Function = function(player, args)
            local reason = "You have been kicked"

            if args[2] then
                reason = table.concat(args, " ", 2)
            end

            player:Kick(reason)

            print("Kicked player: " .. player.Name .. " for: " .. reason)
        end
    },
}
```

-- Required steps

You are required to rank yourself inside of the CommandHandler script simply replace Zero with your Id. 

