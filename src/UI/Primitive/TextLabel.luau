local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local _ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local _TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local e = React.createElement

export type props = {

	Size: UDim2?,
	Position: UDim2?,
	BackgroundColor3: Color3?,
	Text: string & any,
    BGTransparency: number?,
	OnClick: () -> ()?,
	children: any?,
	Rotation : number?,
	TextColor3 : Color3?,
	TextScaled : boolean?,
	TextTransparency : number?,

}

return function(props: props)

	return e("TextLabel", 
   {
        Size = props.Size or UDim2.fromScale(0.5, 0.5),
		Position = props.Position or UDim2.fromScale(0.2, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BGTransparency or 0,
		Text = props.Text or ``,
		Rotation = props.Rotation or 0,
		TextColor3 = props.TextColor3 or Color3.new(),
		TextScaled = props.TextScaled or true,
		TextTransparency = props.TextTransparency or 0
    },
     {
		props.children,
	} 
    )
end
