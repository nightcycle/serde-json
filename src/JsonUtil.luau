--!strict
-- inspired by the rojo explicit standard for converting roblox types into JSON-serializable structures
-- Services
-- Packages
local Option = require("@wally/Option")
local Result = require("@wally/Result")
-- Modules
-- Types
type Option<V> = Option.Option<V>
type Result<V, E> = Result.Result<V, E>
-- Constants
-- Variables
-- References
-- Private Functions
function getNumberType(value: number | NaNJson | InfJson): "number" | "NaN" | "Inf"
	if typeof(value) == "number" then
		if value ~= value then
			return "NaN"
		elseif math.abs(value) == math.huge then
			return "Inf"
		else
			return "number"
		end
	elseif value["NaN"] then
		return "NaN"
	elseif value["Inf"] then
		return "Inf"
	elseif value["Int32"] or value["Int64"] or value["Float32"] or value["Float64"] then
		return "number"
	end
	error(`Invalid number type: {value}`)
end
function getIfComplex(values: { number }): boolean
	for i, v in ipairs(values) do
		if getNumberType(v) ~= "number" then
			return true
		end
	end
	return false
end

-- Classes
local ToJson = {}
local FromJson = {}

export type NaNJson = { NaN: true }

ToJson.NaN = function(value: number): NaNJson
	return table.freeze({
		NaN = true,
	} :: NaNJson)
end

FromJson.NaN = function(value: NaNJson): number
	return 1 / 0
end

export type InfJson = { Inf: boolean }

ToJson.Inf = function(value: number): InfJson
	return table.freeze({
		Inf = true,
	} :: InfJson)
end

FromJson.Inf = function(value: InfJson): number
	if value.Inf then
		return math.huge
	else
		return -math.huge
	end
end

export type Float32Json = { Float32: number | NaNJson | InfJson }
ToJson.Float32 = function(value: number): Float32Json
	local numberType = getNumberType(value)
	if numberType == "NaN" then
		return { Float32 = ToJson.NaN(value) }
	elseif numberType == "Inf" then
		return { Float32 = ToJson.Inf(value) }
	elseif numberType == "number" then
		return { Float32 = value }
	end
	error(`Unsupported number type: {numberType}`)
end

FromJson.Float32 = function(value: Float32Json): number
	local v = value.Float32
	local numberType = getNumberType(v)
	if numberType == "number" then
		return v :: number
	elseif numberType == "NaN" then
		return FromJson.NaN(v :: NaNJson)
	elseif numberType == "Inf" then
		return FromJson.Inf(v :: InfJson)
	end
	error(`Unsupported number type: {numberType}`)
end

local function ezFromF32(v: number | Float32Json): number
	if typeof(v) == "number" then
		return v
	else
		return FromJson.Float32(v)
	end
end

export type Float64Json = { Float64: number | NaNJson | InfJson }
ToJson.Float64 = function(value: number): Float64Json
	local numberType = getNumberType(value)
	if numberType == "NaN" then
		return { Float64 = ToJson.NaN(value) }
	elseif numberType == "Inf" then
		return { Float64 = ToJson.Inf(value) }
	elseif numberType == "number" then
		return { Float64 = value }
	end
	error(`Unsupported number type: {numberType}`)
end

FromJson.Float64 = function(value: Float64Json): number
	local v = value.Float64
	local numberType = getNumberType(v)
	if numberType == "number" then
		return v :: number
	elseif numberType == "NaN" then
		return FromJson.NaN(v :: NaNJson)
	elseif numberType == "Inf" then
		return FromJson.Inf(v :: InfJson)
	end
	error(`Unsupported number type: {numberType}`)
end

export type Int32Json = { Int32: number | NaNJson | InfJson }
ToJson.Int32 = function(value: number): Int32Json
	local numberType = getNumberType(value)
	if numberType == "NaN" then
		return { Int32 = ToJson.NaN(value) }
	elseif numberType == "Inf" then
		return { Int32 = ToJson.Inf(value) }
	elseif numberType == "number" then
		return { Int32 = math.round(value) }
	end
	error(`Unsupported number type: {numberType}`)
end

FromJson.Int32 = function(value: Int32Json): number
	local v = value.Int32
	local numberType = getNumberType(v)
	if numberType == "number" then
		return math.round(v :: number)
	elseif numberType == "NaN" then
		return FromJson.NaN(v :: NaNJson)
	elseif numberType == "Inf" then
		return FromJson.Inf(v :: InfJson)
	end
	error(`Unsupported number type: {numberType}`)
end

export type Int64Json = { Int64: number | NaNJson | InfJson }
ToJson.Int64 = function(value: number): Int64Json
	local numberType = getNumberType(value)
	if numberType == "NaN" then
		return { Int64 = ToJson.NaN(value) }
	elseif numberType == "Inf" then
		return { Int64 = ToJson.Inf(value) }
	elseif numberType == "number" then
		return { Int64 = math.round(value) }
	end
	error(`Unsupported number type: {numberType}`)
end

FromJson.Int64 = function(value: Int64Json): number
	local v = value.Int64
	local numberType = getNumberType(v)
	if numberType == "number" then
		return math.round(v :: number)
	elseif numberType == "NaN" then
		return FromJson.NaN(v :: NaNJson)
	elseif numberType == "Inf" then
		return FromJson.Inf(v :: InfJson)
	end
	error(`Unsupported number type: {numberType}`)
end

export type BoolJson = { Bool: boolean }

ToJson.Bool = function(value: boolean): BoolJson
	return { Bool = value }
end

FromJson.Bool = function(value: BoolJson): boolean
	return value.Bool
end

export type StringJson = { String: string }

ToJson.String = function(value: string): StringJson
	return { String = value }
end

FromJson.String = function(value: StringJson): string
	return value.String
end

export type AxesJson = { "X" | "Y" | "Z" }

ToJson.Axes = function(value: Axes): AxesJson
	local out: AxesJson = {}
	if value.X then
		table.insert(out, "X")
	end
	if value.Y then
		table.insert(out, "Y")
	end
	if value.Z then
		table.insert(out, "Z")
	end
	return out
end

FromJson.Axes = function(value: AxesJson): Axes
	local axes: { Enum.Axis } = {}
	for i, axis in ipairs(value) do
		if axis == "X" then
			table.insert(axes, Enum.Axis.X)
		elseif axis == "Y" then
			table.insert(axes, Enum.Axis.Y)
		elseif axis == "Z" then
			table.insert(axes, Enum.Axis.Z)
		end
	end
	return Axes.new(table.unpack(axes))
end

export type BrickColorJson = { BrickColor: number }

ToJson.BrickColor = function(value: BrickColor): BrickColorJson
	return { BrickColor = value.Number }
end

FromJson.BrickColor = function(value: BrickColorJson): BrickColor
	return BrickColor.new(value.BrickColor)
end

export type CFrameJson = {
	position: { number },
	orientation: { { number } },
} | {
	position: { Float32Json },
	orientation: { { Float32Json } },
}

ToJson.CFrame = function(value: CFrame): CFrameJson
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = value:GetComponents()
	local isComplex = getIfComplex({ x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 })
	if isComplex then
		return {
			position = { ToJson.Float32(x), ToJson.Float32(y), ToJson.Float32(z) },
			orientation = {
				{ ToJson.Float32(R00), ToJson.Float32(R01), ToJson.Float32(R02) },
				{ ToJson.Float32(R10), ToJson.Float32(R11), ToJson.Float32(R12) },
				{ ToJson.Float32(R20), ToJson.Float32(R21), ToJson.Float32(R22) },
			},
		}
	else
		return {
			position = { x, y, z },
			orientation = {
				{ R00, R01, R02 },
				{ R10, R11, R12 },
				{ R20, R21, R22 },
			},
		}
	end
end

FromJson.CFrame = function(value: CFrameJson): CFrame
	local orientation = value.orientation

	return CFrame.new(
		ezFromF32(value.position[1]),
		ezFromF32(value.position[2]),
		ezFromF32(value.position[3]),
		ezFromF32(orientation[1][1]),
		ezFromF32(orientation[1][2]),
		ezFromF32(orientation[1][3]),
		ezFromF32(orientation[2][1]),
		ezFromF32(orientation[2][2]),
		ezFromF32(orientation[2][3]),
		ezFromF32(orientation[3][1]),
		ezFromF32(orientation[3][2]),
		ezFromF32(orientation[3][3])
	)
end

export type Color3Json = { Color3: { number } | { Float32Json } }

ToJson.Color3 = function(value: Color3): Color3Json
	local isComplex = getIfComplex({ value.R, value.G, value.B })
	if isComplex then
		return {
			Color3 = { ToJson.Float32(value.R), ToJson.Float32(value.G), ToJson.Float32(value.B) },
		}
	else
		return {
			Color3 = { value.R, value.G, value.B },
		}
	end
end

FromJson.Color3 = function(value: Color3Json): Color3
	return Color3.new(ezFromF32(value.Color3[1]), ezFromF32(value.Color3[2]), ezFromF32(value.Color3[3]))
end

export type ColorSequenceJson = {
	ColorSequence: {
		keypoints: { { time: Float32Json, color: { Float32Json } } | { time: number, color: { number } } },
	},
}
ToJson.ColorSequence = function(value: ColorSequence): ColorSequenceJson
	local keypoints: { { time: Float32Json, color: { Float32Json } } | { time: number, color: { number } } } =
		{}
	for i, keypoint in ipairs(value.Keypoints) do
		local isComplex =
			getIfComplex({ keypoint.Time, keypoint.Value.R, keypoint.Value.G, keypoint.Value.B })
		if isComplex then
			table.insert(keypoints, {
				time = ToJson.Float32(keypoint.Time),
				color = {
					ToJson.Float32(keypoint.Value.R),
					ToJson.Float32(keypoint.Value.G),
					ToJson.Float32(keypoint.Value.B),
				},
			})
		else
			table.insert(keypoints, {
				time = keypoint.Time,
				color = { keypoint.Value.R, keypoint.Value.G, keypoint.Value.B },
			})
		end
	end

	return {
		ColorSequence = {
			keypoints = keypoints,
		},
	}
end

FromJson.ColorSequence = function(value: ColorSequenceJson): ColorSequence
	local keypoints = {}
	for i, keypoint in ipairs(value.ColorSequence.keypoints) do
		table.insert(
			keypoints,
			ColorSequenceKeypoint.new(
				ezFromF32(keypoint.time),
				Color3.new(
					ezFromF32(keypoint.color[1]),
					ezFromF32(keypoint.color[2]),
					ezFromF32(keypoint.color[3])
				)
			)
		)
	end
	return ColorSequence.new(keypoints)
end

-- deviation from rojo standard
export type EnumJson = {
	EnumItem: {
		EnumType: string,
		Value: number,
	},
}
ToJson.EnumItem = function(value: EnumItem): EnumJson
	return {
		EnumItem = {
			EnumType = tostring(value.EnumType),
			Value = value.Value,
		},
	}
end

FromJson.EnumItem = function(value: EnumJson): EnumItem
	local enumType: Enum = Enum[tostring(value.EnumItem)]
	local item: EnumItem?
	for i, enumItem in ipairs(enumType:GetEnumItems()) do
		if enumItem.Value == value.EnumItem.Value then
			item = enumItem
			break
		end
	end
	assert(item, `EnumItem at value {value.EnumItem.Value} not found in enum {enumType}`)
	return item
end

export type FacesJson = { "Right" | "Top" | "Back" | "Left" | "Bottom" | "Front" }
ToJson.Faces = function(value: Faces): FacesJson
	local out: FacesJson = {}
	if value.Right then
		table.insert(out, "Right")
	end
	if value.Top then
		table.insert(out, "Top")
	end
	if value.Back then
		table.insert(out, "Back")
	end
	if value.Left then
		table.insert(out, "Left")
	end
	if value.Bottom then
		table.insert(out, "Bottom")
	end
	if value.Front then
		table.insert(out, "Front")
	end
	return out
end

FromJson.Faces = function(value: FacesJson): Faces
	local normalIds: { Enum.NormalId } = {}
	for i, face in ipairs(value) do
		if face == "Right" then
			table.insert(normalIds, Enum.NormalId.Right)
		elseif face == "Top" then
			table.insert(normalIds, Enum.NormalId.Top)
		elseif face == "Back" then
			table.insert(normalIds, Enum.NormalId.Back)
		elseif face == "Left" then
			table.insert(normalIds, Enum.NormalId.Left)
		elseif face == "Bottom" then
			table.insert(normalIds, Enum.NormalId.Bottom)
		elseif face == "Front" then
			table.insert(normalIds, Enum.NormalId.Front)
		end
	end
	return Faces.new(table.unpack(normalIds))
end

export type FontJson = {
	Font: {
		family: string,
		weight: string,
		style: string,
	},
}
ToJson.Font = function(value: Font): FontJson
	return {
		Font = {
			family = value.Family,
			weight = value.Weight.Name,
			style = value.Style.Name,
		},
	}
end

FromJson.Font = function(value: FontJson): Font
	local weight: Enum.FontWeight = (Enum.FontWeight :: any)[value.Font.weight]
	local style: Enum.FontStyle = (Enum.FontStyle :: any)[value.Font.style]

	return Font.new(value.Font.family, weight, style)
end

export type NumberRangeJson = {
	NumberRange: { Float32Json } | { number },
}
ToJson.NumberRange = function(value: NumberRange): NumberRangeJson
	local isComplex = getIfComplex({ value.Min, value.Max })
	if isComplex then
		return {
			NumberRange = {
				ToJson.Float32(value.Min),
				ToJson.Float32(value.Max),
			},
		}
	else
		return {
			NumberRange = {
				value.Min,
				value.Max,
			},
		}
	end
end

FromJson.NumberRange = function(value: NumberRangeJson): NumberRange
	return NumberRange.new(ezFromF32(value.NumberRange[1]), ezFromF32(value.NumberRange[2]))
end

export type NumberSequenceJson = {
	NumberSequence: {
		keypoints: {
			{
				time: Float32Json,
				value: Float32Json,
				envelope: Float32Json,
			} | {
				time: number,
				value: number,
				envelope: number,
			}
		},
	},
}
ToJson.NumberSequence = function(value: NumberSequence): NumberSequenceJson
	local keypoints: {
		{
			time: Float32Json,
			value: Float32Json,
			envelope: Float32Json,
		} | {
			time: number,
			value: number,
			envelope: number,
		}
	} =
		{}
	for i, keypoint in ipairs(value.Keypoints) do
		local isComplex = getIfComplex({ keypoint.Time, keypoint.Value, keypoint.Envelope })
		if isComplex then
			table.insert(keypoints, {
				time = ToJson.Float32(keypoint.Time),
				value = ToJson.Float32(keypoint.Value),
				envelope = ToJson.Float32(keypoint.Envelope),
			})
		else
			table.insert(keypoints, {
				time = keypoint.Time,
				value = keypoint.Value,
				envelope = keypoint.Envelope,
			})
		end
	end
	return {
		NumberSequence = {
			keypoints = keypoints,
		},
	}
end

FromJson.NumberSequence = function(value: NumberSequenceJson): NumberSequence
	local keypoints = {}
	for i, keypoint in ipairs(value.NumberSequence.keypoints) do
		table.insert(
			keypoints,
			NumberSequenceKeypoint.new(
				ezFromF32(keypoint.time),
				ezFromF32(keypoint.value),
				ezFromF32(keypoint.envelope)
			)
		)
	end
	return NumberSequence.new(keypoints)
end

export type PhysicalPropertiesJson = {
	PhysicalProperties: {
		density: number,
		friction: number,
		elasticity: number,
		frictionWeight: number,
		elasticityWeight: number,
	} | {
		density: Float32Json,
		friction: Float32Json,
		elasticity: Float32Json,
		frictionWeight: Float32Json,
		elasticityWeight: Float32Json,
	},
}

ToJson.PhysicalProperties = function(value: PhysicalProperties): PhysicalPropertiesJson
	assert(
		typeof(value) == "PhysicalProperties",
		`PhysicalProperties must be a PhysicalProperties, got typeof "{typeof(value)}"`
	)

	local isComplex = getIfComplex({
		value.Density,
		value.Friction,
		value.Elasticity,
		value.FrictionWeight,
		value.ElasticityWeight,
	})
	if isComplex then
		return {
			PhysicalProperties = {
				density = ToJson.Float32(value.Density),
				friction = ToJson.Float32(value.Friction),
				elasticity = ToJson.Float32(value.Elasticity),
				frictionWeight = ToJson.Float32(value.FrictionWeight),
				elasticityWeight = ToJson.Float32(value.ElasticityWeight),
			},
		}
	else
		return {
			PhysicalProperties = {
				density = value.Density,
				friction = value.Friction,
				elasticity = value.Elasticity,
				frictionWeight = value.FrictionWeight,
				elasticityWeight = value.ElasticityWeight,
			},
		}
	end
end

FromJson.PhysicalProperties = function(value: PhysicalPropertiesJson): PhysicalProperties
	return PhysicalProperties.new(
		ezFromF32(value.PhysicalProperties.density),
		ezFromF32(value.PhysicalProperties.friction),
		ezFromF32(value.PhysicalProperties.elasticity),
		ezFromF32(value.PhysicalProperties.frictionWeight),
		ezFromF32(value.PhysicalProperties.elasticityWeight)
	)
end

export type RayJson = {
	Ray: {
		origin: { number },
		direction: { number },
	} | {
		origin: { Float32Json },
		direction: { Float32Json },
	},
}

ToJson.Ray = function(value: Ray): RayJson
	local isComplex = getIfComplex({
		value.Origin.X,
		value.Origin.Y,
		value.Origin.Z,
		value.Direction.X,
		value.Direction.Y,
		value.Direction.Z,
	})
	if isComplex then
		return {
			Ray = {
				origin = {
					ToJson.Float32(value.Origin.X),
					ToJson.Float32(value.Origin.Y),
					ToJson.Float32(value.Origin.Z),
				},
				direction = {
					ToJson.Float32(value.Direction.X),
					ToJson.Float32(value.Direction.Y),
					ToJson.Float32(value.Direction.Z),
				},
			},
		}
	else
		return {
			Ray = {
				origin = { value.Origin.X, value.Origin.Y, value.Origin.Z },
				direction = { value.Direction.X, value.Direction.Y, value.Direction.Z },
			},
		}
	end
end

FromJson.Ray = function(value: RayJson): Ray
	return Ray.new(
		Vector3.new(
			ezFromF32(value.Ray.origin[1]),
			ezFromF32(value.Ray.origin[2]),
			ezFromF32(value.Ray.origin[3])
		),
		Vector3.new(
			ezFromF32(value.Ray.direction[1]),
			ezFromF32(value.Ray.direction[2]),
			ezFromF32(value.Ray.direction[3])
		)
	)
end

export type RectJson = {
	Rect: { { number } } | { { Float32Json } },
}

ToJson.Rect = function(value: Rect): RectJson
	local isComplex = getIfComplex({ value.Min.X, value.Min.Y, value.Max.X, value.Max.Y })
	if isComplex then
		return {
			Rect = {
				{ ToJson.Float32(value.Min.X), ToJson.Float32(value.Min.Y) },
				{ ToJson.Float32(value.Max.X), ToJson.Float32(value.Max.Y) },
			},
		}
	else
		return {
			Rect = {
				{ value.Min.X, value.Min.Y },
				{ value.Max.X, value.Max.Y },
			},
		}
	end
end

FromJson.Rect = function(value: RectJson): Rect
	return Rect.new(
		ezFromF32(value.Rect[1][1]),
		ezFromF32(value.Rect[1][2]),
		ezFromF32(value.Rect[2][1]),
		ezFromF32(value.Rect[2][2])
	)
end

export type UDimJson = {
	UDim: { number } | { Float32Json },
}

ToJson.UDim = function(value: UDim): UDimJson
	local isComplex = getIfComplex({ value.Scale, value.Offset })
	if isComplex then
		return {
			UDim = {
				ToJson.Float32(value.Scale),
				ToJson.Float32(value.Offset),
			},
		}
	else
		return {
			UDim = {
				value.Scale,
				math.round(value.Offset),
			},
		}
	end
end

FromJson.UDim = function(value: UDimJson): UDim
	return UDim.new(ezFromF32(value.UDim[1]), ezFromF32(value.UDim[2]))
end

export type UDim2Json = {
	UDim2: { { number } } | { { Float32Json } },
}

ToJson.UDim2 = function(value: UDim2): UDim2Json
	local isComplex = getIfComplex({ value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset })
	if isComplex then
		return {
			UDim2 = {
				{ ToJson.Float32(value.X.Scale), ToJson.Float32(value.X.Offset) },
				{ ToJson.Float32(value.Y.Scale), ToJson.Float32(value.Y.Offset) },
			},
		}
	else
		return {
			UDim2 = {
				{ value.X.Scale, math.round(value.X.Offset) },
				{ value.Y.Scale, math.round(value.Y.Offset) },
			},
		}
	end
end

FromJson.UDim2 = function(value: UDim2Json): UDim2
	return UDim2.new(
		UDim.new(ezFromF32(value.UDim2[1][1]), ezFromF32(value.UDim2[1][2])),
		UDim.new(ezFromF32(value.UDim2[2][1]), ezFromF32(value.UDim2[2][2]))
	)
end

export type Vector2Json = {
	Vector2: { number } | { Float32Json },
}

ToJson.Vector2 = function(value: Vector2): Vector2Json
	local isComplex = getIfComplex({ value.X, value.Y })
	if isComplex then
		return {
			Vector2 = {
				ToJson.Float32(value.X),
				ToJson.Float32(value.Y),
			},
		}
	else
		return {
			Vector2 = { value.X, value.Y },
		}
	end
end

FromJson.Vector2 = function(value: Vector2Json): Vector2
	return Vector2.new(ezFromF32(value.Vector2[1]), ezFromF32(value.Vector2[2]))
end

export type Vector3Json = {
	Vector3: { number } | { Float32Json },
}

ToJson.Vector3 = function(value: Vector3): Vector3Json
	local isComplex = getIfComplex({ value.X, value.Y, value.Z })
	if isComplex then
		return {
			Vector3 = {
				ToJson.Float32(value.X),
				ToJson.Float32(value.Y),
				ToJson.Float32(value.Z),
			},
		}
	else
		return {
			Vector3 = { value.X, value.Y, value.Z },
		}
	end
end

FromJson.Vector3 = function(value: Vector3Json): Vector3
	return Vector3.new(ezFromF32(value.Vector3[1]), ezFromF32(value.Vector3[2]), ezFromF32(value.Vector3[3]))
end

-- this is not officially supported by Rojo, however it seems handy to have
export type Region3Json = {
	Region3: { Min: { number }, Max: { number } } | { Min: { Float32Json }, Max: { Float32Json } },
}
ToJson.Region3 = function(value: Region3): Region3Json
	local min, max = value.CFrame.Position - value.Size / 2, value.CFrame.Position + value.Size / 2

	local isComplex = getIfComplex({ min.X, min.Y, min.Z, max.X, max.Y, max.Z })
	if isComplex then
		return {
			Region3 = {
				Min = {
					ToJson.Float32(min.X),
					ToJson.Float32(min.Y),
					ToJson.Float32(min.Z),
				},
				Max = {
					ToJson.Float32(max.X),
					ToJson.Float32(max.Y),
					ToJson.Float32(max.Z),
				},
			},
		}
	else
		return {
			Region3 = {
				Min = { min.X, min.Y, min.Z },
				Max = { max.X, max.Y, max.Z },
			},
		}
	end
end

FromJson.Region3 = function(value: Region3Json): Region3
	return Region3.new(
		Vector3.new(
			ezFromF32(value.Region3.Min[1]),
			ezFromF32(value.Region3.Min[2]),
			ezFromF32(value.Region3.Min[3])
		),
		Vector3.new(
			ezFromF32(value.Region3.Max[1]),
			ezFromF32(value.Region3.Max[2]),
			ezFromF32(value.Region3.Max[3])
		)
	)
end

export type OptionJson<V> = {
	None: true,
} | {
	Some: V,
}

ToJson.Option = function<V>(value: Option<V>): OptionJson<V>
	return value:match(function(v): OptionJson<V>
		return {
			Some = v,
		}
	end, function(): OptionJson<V>
		return table.freeze({ None = true } :: {
			None: true,
		})
	end)
end

FromJson.Option = function<V>(value: OptionJson<V>): Option<V>
	if value["None"] then
		return Option.none()
	else
		return Option.some(value["Some"] :: V)
	end
end

export type ResultJson<V, E> = {
	Err: E,
} | {
	Ok: V,
}

ToJson.Result = function<V, E>(value: Result<V, E>): ResultJson<V, E>
	return value:match(function(v): ResultJson<V, E>
		return {
			Ok = v,
		}
	end, function(e): ResultJson<V, E>
		return { Err = e }
	end)
end

FromJson.Result = function<V, E>(value: ResultJson<V, E>): Result<V, E>
	if value["Err"] then
		return Result.err(value["Err"] :: E)
	else
		return Result.ok(value["Ok"] :: V)
	end
end

export type Value =
	Axes
	| boolean
	| BrickColor
	| CFrame
	| Color3
	| ColorSequence
	| EnumItem
	| Faces
	| number
	| NumberRange
	| NumberSequence
	| PhysicalProperties
	| Ray
	| Rect
	| string
	| UDim
	| UDim2
	| Vector2
	| Vector3
	| Region3

export type JsonValue =
	AxesJson
	| BoolJson
	| BrickColorJson
	| CFrameJson
	| Color3Json
	| ColorSequenceJson
	| EnumJson
	| FacesJson
	| Float32Json
	| Float64Json
	| FontJson
	| Int32Json
	| Int64Json
	| NumberRangeJson
	| NumberSequenceJson
	| PhysicalPropertiesJson
	| RayJson
	| RectJson
	| StringJson
	| UDimJson
	| UDim2Json
	| Vector2Json
	| Vector3Json
	| Region3Json
	| InfJson
	| NaNJson
	| OptionJson<JsonValue>
	| ResultJson<JsonValue, JsonValue>

return {
	ser = ToJson,
	deser = FromJson,
}
