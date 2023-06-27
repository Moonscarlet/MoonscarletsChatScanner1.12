require "functional"
function print(str)
  	DEFAULT_CHAT_FRAME:AddMessage(str);
end

function printColored(str, r,g,b)
  	DEFAULT_CHAT_FRAME:AddMessage(str, r, g, b);
end

function string.gmatch(s,pattern)
	local words = {}
	local start, finish = 1, 1
	repeat
	  start, finish = string.find(s, pattern, finish)
	  if start then
		local word = string.sub(s, start, finish)
		-- print(word)
		table.insert(words,word)
		finish = finish + 1
	  end
	until not start
	return words
end

local frameScanner = CreateFrame("FRAME")
frameScanner:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frameScanner:RegisterEvent("PLAYER_LOGOUT"); -- Fired when user is logging out

frameScanner:SetScript("OnEvent", function(self, ...)
    if event == "ADDON_LOADED" then
        print("MoonscarletsChatScanner Addon loaded")
		-- for _,w in ipairs(whitelistedStringTable) do
			-- print (w)
		-- end
    elseif event == "PLAYER_LOGOUT" then
         print("Player is logging out")
    end
end)
 

local messageCheckDuplicate
local enabled = true


local commands =
{
    ["help"] = function()
        print("Commands : ")
        print(" ")
        print("/CS add [String]")
        print('Description : Adds a string to whitelist (underscore for spaces - | for must match all - "-"to exclude a word)')
        print(" ")
        print("/CS del [key number]")
        print("Description : Removes string by number in the list")
        print(" ")
        print("/CS clear")
        print("Description : Clears the list")
        print(" ")
        print("/CS list")
        print("Description : Prints the watchlist")
        print(" ")
		
        print("/CS addplayer [String]")
        print('Description : Adds a player to blacklist')
        print(" ")
        print("/CS delplayer [key number]")
        print("Description : Removes a player by number from the blacklist")
        print(" ")
        print("/CS clearplayers")
        print("Description : Clears the blacklisted players list")
        print(" ")
        print("/CS players")
        print("Description : Prints the blacklisted players")
        print(" ")
		
		print("/CS enable")
        print("Description : Enables scanning")
        print(" ")
		print("/CS disable")
        print("Description : Disables scanning")
		print("/CS master")
        print("Description : play notification even if sounds are muted")
    end,
 
    ["add"] = function(textstr)
        if whitelistedStringTable == nil then
            print("--")
            print("No string table detected, creating a new, empty one")
            whitelistedStringTable = {nil}
        end
		textstr= string.gsub(textstr,"_", " ")
        table.insert(whitelistedStringTable, textstr)
		print("--")
		print("Added "..textstr)
    end,
 
    ["del"] = function(key)
		print("--")
		print("Removed "..key..":"..whitelistedStringTable[tonumber(key)])    
		table.remove(whitelistedStringTable, key)
    end,
	
    ["clear"] = function()
		whitelistedStringTable={}
        print("--")
        print("Wiped")
    end,
 
     ["enable"] = function()
		enabled= true
        print("--")
        print("Enabled")
    end,

     ["disable"] = function()
		enabled= false
        print("--")
        print("Disabled")
    end,
	

    ["list"] = function()
		print("--")
		print("Enabled: ".. tostring(enabled))
        print("Watchlist:")
        if (whitelistedStringTable == nil) then
             print("Watchlist is empty")
			 return
        end
 
        for i,v in ipairs(whitelistedStringTable) do
            print(i..":"..v)
        end
    end,

    ["addplayer"] = function(textstr)
        if whitelistedStringTablePlayersChat == nil then
            print("--")
            print("No string table detected, creating a new, empty one")
            whitelistedStringTablePlayersChat = {}
			table.insert(whitelistedStringTablePlayersChat, "")
        end
        table.insert(whitelistedStringTablePlayersChat, textstr)
    end,
 
    ["delplayer"] = function(key)
		print("--")
		print("Removed "..key)    
		table.remove(whitelistedStringTablePlayersChat, key)
    end,
	
    ["clearplayers"] = function()
        wipe(whitelistedStringTablePlayersChat)
        print("--")
        print("Wiped")
    end,
	
	["players"] = function()
        print("Ignored players:")
        if (whitelistedStringTablePlayersChat == nil) then
             print("Ignore list is empty")
			 return
        end
 
        for i,v in ipairs(whitelistedStringTablePlayersChat) do
            print(i,v)
        end
    end
	
}


function HandleSlashCommands(str) 
	-- table.insert(whitelistedStringTable, "WHATEVER1111")------------------TEST

	-- for i,v in ipairs(whitelistedStringTable) do
            -- print(i..":"..v)
	-- end
				
    if (string.len(str) == 0) then
        print("Command not recognized")
        -- print("Command not recognized, showing help")
        -- commands.help()
        return;    
    end
   
    local args = {};
    for _, arg in ipairs( string.gmatch(str,"%S+")) do
        if (string.len(arg) > 0) then
            table.insert(args, string.lower(arg));
        end
		
		if (not commands[args[1]]) then
			print("Command not recognized, showing help")
			commands.help()
			return;    
		end		
    end
   	
	for id, arg in ipairs(args) do
		
        if (getn(args)== 1) then
            -- commands.list()
            commands[arg]()
			return
			
		elseif (getn(args)== 2) then
			commands[arg](args[2])
			return
        end
    end
end

SLASH_CS1 = "/CS"
SlashCmdList["CS"] = HandleSlashCommands





local chatFrameScanner = CreateFrame("Frame")

chatFrameScanner:RegisterEvent("CHAT_MSG_CHANNEL")
chatFrameScanner:RegisterEvent("CHAT_MSG_GUILD")
chatFrameScanner:RegisterEvent("CHAT_MSG_YELL")
chatFrameScanner:RegisterEvent("CHAT_MSG_PARTY")
chatFrameScanner:RegisterEvent("CHAT_MSG_SAY")


-- local whitelistedStringTable={		'onyxia',		'nef',		'buff',		'head',		'free',		'stock',		'sfk',}
		
chatFrameScanner:SetScript("OnEvent", function(self, ...)
	if not enabled then return end
    -- print("Event: " .. event)
    -- print("Chat Message: " .. arg1)
    -- print("Author: " .. arg2)
    -- print("Language: " .. arg3)
    -- print("Channel Name: " .. arg4)
    -- print("Target: " .. arg5)
    -- print("Flags: " .. arg6)
    -- print("Zone ID: " .. arg7)
    -- print("Channel Number: " .. arg8)
    -- print("Channel Base Name: " .. arg9)
    -- print("Line ID: " .. arg11)
    -- print("Sender GUID: " .. arg12)
	
	-- print("Chat Message: " .. arg1)
    -- print("Author: " .. arg2)
	-- print("Channel Base Name: " .. arg9)
	message = arg1
	messageLower = string.lower(arg1)
	player = arg2
	chanName = arg9
	
	if chanName=='LFT' then return end--turtle addon ignore
	
	for _, v in ipairs(whitelistedStringTable) do
		v = string.lower(v)
		local checkFound = true
		
		for _,w in string.gmatch(v, "([^\|]+)") do	--split each word in whitelisttable by |
			w = string.lower(w)
			firstChar = string.sub(w, 1, 1)
			wordWithoutfirstChar = string.sub(w, 2)
			
		   if (firstChar~= "-" and not string.find(messageLower,w)) or (firstChar== "-" and string.find(messageLower,wordWithoutfirstChar)) then 
		   --------------if keyword doesn't start with - and keyword not 	found in msg		OR 		keyword starts with - and keyword found in msg THEN ignore this msg
			checkFound= false
		   end
		end

		
		if checkFound then	
			-- if string.find(messageLower, v) then
			playerLink= "|Hplayer:"..player.."|h"..player.."|h" --GetPlayerLink(characterName,linkDisplayText)
			
			msg= "|cAAFF0000FOUND(|r|cff92ff58"..string.upper(v).."|r|cffFF0000): |r|cff5892ff\n["..string.upper(chanName).."]|r "..playerLink.."|cff5892ff: "..message.."|r"
			print(msg)
			PlaySoundFile("Interface\\AddOns\\ChatScanner\\CatDeath.ogg")
			return
			-- end
		end
	end	
end)



