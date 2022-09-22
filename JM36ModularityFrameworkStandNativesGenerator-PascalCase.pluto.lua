local json_decode = require('json').decode
local setmetatable = setmetatable
local io_open = io.open
local table_concat = table.concat
local math_min = math.min
local string_byte = string.byte
local table_sort = table.sort
local collectgarbage = collectgarbage

local string_UpperFirstLowerElse <const> = function(string)
	return string:sub(1,1):upper()..string:sub(2):lower()
end

local table_sort_func <const> = function(inputA,inputB)
	return inputA[1] < inputB[1]
end

local ParamTypeReturnHandler <const> = setmetatable(
	{
		["Any"]			=	'end_call("%s")return get_return_value_int()end,\n',
		["Any*"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["Blip"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["BOOL"]		=	'end_call("%s")return get_return_value_bool()end,\n',
		["Cam"]			=	'end_call("%s")return get_return_value_int()end,\n',
		["Entity"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["FireId"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["float"]		=	'end_call("%s")return get_return_value_float()end,\n',
		["Hash"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["int"]			=	'end_call("%s")return get_return_value_int()end,\n',
		["Interior"]	=	'end_call("%s")return get_return_value_int()end,\n',
		["Object"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["Ped"]			=	'end_call("%s")return get_return_value_int()end,\n',
		["Pickup"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["Player"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["ScrHandle"]	=	'end_call("%s")return get_return_value_int()end,\n',
		["Vehicle"]		=	'end_call("%s")return get_return_value_int()end,\n',
		["const char*"] =	'end_call("%s")return get_return_value_string()end,\n',
		["Vector3"]		=	'end_call("%s")return get_return_value_vector3()end,\n',
		["void"]		=	'end_call("%s")end,\n',
	},
	{
		__index =	function(Self, Key)
						local TypeReturnHandlerString = 'end_call("%s")return get_return_value_%s()end,\n':format("%s", Key)
						Self[Key] = TypeReturnHandlerString
						print("\n", 'WARNING: Return type "%s" is undefined.':format(Key), "\n")
						return TypeReturnHandlerString
					end
	}
)
local ParamTypePushHandler_VarArgs <const> = setmetatable(
	{
		["Any"]			=	";i+=1;push_arg_int(args[i])",
		["Any*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Blip"]		=	";i+=1;push_arg_int(args[i])",
		["Blip*"]		=	";i+=1;push_arg_pointer(args[i])",
		["BOOL"]		=	";i+=1;push_arg_bool(args[i])",
		["BOOL*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Cam"]			=	";i+=1;push_arg_int(args[i])",
		["char*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Entity"]		=	";i+=1;push_arg_int(args[i])",
		["Entity*"]		=	";i+=1;push_arg_pointer(args[i])",
		["FireId"]		=	";i+=1;push_arg_int(args[i])",
		["float"]		=	";i+=1;push_arg_float(args[i])",
		["float*"]		=	";i+=1;push_arg_pointer(args[i])",
		["FloatV3"]		=	";i+=1;i=i+push_arg_FloatV3(args,i)",
		["Hash"]		=	";i+=1;push_arg_int(args[i])",
		["Hash*"]		=	";i+=1;push_arg_pointer(args[i])",
		["int"]			=	";i+=1;push_arg_int(args[i])",
		["int*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Interior"]	=	";i+=1;push_arg_int(args[i])",
		["Object"]		=	";i+=1;push_arg_int(args[i])",
		["Object*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Ped"]			=	";i+=1;push_arg_int(args[i])",
		["Ped*"]		=	";i+=1;push_arg_pointer(args[i])",
		["Pickup"]		=	";i+=1;push_arg_int(args[i])",
		["Player"]		=	";i+=1;push_arg_int(args[i])",
		["ScrHandle"]	=	";i+=1;push_arg_int(args[i])",
		["ScrHandle*"]	=	";i+=1;push_arg_pointer(args[i])",
		["Vehicle"]		=	";i+=1;push_arg_int(args[i])",
		["Vehicle*"]	=	";i+=1;push_arg_pointer(args[i])",
		["const char*"] =	";i+=1;push_arg_string(args[i])",
		["Vector3"]		=	";i+=1;push_arg_vector3(args[i])",
		["Vector3*"]	=	";i+=1;push_arg_pointer(args[i])",
	},
	{
		__index =	function(Self, Key)
						local TypePushHandlerString = ";i+=1;push_arg_%s(args[i])":format(Key)
						Self[Key] = TypePushHandlerString
						print("\n", 'WARNING: Push arg VarArg type "%s" is undefined.':format(Key), "\n")
						return TypePushHandlerString
					end
	}
)
local ParamTypePushHandler_StcArgs <const> = setmetatable(
	{
		["Any"]			=	"push_arg_int(%s)",
		["Any*"]		=	"push_arg_pointer(%s)",
		["Blip"]		=	"push_arg_int(%s)",
		["Blip*"]		=	"push_arg_pointer(%s)",
		["BOOL"]		=	"push_arg_bool(%s)",
		["BOOL*"]		=	"push_arg_pointer(%s)",
		["Cam"]			=	"push_arg_int(%s)",
		["char*"]		=	"push_arg_pointer(%s)",
		["Entity"]		=	"push_arg_int(%s)",
		["Entity*"]		=	"push_arg_pointer(%s)",
		["FireId"]		=	"push_arg_int(%s)",
		["float"]		=	"push_arg_float(%s)",
		["float*"]		=	"push_arg_pointer(%s)",
		["Hash"]		=	"push_arg_int(%s)",
		["Hash*"]		=	"push_arg_pointer(%s)",
		["int"]			=	"push_arg_int(%s)",
		["int*"]		=	"push_arg_pointer(%s)",
		["Interior"]	=	"push_arg_int(%s)",
		["Object"]		=	"push_arg_int(%s)",
		["Object*"]		=	"push_arg_pointer(%s)",
		["Ped"]			=	"push_arg_int(%s)",
		["Ped*"]		=	"push_arg_pointer(%s)",
		["Pickup"]		=	"push_arg_int(%s)",
		["Player"]		=	"push_arg_int(%s)",
		["ScrHandle"]	=	"push_arg_int(%s)",
		["ScrHandle*"]	=	"push_arg_pointer(%s)",
		["Vehicle"]		=	"push_arg_int(%s)",
		["Vehicle*"]	=	"push_arg_pointer(%s)",
		["const char*"] =	"push_arg_string(%s)",
		["Vector3"]		=	"push_arg_vector3(%s)",
		["Vector3*"]	=	"push_arg_pointer(%s)",
	},
	{
		__index =	function(Self, Key)
						local TypePushHandlerString = "push_arg_int(%s)":format(Key)--"push_arg_%s(%s)":format(Key)
						Self[Key] = TypePushHandlerString
						print("\n", 'WARNING: Push arg StcArg type "%s" is undefined.':format(Key), "\n")
						return TypePushHandlerString
					end
	}
)
local StcArgs_StringSubs <const> = setmetatable(
	{
		["end"]		=	"_end",
		["repeat"]	=	"_repeat",
	},
	{
		__index =	function(Self, Key)
						return Key
					end
	}
)

local NativeDbJsonFile = io_open'natives.json'
if NativeDbJsonFile then
	local NativeDb = json_decode(NativeDbJsonFile:read('a'))
	NativeDbJsonFile:close()
	
	local NativeGenerationTime = os.unixseconds()
	
	local NativeWrapperLib = io_open("natives-%s.lua":format(NativeGenerationTime), "w")
	
	NativeWrapperLib:write(
[[-- DONT RENAME THIS FILE
-- This should be natives-%s.lua wherein %s represents the version.
-- Any given version may not be compatible with any given script using this library.
-- Additionally, you should bundle the version of this library that you are developing against with your script, so "installing" your script is a simple drag & drop operation.

local native_invoker = native_invoker
local begin_call, end_call, get_return_value_bool, get_return_value_float, get_return_value_int, get_return_value_string, get_return_value_vector3, push_arg_bool, push_arg_float, push_arg_int, push_arg_pointer, push_arg_string, push_arg_vector3 = native_invoker.begin_call, native_invoker.end_call, native_invoker.get_return_value_bool, native_invoker.get_return_value_float, native_invoker.get_return_value_int, native_invoker.get_return_value_string, native_invoker.get_return_value_vector3, native_invoker.push_arg_bool, native_invoker.push_arg_float, native_invoker.push_arg_int, native_invoker.push_arg_pointer, native_invoker.push_arg_string, native_invoker.push_arg_vector3

local type = type
local push_arg_FloatV3 <const> = function(args,i)
	local arg = args[i]
	pluto_switch type(arg) do
		case "number":
			push_arg_float(arg)
			push_arg_float(args[i+1])
			push_arg_float(args[i+2])
			return 2
		pluto_default:
			push_arg_float(arg.x)
			push_arg_float(arg.y)
			push_arg_float(arg.z)
			return 0
	end
end

]]:format(NativeGenerationTime, NativeGenerationTime))
	
	local FunctionArray, NumFunctionArray = {}, 0
	do
		for Namespace, HashTableDefinitions in NativeDb do
			for FunctionHash, FunctionData in HashTableDefinitions do
				local FunctionName = FunctionData.name
				if FunctionName:startswith "0x" then
					FunctionName = "_"..FunctionName
				elseif not FunctionName:startswith "_0x" then
					FunctionName = FunctionName:split "_"
					for i=1, #FunctionName do
						FunctionName[i] = string_UpperFirstLowerElse(FunctionName[i])
					end
					FunctionName = table_concat(FunctionName)
				end
				NumFunctionArray+=1;FunctionArray[NumFunctionArray]={FunctionName,FunctionData,FunctionHash}
			end
		end
		table_sort(FunctionArray, table_sort_func)
	end
	NativeDb = nil
	
	collectgarbage()
	
	NativeWrapperLib:write(
[[local OldNames <const> =
{
]])
	
	do
		local OldNamesArray, NumOldNamesArray = {}, 0
		for i=1, NumFunctionArray do
			local FunctionData = FunctionArray[i]
			local FunctionProperties = FunctionData[2]
			local OldNames = FunctionProperties.old_names
			
			if OldNames then
				for j=1, #OldNames do
					local OldName = OldNames[j]
					if OldName:startswith "0x" then
						OldName = "_"..OldName
					elseif not OldName:startswith "_0x" then
						OldName = OldName:split "_"
						for k=1, #OldName do
							OldName[k] = string_UpperFirstLowerElse(OldName[k])
						end
						OldName = table_concat(OldName)
					end
					NumOldNamesArray+=1;OldNamesArray[NumOldNamesArray]={OldName,FunctionData[1]}
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
		local FunctionData = FunctionArray[i]
		local FunctionProperties = FunctionData[2]
		
		local HasSuspectedV3
		local FunctionParams = FunctionProperties.params
		local NumFunctionParams = #FunctionParams
		
		if NumFunctionParams > 2 then
			for j=1, NumFunctionParams do
				if FunctionParams[j].type == "float"
				and (FunctionParams[j+1] and FunctionParams[j+1].type == "float")
				and (FunctionParams[j+2] and FunctionParams[j+2].type == "float")
				then
					HasSuspectedV3 = j-1
					break
				end
			end
		end
		
		if not HasSuspectedV3 then
			if NumFunctionParams == 0 then
				NativeWrapperLib:write('		["%s"]=function()begin_call()':format(FunctionData[1]))
			else
				local FunctionParamsStringArrayTable = {}
				for j=1, NumFunctionParams do
					FunctionParamsStringArrayTable[j] = StcArgs_StringSubs[FunctionParams[j].name]
				end
				NativeWrapperLib:write('		["%s"]=function(%s)begin_call()':format(FunctionData[1], table_concat(FunctionParamsStringArrayTable, ",")))
				for j=1, NumFunctionParams do
					local FunctionParam = FunctionParams[j]
					NativeWrapperLib:write(ParamTypePushHandler_StcArgs[FunctionParam.type]:format(StcArgs_StringSubs[FunctionParam.name]))
				end
			end
		else
			NativeWrapperLib:write('		["%s"]=function(...)local args,i={...},0 begin_call()':format(FunctionData[1]))
			local JumpAhead = 0
			for j=1, NumFunctionParams do
				if JumpAhead == 0 then
					local ParamType = FunctionParams[j].type
					local ParamTypeString = ParamTypePushHandler_VarArgs[ParamType]
					if j > HasSuspectedV3
					and ParamType == "float"
					and (FunctionParams[j+1] and FunctionParams[j+1].type == "float")
					and (FunctionParams[j+2] and FunctionParams[j+2].type == "float")
					then
						ParamTypeString = ParamTypePushHandler_VarArgs["FloatV3"]
						JumpAhead+=2
					end
					NativeWrapperLib:write(ParamTypeString)
				else
					JumpAhead-=1
				end
			end
		end
		NativeWrapperLib:write(ParamTypeReturnHandler[FunctionProperties.return_type]:format(FunctionData[3]:sub(3)))
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
end