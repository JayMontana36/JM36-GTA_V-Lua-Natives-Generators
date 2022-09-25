local setmetatable = setmetatable
return
{
	Returns	=	setmetatable
				(
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
				,
	VarArgs	=	setmetatable
				(
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
						["const char*"] =	";i+=1;push_arg_pointer(args[i])",
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
				,
	StcArgs	=	setmetatable
				(
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
						["const char*"] =	"push_arg_pointer(%s)",
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
}