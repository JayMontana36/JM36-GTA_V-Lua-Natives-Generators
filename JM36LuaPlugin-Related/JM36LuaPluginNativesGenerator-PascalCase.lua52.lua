local json_decode = require('json').decode
local setmetatable = setmetatable
local io_open = io.open
local table_concat = table.concat
local math_min = math.min
local string_byte = string.byte
local table_sort = table.sort
local collectgarbage = collectgarbage
local pairs = pairs

local string_UpperFirstLowerElse = function(string)
	return string:sub(1,1):upper()..string:sub(2):lower()
end
local string_FiveMify = function(string)
	string = string:split("_")
	for j=1,#string do
		string[j] = string_UpperFirstLowerElse(string[j])
	end
	return table_concat(string)
end

local table_sort_func = function(inputA,inputB)
	return inputA[1] < inputB[1]
end

local NativeDbJsonFile = io_open(__Internal_Path..'natives.json')
if NativeDbJsonFile then
	local NativeDb = json_decode(NativeDbJsonFile:read('*a'))
	NativeDbJsonFile:close()

	local NativeGenerationTime = os.time()

	local NativeWrapperLib = io_open(__Internal_Path..("0A_Natives-%s.lua"):format(NativeGenerationTime), "w")

	NativeWrapperLib:write(
([[-- DONT RENAME THIS FILE
-- This should be 0A_Natives-%s.lua wherein %s represents the version.

JM36_GTAV_LuaPlugin_FunctionRemapper_Version = %s
]]):format(NativeGenerationTime, NativeGenerationTime, os.date("%Y%m%d.0",NativeGenerationTime)))

	local NamespacesLP	= {
		PLAYER			= true,
		ENTITY			= true,
		PED				= true,
		VEHICLE			= true,
		OBJECT			= true,
		AI				= true,
		GAMEPLAY		= true,
		AUDIO			= true,
		CUTSCENE		= true,
		INTERIOR		= true,
		CAM				= true,
		WEAPON			= true,
		ITEMSET			= true,
		STREAMING		= true,
		SCRIPT			= true,
		UI				= true,
		GRAPHICS		= true,
		STATS			= true,
		BRAIN			= true,
		MOBILE			= true,
		APP				= true,
		TIME			= true,
		PATHFIND		= true,
		CONTROLS		= true,
		DATAFILE		= true,
		FIRE			= true,
		DECISIONEVENT	= true,
		ZONE			= true,
		ROPE			= true,
		WATER			= true,
		WORLDPROBE		= true,
		NETWORK			= true,
		NETWORKCASH		= true,
		DLC1			= true,
		DLC2			= true,
		SYSTEM			= true,
		DECORATOR		= true,
		SOCIALCLUB		= true,
		UNK				= true,
		UNK1			= true,
		UNK2			= true,
		UNK3			= true,
	}
	local NamespacesLPArray = {
		"PLAYER",
		"ENTITY",
		"PED",
		"VEHICLE",
		"OBJECT",
		"AI",
		"GAMEPLAY",
		"AUDIO",
		"CUTSCENE",
		"INTERIOR",
		"CAM",
		"WEAPON",
		"ITEMSET",
		"STREAMING",
		"SCRIPT",
		"UI",
		"GRAPHICS",
		"STATS",
		"BRAIN",
		"MOBILE",
		"APP",
		"TIME",
		"PATHFIND",
		"CONTROLS",
		"DATAFILE",
		"FIRE",
		"DECISIONEVENT",
		"ZONE",
		"ROPE",
		"WATER",
		"WORLDPROBE",
		"NETWORK",
		"NETWORKCASH",
		"DLC1",
		"DLC2",
		"SYSTEM",
		"DECORATOR",
		"SOCIALCLUB",
		"UNK",
		"UNK1",
		"UNK2",
		"UNK3",
	}
	local NamespacesLPArrayNum = #NamespacesLPArray
	
	local _G = _G
	
	local FunctionArray, NumFunctionArray = {}, 0
	do
		for Namespace, HashTableDefinitions in pairs(NativeDb) do
			local NamespaceTarget = NamespacesLP[Namespace] and Namespace
			for FunctionHash, FunctionData in pairs(HashTableDefinitions) do
				FunctionHash = "_"..FunctionHash
				local FunctionCurName = FunctionData.name
				if string.startsWith(FunctionCurName, "0x") then
					FunctionCurName = "_"..FunctionCurName
				end
				local FunctionOldName = FunctionData.old_names
				if FunctionOldName then
					for i=1, #FunctionOldName do
						local _FunctionOldName = FunctionOldName[i]
						if string.startsWith(_FunctionOldName, "0x") then
							FunctionOldName[i] = "_".._FunctionOldName
						end
					end
				end
				local SearchArray = {FunctionHash,FunctionCurName}
				if FunctionOldName then
					for i=1, #FunctionOldName do
						SearchArray[2+i] = FunctionOldName[i]
					end
				end
				local SearchArrayNum = #SearchArray
				
				if not NamespaceTarget then
					for i=1, NamespacesLPArrayNum do
						local _NamespaceLP = NamespacesLPArray[i]
						local NamespaceTable = _G[_NamespaceLP]
						for j=1, SearchArrayNum do
							local Search = SearchArray[j]
							if NamespaceTable and NamespaceTable[Search] then
								NamespaceTarget = _NamespaceLP
								break
							end
						end
					end
				end
				
				if NamespaceTarget then
					local NamespaceTable = _G[NamespaceTarget]
					for j=1, SearchArrayNum do
						local Search = SearchArray[j]
						if NamespaceTable and NamespaceTable[Search] then
							NumFunctionArray = NumFunctionArray + 1
							FunctionArray[NumFunctionArray] = {FunctionCurName,("%s.%s"):format(NamespaceTarget,Search),SearchArray,SearchArrayNum}
							break
						end
					end
				end
			end
		end
		table_sort(FunctionArray, table_sort_func)
	end
	NativeDb = nil
	
	collectgarbage()
	
	NativeWrapperLib:write(
[[local OldNames =
{
]])
	do
		local OldNamesArray, NumOldNamesArray = {}, 0
		for i=1, NumFunctionArray do
			local Function = FunctionArray[i]
			local FunctionCurName, FunctionNameArray, NumFunctionNameArray = Function[1], Function[3], Function[4]
			
			if not FunctionCurName:startsWith("_0x") then
				FunctionCurName = string_FiveMify(FunctionCurName)
			end
			
			if NumFunctionNameArray > 2 then
				for j=3,NumFunctionNameArray do
					local OldName = FunctionNameArray[j]
					OldName = string_FiveMify(OldName)
					FunctionNameArray[j] = OldName
					NumOldNamesArray = NumOldNamesArray + 1
					OldNamesArray[NumOldNamesArray] = {OldName,FunctionCurName}
				end
			end
		end
		table_sort(OldNamesArray, table_sort_func)
		for i=1, NumOldNamesArray do
			local OldNamesMap = OldNamesArray[i]
			local OldName, NewName = OldNamesMap[1], OldNamesMap[2]
			if OldName ~= NewName then
				NativeWrapperLib:write('	["%s"]="%s",\n':format(OldName,NewName))
			end
		end
	end
	NativeWrapperLib:write(
[[}
_G2.Natives_PascalCase = setmetatable
(
	{
]])
	for i=1, NumFunctionArray do
		local Function = FunctionArray[i]
		local FunctionName = Function[1]
		if not FunctionName:startsWith("_0x") then
			FunctionName = string_FiveMify(FunctionName)
		end
		--NativeWrapperLib:write(('		%s=%s,\n'):format(FunctionName,Function[2]))
		NativeWrapperLib:write(('		["%s"]=%s,\n'):format(FunctionName,Function[2]))
	end
	NativeWrapperLib:write(
[[	},
	{
		__index=function(Self,Key)
			local NewName = OldNames[Key]
			if NewName then
				local Value = Self[NewName]
				Self[Key] = Value
				do
					local ErrorSource
					do
						local DebugInfoArray, DebugInfoCount = {}, 1
						local debug_getinfo = debug.getinfo
						local DebugInfo
						repeat
							DebugInfoCount += 1
							DebugInfo = debug_getinfo(DebugInfoCount)
							DebugInfoArray[DebugInfoCount] = DebugInfo
						until DebugInfo == nil or DebugInfo.what == "main"
						if DebugInfo and DebugInfo.what == "main" then
							ErrorSource = DebugInfo
						else
							for Index=2,DebugInfoCount do
								DebugInfo = DebugInfoArray[Index]
								if DebugInfo.currentline ~= -1 and not DebugInfo.short_src:startswith "[string " then
									ErrorSource = DebugInfo
									break
								end
							end
						end
					end
					if ErrorSource then
						print(('[Heads Up - Native]\n"%s" is now known as "%s".\n%s:%s'):format(Key, NewName, ErrorSource.short_src, ErrorSource.currentline))
					else
						print(('[Heads Up - Native]\n"%s" is now known as "%s".\nNo additional information is available.'):format(Key, NewName))
					end
				end
				return Value
			end
		end
	}
)]])
	NativeWrapperLib:close()
end