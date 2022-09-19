local json_decode = require('json').decode
local setmetatable = setmetatable
local io_open = io.open
local table_concat = table.concat
local math_min = math.min
local string_byte = string.byte
local table_sort = table.sort
local collectgarbage = collectgarbage

--local _ = string_byte"_"
local table_sort_func <const> = function(inputA,inputB)
    inputA,inputB=inputA[1],inputB[1]
    if inputA == inputB then return false end
    
    local Limit = math_min(#inputA,#inputB) + 1
    
    for i=1,Limit do
        if i ~= Limit then
            local _inputA,_inputB = string_byte(inputA[i]),string_byte(inputB[i])
--          if _inputA ~= _ and _inputB ~= _ then
                if _inputA~=_inputB then
                    return _inputA < _inputB
                end
--          end
        else
            return inputA[i]==nil
        end
    end
end

local ParamTypeReturnHandler <const> = setmetatable(
    {
        ["Any"]         =   {'return ',''},
        ["Any*"]        =   {'return ',''},
        ["Blip"]        =   {'return ',':__tointeger()'},
        ["BOOL"]        =   {'return ',':__tointeger()~=0 '},
        ["Cam"]         =   {'return ',':__tointeger()'},
        ["Entity"]      =   {'return ',':__tointeger()'},
        ["FireId"]      =   {'return ',':__tointeger()'},
        ["float"]       =   {'return ',':__tonumber()'},
        ["Hash"]        =   {'return ',':__tointeger()'},
        ["int"]         =   {'return ',':__tointeger()'},
        ["Interior"]    =   {'return ',':__tointeger()'},
        ["Object"]      =   {'return ',':__tointeger()'},
        ["Ped"]         =   {'return ',':__tointeger()'},
        ["Pickup"]      =   {'return ',':__tointeger()'},
        ["Player"]      =   {'return ',':__tointeger()'},
        ["ScrHandle"]   =   {'return ',':__tointeger()'},
        ["Vehicle"]     =   {'return ',':__tointeger()'},
        ["const char*"] =   {'return ',':__tostring(true)'},
        ["Vector3"]     =   {'return ',':__tov3()'},
        ["void"]        =   {'return ',''},
                    
    },
    {
        __index =   function(Self, Key)
                        local TypeReturnHandlerString = {'return ',''}
                        Self[Key] = TypeReturnHandlerString
                        print("\n", 'WARNING: Return type "%s" is undefined.':format(Key), "\n")
                        return TypeReturnHandlerString
                    end
    }
)
local ParamTypePushHandler_StcArgs <const> = setmetatable(
    {
        ["Any"]         =   {"",""},
        ["Any*"]        =   {";%s=%s or ByteBuffer256()",",%s "},
        ["Blip"]        =   {"",""},
        ["Blip*"]       =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["BOOL"]        =   {"",""},
        ["BOOL*"]       =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()~=0 "},
        ["Cam"]         =   {"",""},
        ["char*"]       =   {";%s=%s or ByteBuffer256()",",%s:__tostring(true)"},
        ["Entity"]      =   {"",""},
        ["Entity*"]     =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["FireId"]      =   {"",""},
        ["float"]       =   {"",""},
        ["float*"]      =   {";%s=%s or ByteBuffer32()",",%s:__tointeger()"},
        ["Hash"]        =   {"",""},
        ["Hash*"]       =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["int"]         =   {"",""},
        ["int*"]        =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["Interior"]    =   {"",""},
        ["Object"]      =   {"",""},
        ["Object*"]     =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["Ped"]         =   {"",""},
        ["Ped*"]        =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["Pickup"]      =   {"",""},
        ["Player"]      =   {"",""},
        ["ScrHandle"]   =   {"",""},
        ["ScrHandle*"]  =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["Vehicle"]     =   {"",""},
        ["Vehicle*"]    =   {";%s=%s or ByteBuffer8()",",%s:__tointeger()"},
        ["const char*"] =   {";%s=%s or ByteBuffer256()",",%s:__tostring(true)"},
        ["Vector3"]     =   {"",""},
        ["Vector3*"]    =   {";%s=%s or ByteBuffer32()",",%s:__tov3()"},
    },
    {
        __index =   function(Self, Key)
                        local TypePushHandlerString = {"",""}
                        Self[Key] = TypePushHandlerString
                        print("\n", 'WARNING: Push arg VarArg type "%s" is undefined.':format(Key), "\n")
                        return TypePushHandlerString
                    end
    }
)
local StcArgs_StringSubs <const> = setmetatable(
    {
        ["end"]     =   "_end",
        ["repeat"]  =   "_repeat",
    },
    {
        __index =   function(Self, Key)
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

local native_call = native.call

]]:format(NativeGenerationTime, NativeGenerationTime))
    
    local NamespaceArray, NumNamespaceArray = {}, 0
    do
        for Namespace, HashTableDefinitions in NativeDb do
            NumNamespaceArray+=1;NamespaceArray[NumNamespaceArray]={Namespace,HashTableDefinitions}
        end
        table_sort(NamespaceArray, table_sort_func)
    end
    NativeDb = nil
    
    for h=1, NumNamespaceArray do
        local FunctionArray, i = {}, 0
        local HashTableDefinitions = NamespaceArray[h][2]
        for FunctionHash, FunctionData in HashTableDefinitions do
            i+=1;FunctionArray[i]={FunctionData.name,FunctionData,FunctionHash}
        end
        table_sort(FunctionArray, table_sort_func)
        NamespaceArray[h][2]=FunctionArray
    end
    
    collectgarbage()
    
    NativeWrapperLib:write(
[[local OldNames <const> =
{
]])
    
    do
        local OldNamesArray, NumOldNamesArray = {}, 0
        for h=1, NumNamespaceArray do
            local NamespaceData = NamespaceArray[h]
            local NamespaceFunctions = NamespaceData[2]
            
            for i=1, #NamespaceFunctions do
                local FunctionData = NamespaceFunctions[i]
                local FunctionProperties = FunctionData[2]
                local OldNames = FunctionProperties.old_names
                
                if OldNames then
                    for j=1, #OldNames do
                        NumOldNamesArray+=1;OldNamesArray[NumOldNamesArray]={OldNames[j],FunctionData[1]}
                    end
                end
            end
        end
        table_sort(OldNamesArray, table_sort_func)
        for i=1, NumOldNamesArray do
            local OldName = OldNamesArray[i]
            NativeWrapperLib:write('    ["%s"]="%s",\n':format(OldName[1],OldName[2]))
        end
    end
    
    NativeWrapperLib:write(
[[}

local metatable <const> =
{
    __index=function(Self,Key)
        local NewName = OldNames[Key]
        if NewName then
            local Function = Self[NewName]
            if Function then
                Self[Key] = Function
                do
                    local _, ErrorString = pcall(error,('Native "%s" is now known as "%s".'):format(Key,NewName),2)
                    ErrorString = ErrorString:split("\\")
                    ErrorString = ErrorString[#ErrorString]
                    print(("[Heads Up!] - %s"):format(ErrorString))
                end
                return Function
            end
        end
    end
}
local setmetatable = setmetatable

]])
    
    for h=1, NumNamespaceArray do
        local NamespaceData = NamespaceArray[h]
        NativeWrapperLib:write(NamespaceData[1].."=setmetatable({\n")
        local NamespaceFunctions = NamespaceData[2]
        for i=1, #NamespaceFunctions do
            local FunctionData = NamespaceFunctions[i]
            local FunctionProperties = FunctionData[2]
            local FunctionParams = FunctionProperties.params
            local NumFunctionParams = #FunctionParams
            local FunctionParamsString
            do
                local FunctionParamsStringArrayTable = {}
                for j=1, NumFunctionParams do
                    local FunctionParamName = StcArgs_StringSubs[FunctionParams[j].name]
                    FunctionParams[j].name = FunctionParamName
                    FunctionParamsStringArrayTable[j] = FunctionParamName
                end
                FunctionParamsString = table_concat(FunctionParamsStringArrayTable, ",")
            end
            do
                local FunctionName = FunctionData[1]
                if FunctionName:startswith "0x" then
                    FunctionName = "_"..FunctionName
                end
                NativeWrapperLib:write('    ["%s"]=function(%s)':format(FunctionName,FunctionParamsString))
            end
            for j=1, NumFunctionParams do
                local FunctionParam = FunctionParams[j]
                local FunctionParamName = FunctionParam.name
                NativeWrapperLib:write('%s':format(ParamTypePushHandler_StcArgs[FunctionParam.type][1]:format(FunctionParamName,FunctionParamName)))
            end
            do
                local ReturnType = ParamTypeReturnHandler[FunctionProperties.return_type]
                NativeWrapperLib:write('%snative_call(%s%s)%s':format(ReturnType[1], FunctionData[3], FunctionParamsString~="" and ","..FunctionParamsString or FunctionParamsString, ReturnType[2]))
            end
            for j=1, NumFunctionParams do
                local FunctionParam = FunctionParams[j]
                local FunctionParamName = FunctionParam.name
                NativeWrapperLib:write('%s':format(ParamTypePushHandler_StcArgs[FunctionParam.type][2]:format(FunctionParamName)))
            end
            NativeWrapperLib:write('end,\n')
        end
        NativeWrapperLib:write("},metatable)\n")
    end
end