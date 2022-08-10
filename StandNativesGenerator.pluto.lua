local json_decode = require('json').decode
local setmetatable = setmetatable
local io_open = io.open

local ParamTypePushHandler <const> = setmetatable(
    {
        ["Any"]         =   ";i+=1;push_arg_int(args[i])",
        ["Any*"]        =   ";i+=1;push_arg_pointer(args[i])",
        ["Blip"]        =   ";i+=1;push_arg_int(args[i])",
        ["Blip*"]       =   ";i+=1;push_arg_pointer(args[i])",
        ["BOOL"]        =   ";i+=1;push_arg_bool(args[i])",
        ["BOOL*"]       =   ";i+=1;push_arg_pointer(args[i])",
        ["Cam"]         =   ";i+=1;push_arg_int(args[i])",
        ["char*"]       =   ";i+=1;push_arg_pointer(args[i])",
        ["Entity"]      =   ";i+=1;push_arg_int(args[i])",
        ["Entity*"]     =   ";i+=1;push_arg_pointer(args[i])",
        ["FireId"]      =   ";i+=1;push_arg_int(args[i])",
        ["float"]       =   ";i+=1;push_arg_float(args[i])",
        ["float*"]      =   ";i+=1;push_arg_pointer(args[i])",
        ["FloatV3"]     =   ";i+=1;i=i+push_arg_FloatV3(args[i])",
        ["Hash"]        =   ";i+=1;push_arg_int(args[i])",
        ["Hash*"]       =   ";i+=1;push_arg_pointer(args[i])",
        ["int"]         =   ";i+=1;push_arg_int(args[i])",
        ["int*"]        =   ";i+=1;push_arg_pointer(args[i])",
        ["Interior"]    =   ";i+=1;push_arg_int(args[i])",
        ["Object"]      =   ";i+=1;push_arg_int(args[i])",
        ["Object*"]     =   ";i+=1;push_arg_pointer(args[i])",
        ["Ped"]         =   ";i+=1;push_arg_int(args[i])",
        ["Ped*"]        =   ";i+=1;push_arg_pointer(args[i])",
        ["Pickup"]      =   ";i+=1;push_arg_int(args[i])",
        ["Player"]      =   ";i+=1;push_arg_int(args[i])",
        ["ScrHandle"]   =   ";i+=1;push_arg_int(args[i])",
        ["ScrHandle*"]  =   ";i+=1;push_arg_pointer(args[i])",
        ["Vehicle"]     =   ";i+=1;push_arg_int(args[i])",
        ["Vehicle*"]    =   ";i+=1;push_arg_pointer(args[i])",
        ["const char*"] =   ";i+=1;push_arg_string(args[i])",
        ["Vector3"]     =   ";i+=1;push_arg_vector3(args[i])",
        ["Vector3*"]    =   ";i+=1;push_arg_pointer(args[i])",
    },
    {
        __index =   function(Self, Key)
                        local TypePushHandlerString = ";i+=1;push_arg_%s(args[i])":format(Key)
                        Self[Key] = TypePushHandlerString
                        print("\n", 'WARNING: Push arg type "%s" is undefined.':format(Key), "\n")
                        return TypePushHandlerString
                    end
    }
)
local ParamTypeReturnHandler <const> = setmetatable(
    {
        ["Any"]         =   'end_call("%s")return get_return_value_int()end,\n',
        ["Any*"]        =   'end_call("%s")return get_return_value_int()end,\n',
        ["Blip"]        =   'end_call("%s")return get_return_value_int()end,\n',
        ["BOOL"]        =   'end_call("%s")return get_return_value_bool()end,\n',
        ["Cam"]         =   'end_call("%s")return get_return_value_int()end,\n',
        ["Entity"]      =   'end_call("%s")return get_return_value_int()end,\n',
        ["FireId"]      =   'end_call("%s")return get_return_value_int()end,\n',
        ["float"]       =   'end_call("%s")return get_return_value_float()end,\n',
        ["Hash"]        =   'end_call("%s")return get_return_value_int()end,\n',
        ["int"]         =   'end_call("%s")return get_return_value_int()end,\n',
        ["Interior"]    =   'end_call("%s")return get_return_value_int()end,\n',
        ["Object"]      =   'end_call("%s")return get_return_value_int()end,\n',
        ["Ped"]         =   'end_call("%s")return get_return_value_int()end,\n',
        ["Pickup"]      =   'end_call("%s")return get_return_value_int()end,\n',
        ["Player"]      =   'end_call("%s")return get_return_value_int()end,\n',
        ["ScrHandle"]   =   'end_call("%s")return get_return_value_int()end,\n',
        ["Vehicle"]     =   'end_call("%s")return get_return_value_int()end,\n',
        ["const char*"] =   'end_call("%s")return get_return_value_string()end,\n',
        ["Vector3"]     =   'end_call("%s")return get_return_value_vector3()end,\n',
        ["void"]        =   'end_call("%s")end,\n',
                    
    },
    {
        __index =   function(Self, Key)
                        local TypeReturnHandlerString = 'end_call("%s")return get_return_value_%s()end,\n':format("%s", Key)
                        Self[Key] = TypeReturnHandlerString
                        print("\n", 'WARNING: Return type "%s" is undefined.':format(Key), "\n")
                        return TypeReturnHandlerString
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
local push_arg_FloatV3 <const> = function(i, args)
    pluto_switch type(i) do
        case "number":
            push_arg_float(args[i])
            push_arg_float(args[i+1])
            push_arg_float(args[i+2])
            return 2
        pluto_default:
            push_arg_vector3(args[i])
            return 0
    end
end

]]:format(NativeGenerationTime, NativeGenerationTime))
    
    for Namespace, HashTableDefinitions in NativeDb do
        NativeWrapperLib:write(Namespace.."={\n")
        for FunctionHash, FunctionData in HashTableDefinitions do
            do
                local FunctionName = FunctionData.name
                if FunctionName:startswith "0x" then
                    FunctionName = "_"..FunctionName
                end
                NativeWrapperLib:write('    ["%s"]=function(...)local args,i={...},0 begin_call()':format(FunctionName))
            end
            do
                local FunctionParams <const> = FunctionData.params
                local JumpAhead = 0
                for i=1, #FunctionParams do
                    if JumpAhead == 0 then
                        local ParamType = FunctionParams[i].type
                        local ParamTypeString = ParamTypePushHandler[ParamType]
                        
                        if ParamType == "float"
                        and (FunctionParams[i+1] and FunctionParams[i+1].type == "float")
                        and (FunctionParams[i+2] and FunctionParams[i+2].type == "float")
                        then
                            ParamTypeString = ParamTypePushHandler["FloatV3"]
                            JumpAhead+=2
                        end
                        NativeWrapperLib:write(ParamTypeString)
                    else
                        JumpAhead-=1
                    end
                end
            end
            NativeWrapperLib:write(ParamTypeReturnHandler[FunctionData.return_type]:format(FunctionHash:sub(3)))
        end
        NativeWrapperLib:write("}\n")
    end
end