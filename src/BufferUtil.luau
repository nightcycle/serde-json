--!strict
-- inspired by the rojo explicit standard for converting roblox types into JSON-serializable structures
-- Services
-- Packages
local Option = require("@wally/Option")
local Result = require("@wally/Result")
local BufferEncoder = require("@wally/BufferEncoder")
-- Modules
local Types = require("@proj/Types")
-- Types
type Option<V> = Option.Option<V>
type Result<V, E> = Result.Result<V, E>
type Value = Types.Value
-- Constants
-- Variables
-- References
-- Private Functions

-- Classes
local ToBuffer = {}
local FromBuffer = {}

ToBuffer.Float32 = function(value: number): buffer
	local buf = buffer.create(4)
	buffer.writef32(buf, 0, value)
	return buf
end

FromBuffer.Float32 = function(buf: buffer): number
	assert(buffer.len(buf) == 4, `buffer length must be 4 bytes, got {buffer.len(buf)}`)
	return buffer.readf32(buf, 0)
end

ToBuffer.Float64 = function(value: number): buffer
	local buf = buffer.create(8)
	buffer.writef64(buf, 0, value)
	return buf
end

FromBuffer.Float64 = function(buf: buffer): number
	assert(buffer.len(buf) == 8, `buffer length must be 8 bytes, got {buffer.len(buf)}`)
	return buffer.readf64(buf, 0)
end

ToBuffer.Int32 = function(value: number): buffer
	local buf = buffer.create(4)
	buffer.writei32(buf, 0, value)
	return buf
end

FromBuffer.Int32 = function(buf: buffer): number
	assert(buffer.len(buf) == 4, `buffer length must be 4 bytes, got {buffer.len(buf)}`)
	return buffer.readi32(buf, 0)
end

-- this isn't really Int64 encoding, it's secretly a float64
ToBuffer.Int64 = function(value: number): buffer
	local buf = buffer.create(8)
	buffer.writef64(buf, 0, value)
	return buf
end

FromBuffer.Int64 = function(buf: buffer): number
	assert(buffer.len(buf) == 8, `buffer length must be 8 bytes, got {buffer.len(buf)}`)
	return math.round(buffer.readf64(buf, 0))
end

ToBuffer.Bool = function(value: boolean): buffer
	local buf = buffer.create(1)
	if value then
		buffer.writei8(buf, 0, 1)
	else
		buffer.writei8(buf, 0, 0)
	end
	return buf
end

FromBuffer.Bool = function(buf: buffer): boolean
	assert(buffer.len(buf) == 1, `buffer length must be 1 byte, got {buffer.len(buf)}`)
	return buffer.readi8(buf, 0) == 1
end

ToBuffer.String = function(value: string): buffer
	return buffer.fromstring(value)
end

FromBuffer.String = function(buf: buffer): string
	return buffer.tostring(buf)
end

ToBuffer.Axes = function(value: Axes): buffer
	-- local b0 = value.X and 1 or 0
	-- local b1 = value.Y and 1 or 0
	-- local b2 = value.Z and 1 or 0
	-- local b3 = value.Back and 1 or 0
	-- local b4 = value.Front and 1 or 0
	-- local b5 = value.Right and 1 or 0
	-- local b6 = value.Left and 1 or 0
	-- local b7 = value.Bottom and 1 or 0
	-- local b8 = value.Top and 1 or 0

	-- local i16 = 0
	-- i16 = bit32.band()
	-- local buf = buffer.create(2)
	-- buffer.writei16(buf, 0, i16)
	-- return buf
end

FromBuffer.Axes = function(buf: buffer): Axes
	-- BufferEncoder.
end

ToBuffer.BrickColor = function(value: BrickColor): buffer end

FromBuffer.BrickColor = function(buf: buffer): BrickColor end

ToBuffer.CFrame = function(value: CFrame): buffer end

FromBuffer.CFrame = function(buf: buffer): CFrame end

ToBuffer.Color3 = function(value: Color3): buffer end

FromBuffer.Color3 = function(buf: buffer): buffer end

ToBuffer.ColorSequence = function(value: ColorSequence): buffer end

FromBuffer.ColorSequence = function(buf: buffer): ColorSequence end

ToBuffer.EnumItem = function(value: EnumItem): buffer end

FromBuffer.EnumItem = function(buf: buffer): EnumItem end

ToBuffer.Faces = function(value: Faces): buffer end

FromBuffer.Faces = function(buf: buffer): Faces end

ToBuffer.Font = function(value: Font): buffer end

FromBuffer.Font = function(buf: buffer): Font end

ToBuffer.NumberRange = function(value: NumberRange): buffer end

FromBuffer.NumberRange = function(buf: buffer): NumberRange end

ToBuffer.NumberSequence = function(value: NumberSequence): buffer end

FromBuffer.NumberSequence = function(buf: buffer): NumberSequence end

ToBuffer.PhysicalProperties = function(value: PhysicalProperties): buffer end

FromBuffer.PhysicalProperties = function(buf: buffer): PhysicalProperties end

ToBuffer.Ray = function(value: Ray): buffer end

FromBuffer.Ray = function(buf: buffer): Ray end

ToBuffer.Rect = function(value: Rect): buffer end

FromBuffer.Rect = function(buf: buffer): Rect end

ToBuffer.UDim = function(value: UDim): buffer end

FromBuffer.UDim = function(buf: buffer): UDim end

ToBuffer.UDim2 = function(value: UDim2): buffer end

FromBuffer.UDim2 = function(buf: buffer): UDim2 end

ToBuffer.Vector2 = function(value: Vector2): buffer end

FromBuffer.Vector2 = function(buf: buffer): Vector2 end

ToBuffer.Vector3 = function(value: Vector3): buffer end

FromBuffer.Vector3 = function(buf: buffer): Vector3 end

ToBuffer.Region3 = function(value: Region3): buffer end

FromBuffer.Region3 = function(buf: buffer): Region3 end

ToBuffer.Option = function(value: Option<buffer>): buffer end

FromBuffer.Option = function(buf: buffer): Option<buffer> end

ToBuffer.Result = function(value: Result<buffer, buffer>): buffer end

FromBuffer.Result = function(value: buffer): Result<buffer, buffer> end

return {
	ser = ToBuffer,
	deser = FromBuffer,
}
