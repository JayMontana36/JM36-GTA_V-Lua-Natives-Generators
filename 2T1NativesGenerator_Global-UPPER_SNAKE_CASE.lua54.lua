local json_decode = require('json').decode
local setmetatable = setmetatable
local io_open = io.open
local table_concat = table.concat
local math_min = math.min
local string_byte = string.byte
local table_sort = table.sort
local collectgarbage = collectgarbage

local table_sort_func <const> = function(inputA,inputB)
    return inputA[1] < inputB[1]
end

local ParamTypeReturnHandler <const> = setmetatable(
    {
        ["Any"]         =   '',
        ["Any*"]        =   '',
        ["Blip"]        =   ':__tointeger()',
        ["BOOL"]        =   ':__tointeger()~=0;',
        ["Cam"]         =   ':__tointeger()',
        ["Entity"]      =   ':__tointeger()',
        ["FireId"]      =   ':__tointeger()',
        ["float"]       =   ':__tonumber()',
        ["Hash"]        =   ':__tointeger()',
        ["int"]         =   ':__tointeger()',
        ["Interior"]    =   ':__tointeger()',
        ["Object"]      =   ':__tointeger()',
        ["Ped"]         =   ':__tointeger()',
        ["Pickup"]      =   ':__tointeger()',
        ["Player"]      =   ':__tointeger()',
        ["ScrHandle"]   =   ':__tointeger()',
        ["Vehicle"]     =   ':__tointeger()',
        ["const char*"] =   ':__tostring(true)',
        ["Vector3"]     =   ':__tov3()',
        ["void"]        =   '',
                    
    },
    {
        __index =   function(Self, Key)
                        local TypeReturnHandlerString = ''
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
            do
                local FunctionName = FunctionData[1]
                if FunctionName:startswith "0x" then
                    FunctionName = "_"..FunctionName
                end
                NativeWrapperLib:write('    ["%s"]=function(...)return native_call(%s,...)%send,\n':format(FunctionName,FunctionData[3],ParamTypeReturnHandler[FunctionData[2].return_type]))
            end
        end
        NativeWrapperLib:write("},metatable)\n")
    end
end