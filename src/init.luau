--!strict
-- Services
-- Packages
local Result = require("@pkg/@nightcycle/result")
local Option = require("@pkg/@nightcycle/option")
local LuneUtil = require("@pkg/@nightcycle/lune-util")
-- Modules
local JsonUtil = require("./JsonUtil")
-- Types
export type Ser = typeof(JsonUtil.ser)
export type Deser = typeof(JsonUtil.deser)
export type Result<V, E> = Result.Result<V, E>
export type Option<V> = Option.Option<V>
export type JsonValue = JsonUtil.JsonValue
export type Value = JsonUtil.Value
export type AxesJson = JsonUtil.AxesJson
export type BoolJson = JsonUtil.BoolJson
export type BrickColorJson = JsonUtil.BrickColorJson
export type CFrameJson = JsonUtil.CFrameJson
export type Color3Json = JsonUtil.Color3Json
export type ColorSequenceJson = JsonUtil.ColorSequenceJson
export type EnumJson = JsonUtil.EnumJson
export type FacesJson = JsonUtil.FacesJson
export type Float32Json = JsonUtil.Float32Json
export type Float64Json = JsonUtil.Float64Json
export type FontJson = JsonUtil.FontJson
export type Int32Json = JsonUtil.Int32Json
export type Int64Json = JsonUtil.Int64Json
export type NumberRangeJson = JsonUtil.NumberRangeJson
export type NumberSequenceJson = JsonUtil.NumberSequenceJson
export type PhysicalPropertiesJson = JsonUtil.PhysicalPropertiesJson
export type RayJson = JsonUtil.RayJson
export type RectJson = JsonUtil.RectJson
export type StringJson = JsonUtil.StringJson
export type UDimJson = JsonUtil.UDimJson
export type UDim2Json = JsonUtil.UDim2Json
export type Vector2Json = JsonUtil.Vector2Json
export type Vector3Json = JsonUtil.Vector3Json
export type Region3Json = JsonUtil.Region3Json
export type InfJson = JsonUtil.InfJson
export type NaNJson = JsonUtil.NaNJson
export type OptionJson<V> = JsonUtil.OptionJson<V>
export type ResultJson<V, E> = JsonUtil.ResultJson<V, E>
export type AnyJson = JsonUtil.AnyJson

type SerdeImpl<Field, JsonField> = {
	__index: SerdeImpl<Field, JsonField>,
	encode: (self: Serde<Field, JsonField>, input: Field) -> Result<JsonField, string>,
	decode: (self: Serde<Field, JsonField>, input: JsonField) -> Result<Field, string>,
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
		return LuneUtil.Net.jsonEncode(self._ser(input, JsonUtil.ser))
	end)
end

function Serde:encode(input: { [string]: unknown }): Result<{ [string]: JsonUtil.JsonValue }, string>
	return Result.try(function()
		return self._ser(input, JsonUtil.ser) :: { [string]: JsonUtil.JsonValue }
	end):match(function(value)
		return Result.ok(value)
	end, function(err: string)
		return Result.err(err)
	end)
end

function Serde:decode(input: { [string]: JsonUtil.JsonValue }): Result<{ [string]: unknown }, string>
	return Result.try(function()
		return self._deser(input, JsonUtil.deser)
	end)
end

function Serde:fromString(input: string): Result<{ [string]: unknown }, string>
	return Result.try(function()
		return self._deser(LuneUtil.Net.jsonDecode(input) :: any, JsonUtil.deser)
	end)
end

return {
	new = newSerde,
	intersect = intersectSerde,
}
