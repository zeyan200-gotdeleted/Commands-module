# Command System


## Overview

---

## Setup and Initialization
1. **Place the Script**: The script must be placed in `ServerScriptService` to run on the server.
2. **Authorized Users**: Modify the `AllowedUserIds` table to include the User IDs of players allowed to use commands.
   ```lua
   local AllowedUserIds = {
       [1] = true, -- UserId 1
       [2] = true, -- UserId 2
       [3] = true  -- UserId 3
   }
   ```
3. **Command Module**: Create a `ModuleScript` (child of the script) to define commands. The system loads this module automatically.
4. **Run the System**: The system initializes and starts listening for chat messages when the script runs.

---

## Features

### Authorized Users
- Only players with User IDs listed in `AllowedUserIds` can execute commands.
- Unauthorized users' chat messages are ignored.

### Command Execution
- Commands are triggered by chat messages starting with `!` (e.g., `!kill playerName`).
- The system parses the command name and arguments, then executes the associated function.

### Player Targeting
- Commands can target:
  - **Specific players**: By partial or full username (e.g., `!kill bob`).
  - **All players**: Using `all` (e.g., `!kill all`).
  - **Self**: Using `me` or no argument (e.g., `!kill` or `!kill me`).
- If no matching players are found, the command defaults to the caller.

### Looping Commands
- Commands marked as `Loopable` can be executed repeatedly using the `loop` prefix (e.g., `!loopkill playerName`).
- Looping runs every second until stopped with the `unloop` prefix (e.g., `!unloopkill`).
- Loops are stored per user and command to allow multiple simultaneous loops.

### Command Aliases
- Commands can have alternate names (e.g., `!k` as an alias for `!kill`).
- Aliases are case-insensitive.

---

## Usage

### Defining Commands
Create a `ModuleScript` named `CommandList` (or similar) as a child of the main script. Example:
```lua
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

### Executing Commands
Authorized users can execute commands via chat. Examples:
- `!kill bob`: Kills the player with a name containing "bob".
- `!kill all`: Kills all players.
- `!loopkill bob`: Repeatedly kills "bob" every second.
- `!unloopkill`: Stops the looping kill command.
- `!heal me`: Heals the caller.

---

## Code Breakdown

### Services and Variables
- **Services**:
  - `Players`: Roblox service for accessing players.
  - `ServerScriptService`: Roblox service for server-side scripts.
- **AllowedUserIds**: A table mapping authorized User IDs to `true`.

### CommandSystem Class
- The system is implemented as a Lua class (`CommandSystem`) using metatables.
- Key properties:
  - `Commands`: Stores the loaded command definitions.
  - `LoopStorage`: Stores coroutines for looping commands.

### Key Methods
1. **CommandSystem.new()**
   - Creates a new instance of the Command System.
   - Initializes `Commands` and `LoopStorage`.
   - Calls `LoadCommands` to load the command module.

2. **CommandSystem:LoadCommands()**
   - Loads the `ModuleScript` (child of the script) containing command definitions.
   - Sets `self.Commands` to the module’s returned table or an empty table if no module is found.

3. **CommandSystem:FindPlayers(caller, arg)**
   - Resolves the target players for a command based on the provided argument.
   - Returns:
     - A table of all players if `arg` is `"all"`.
     - The caller if `arg` is `"me"` or empty.
     - Players whose names partially match `arg` (case-insensitive).
     - The caller if no matches are found.

4. **CommandSystem:FindCommand(commandName)**
   - Searches for a command by name or alias (case-insensitive).
   - Returns the command table or `nil` if not found.

5. **CommandSystem:OnPlayerChatted(player, message)**
   - Handles chat messages from players.
   - Checks if the player is authorized (`AllowedUserIds`).
   - Processes messages starting with `!`:
     - Splits the message into command name and arguments.
     - Handles `loop` and `unloop` prefixes.
     - Finds and executes the command with resolved targets and arguments.
   - Supports looping via coroutines stored in `LoopStorage`.

6. **CommandSystem:Start()**
   - Sets up event listeners for:
     - `PlayerAdded`: Connects new players’ `Chatted` events.
     - Existing players’ `Chatted` events.
   - Starts the system.

---

## Example Command Module
```lua
-- CommandList (ModuleScript)

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

### Example Commands
- `!kick bob`: Kicks the player with a name containing "bob".
- `!speed me 50`: Sets the caller’s walk speed to 50.
- `!loopspeed all 100`: Repeatedly sets all players’ walk speed to 100 every second.
- `!unloopspeed`: Stops the looping speed command.

---

