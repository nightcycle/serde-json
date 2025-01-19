--!strict
-- uses the rojo explicit standard for converting roblox types into JSON-serializable structures
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private FunctionsToJson
-- Classes
local ToJson = {}
local FromJson = {}

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
	local out: Axes = Axes.new()
	for i, axis in ipairs(value) do
		if axis == "X" then
			out.X = true
		elseif axis == "Y" then
			out.Y = true
		elseif axis == "Z" then
			out.Z = true
		end
	end
	return out
end

export type BoolJson = { Bool: boolean }

ToJson.Bool = function(value: boolean): BoolJson
	return { Bool = value }
end

FromJson.Bool = function(value: BoolJson): boolean
	return value.Bool
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
}

ToJson.CFrame = function(value: CFrame): CFrameJson
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = value:GetComponents()
	return {
		position = { x, y, z },
		orientation = {
			{ R00, R01, R02 },
			{ R10, R11, R12 },
			{ R20, R21, R22 },
		},
	}
end

FromJson.CFrame = function(value: CFrameJson): CFrame
	local orientation = value.orientation
	return CFrame.new(
		value.position[1],
		value.position[2],
		value.position[3],
		orientation[1][1],
		orientation[1][2],
		orientation[1][3],
		orientation[2][1],
		orientation[2][2],
		orientation[2][3],
		orientation[3][1],
		orientation[3][2],
		orientation[3][3]
	)
end

export type Color3Json = { Color3: { number } }

ToJson.Color3 = function(value: Color3): Color3Json
	return {
		Color3 = { value.R, value.G, value.B },
	}
end

FromJson.Color3 = function(value: Color3Json): Color3
	return Color3.new(value.Color3[1], value.Color3[2], value.Color3[3])
end

export type ColorSequenceJson = {
	ColorSequence: {
		keypoints: { { time: number, color: { number } } },
	},
}
ToJson.ColorSequence = function(value: ColorSequence): ColorSequenceJson
	local keypoints: { { time: number, color: { number } } } = {}
	for i, keypoint in ipairs(value.Keypoints) do
		table.insert(keypoints, {
			time = keypoint.Time,
			color = { keypoint.Value.R, keypoint.Value.G, keypoint.Value.B },
		})
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
				keypoint.time,
				Color3.new(keypoint.color[1], keypoint.color[2], keypoint.color[3])
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
	local out: Faces = Faces.new()
	for i, face in ipairs(value) do
		if face == "Right" then
			out.Right = true
		elseif face == "Top" then
			out.Top = true
		elseif face == "Back" then
			out.Back = true
		elseif face == "Left" then
			out.Left = true
		elseif face == "Bottom" then
			out.Bottom = true
		elseif face == "Front" then
			out.Front = true
		end
	end
	return out
end

export type Float32Json = { Float32: number }
ToJson.Float32 = function(value: number): Float32Json
	return { Float32 = value }
end

FromJson.Float32 = function(value: Float32Json): number
	return value.Float32
end

export type Float64Json = { Float64: number }
ToJson.Float64 = function(value: number): Float64Json
	return { Float64 = value }
end

FromJson.Float64 = function(value: Float64Json): number
	return value.Float64
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

export type Int32Json = { Int32: number }
ToJson.Int32 = function(value: number): Int32Json
	return { Int32 = math.round(value) }
end

FromJson.Int32 = function(value: Int32Json): number
	return value.Int32
end

export type Int64Json = { Int64: number }
ToJson.Int64 = function(value: number): Int64Json
	return { Int64 = math.round(value) }
end

FromJson.Int64 = function(value: Int64Json): number
	return value.Int64
end

export type NumberRangeJson = {
	NumberRange: { number },
}
ToJson.NumberRange = function(value: NumberRange): NumberRangeJson
	return {
		NumberRange = {
			value.Min,
			value.Max,
		},
	}
end

FromJson.NumberRange = function(value: NumberRangeJson): NumberRange
	return NumberRange.new(value.NumberRange[1], value.NumberRange[2])
end

export type NumberSequenceJson = {
	NumberSequence: { keypoints: { { time: number, value: number, envelope: number } } },
}
ToJson.NumberSequence = function(value: NumberSequence): NumberSequenceJson
	local keypoints: { { time: number, value: number, envelope: number } } = {}
	for i, keypoint in ipairs(value.Keypoints) do
		table.insert(keypoints, {
			time = keypoint.Time,
			value = keypoint.Value,
			envelope = keypoint.Envelope,
		})
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
		table.insert(keypoints, NumberSequenceKeypoint.new(keypoint.time, keypoint.value, keypoint.envelope))
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
	},
}

ToJson.PhysicalProperties = function(value: PhysicalProperties): PhysicalPropertiesJson
	assert(
		typeof(value) == "PhysicalProperties",
		`PhysicalProperties must be a PhysicalProperties, got typeof "{typeof(value)}"`
	)
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

FromJson.PhysicalProperties = function(value: PhysicalPropertiesJson): PhysicalProperties
	return PhysicalProperties.new(
		value.PhysicalProperties.density,
		value.PhysicalProperties.friction,
		value.PhysicalProperties.elasticity,
		value.PhysicalProperties.frictionWeight,
		value.PhysicalProperties.elasticityWeight
	)
end

export type RayJson = {
	Ray: {
		origin: { number },
		direction: { number },
	},
}

ToJson.Ray = function(value: Ray): RayJson
	return {
		Ray = {
			origin = { value.Origin.X, value.Origin.Y, value.Origin.Z },
			direction = { value.Direction.X, value.Direction.Y, value.Direction.Z },
		},
	}
end

FromJson.Ray = function(value: RayJson): Ray
	return Ray.new(
		Vector3.new(value.Ray.origin[1], value.Ray.origin[2], value.Ray.origin[3]),
		Vector3.new(value.Ray.direction[1], value.Ray.direction[2], value.Ray.direction[3])
	)
end

export type RectJson = {
	Rect: { { number } },
}

ToJson.Rect = function(value: Rect): RectJson
	return {
		Rect = {
			{ value.Min.X, value.Min.Y },
			{ value.Max.X, value.Max.Y },
		},
	}
end

FromJson.Rect = function(value: RectJson): Rect
	return Rect.new(value.Rect[1][1], value.Rect[1][2], value.Rect[2][1], value.Rect[2][2])
end

export type StringJson = { String: string }

ToJson.String = function(value: string): StringJson
	return { String = value }
end

FromJson.String = function(value: StringJson): string
	return value.String
end

export type UDimJson = {
	UDim: { number },
}

ToJson.UDim = function(value: UDim): UDimJson
	return {
		UDim = {
			value.Scale,
			math.round(value.Offset),
		},
	}
end

FromJson.UDim = function(value: UDimJson): UDim
	return UDim.new(value.UDim[1], value.UDim[2])
end

export type UDim2Json = {
	UDim2: { { number } },
}

ToJson.UDim2 = function(value: UDim2): UDim2Json
	return {
		UDim2 = {
			{ value.X.Scale, math.round(value.X.Offset) },
			{ value.Y.Scale, math.round(value.Y.Offset) },
		},
	}
end

FromJson.UDim2 = function(value: UDim2Json): UDim2
	return UDim2.new(
		UDim.new(value.UDim2[1][1], value.UDim2[1][2]),
		UDim.new(value.UDim2[2][1], value.UDim2[2][2])
	)
end

export type Vector2Json = {
	Vector2: { number },
}

ToJson.Vector2 = function(value: Vector2): Vector2Json
	return {
		Vector2 = { value.X, value.Y },
	}
end

FromJson.Vector2 = function(value: Vector2Json): Vector2
	return Vector2.new(value.Vector2[1], value.Vector2[2])
end

export type Vector3Json = {
	Vector3: { number },
}

ToJson.Vector3 = function(value: Vector3): Vector3Json
	assert(typeof(value) == "Vector3", `Vector3 must be a Vector3, got typeof "{typeof(value)}"`)
	return {
		Vector3 = { value.X, value.Y, value.Z },
	}
end

FromJson.Vector3 = function(value: Vector3Json): Vector3
	return Vector3.new(value.Vector3[1], value.Vector3[2], value.Vector3[3])
end

-- this is not officially supported by Rojo, however it seems handy to have
export type Region3Json = {
	Region3: { Min: { number }, Max: { number } },
}
ToJson.Region3 = function(value: Region3): Region3Json
	local min, max = value.CFrame.Position - value.Size / 2, value.CFrame.Position + value.Size / 2

	return {
		Region3 = {
			Min = { min.X, min.Y, min.Z },
			Max = { max.X, max.Y, max.Z },
		},
	}
end

FromJson.Region3 = function(value: Region3Json): Region3
	return Region3.new(
		Vector3.new(value.Region3.Min[1], value.Region3.Min[2], value.Region3.Min[3]),
		Vector3.new(value.Region3.Max[1], value.Region3.Max[2], value.Region3.Max[3])
	)
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

return {
	ser = ToJson,
	deser = FromJson,
}
