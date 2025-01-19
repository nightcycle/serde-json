--!strict
-- Services
local HttpService = game:GetService("HttpService")
-- Packages
local Result = require("@wally/Result")
-- Modules
local JsonUtil = require("@proj/JsonUtil")
-- Types
export type Ser = typeof(JsonUtil.ser)
export type Deser = typeof(JsonUtil.deser)
export type Result<V, E> = Result.Result<V, E>
type SerdeImpl<Field, JsonField> = {
	__index: SerdeImpl<Field, JsonField>,
	toString: (self: Serde<Field, JsonField>, input: Field) -> Result<string, string>,
	fromString: (self: Serde<Field, JsonField>, input: string) -> Result<Field, string>,
}
export type Serde<Field, JsonField> = typeof(setmetatable(
	{} :: {
		_ser: (Field, ser: Ser) -> JsonField,
		_deser: (JsonField, deser: Deser) -> Field,
	},
	{} :: SerdeImpl<Field, JsonField>
))

-- Constants
-- Variables
-- References
-- Private Functions
function intersect<AI, AO, BI, BO, Interface>(a: (AI, Interface) -> AO, b: (BI, Interface) -> BO): (AI & BI, Interface) -> AO & BO
	return function(input: AI & BI, interface: Interface): AO & BO
		local fields = {
			a(input, interface) :: any,
			b(input, interface),
		}
		local output: AO & BO = {} :: any
		for i, field in ipairs(fields) do
			for key, value in pairs(field :: any) do
				(output :: any)[key] = value
			end
		end
		return output
	end
end

-- Class
local Serde = {} :: SerdeImpl<{ [string]: unknown }, { [string]: JsonUtil.JsonValue }>
Serde.__index = Serde

-- constructors
function newSerde<Field, JsonField>(
	ser: (Field, ser: Ser) -> JsonField,
	deser: (JsonField, deser: Deser) -> Field
): Serde<Field, JsonField>
	return table.freeze(setmetatable({
		_ser = ser,
		_deser = deser,
	}, Serde :: SerdeImpl<any, any>))
end

function intersectSerde<AField, AJsonField, BField, BJsonField>(
	a: Serde<AField, AJsonField>,
	b: Serde<BField, BJsonField>
): Serde<
	AField & BField,
	AJsonField & BJsonField
>
	return table.freeze(setmetatable({
		_ser = intersect(a._ser, b._ser),
		_deser = intersect(a._deser, b._deser),
	}, Serde :: SerdeImpl<any, any>))
end

function Serde:toString(input: { [string]: unknown }): Result<string, string>
	return Result.try(function()
		return HttpService:JSONEncode(self._ser(input, JsonUtil.ser))
	end)
end

function Serde:fromString(input: string): Result<{ [string]: unknown }, string>
	return Result.try(function()
		return self._deser(HttpService:JSONDecode(input), JsonUtil.deser)
	end)
end

return {
	new = newSerde,
	intersect = intersectSerde,
}
