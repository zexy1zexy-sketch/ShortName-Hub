        end)
    end)

    Bubble.Activated:Connect(function()
        Minimized = false
        Bubble.Visible = false
        Frame.Visible = true
        WindowScale.Scale = 0.78
        Tween(
            WindowScale,
            {
                Scale = 1
            },
            TweenInfo.new(
                0.28,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
        )
    end)

    -- WINDOW DRAGGING
    local Dragging = false; local DragInput; local DragStart
    local StartPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = true
            DragStart = input.Position
            StartPosition = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            DragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Frame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + delta.Y
            )
        end
    end)

    -- BUBBLE DRAGGING
    local BubbleDragging = false; local BubbleInput; local BubbleStart
    local BubblePosition

    Bubble.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            BubbleDragging = true
            BubbleInput = input
            BubbleStart = input.Position
            BubblePosition = Bubble.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    BubbleDragging = false
                end
            end)
        end
    end)

    Bubble.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            BubbleInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == BubbleInput and BubbleDragging then
            local delta = input.Position - BubbleStart
            Bubble.Position = UDim2.new(
                BubblePosition.X.Scale,
                BubblePosition.X.Offset + delta.X,
                BubblePosition.Y.Scale,
                BubblePosition.Y.Offset + delta.Y
            )
        end
    end)

    -- EXIT
    ExitButton.Activated:Connect(function()
        pcall(function()
            Controller.Stop()
        end)
        pcall(function()
            Scythe.Stop()
        end)
        pcall(function()
            if ThanksgivingScanner and type(ThanksgivingScanner.Stop) == "function" then
                ThanksgivingScanner:Stop()
            end
        end)
        HouseAutoEnabled = false
        HouseLoopToken = HouseLoopToken + 1
        ScreenGui:Destroy()
    end)

    SelectPage("Settings"); Tween(WindowScale, { Scale = 1 }, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    return { SetStatus = SetStatus, RefreshLogs = RefreshLogs, ScreenGui = ScreenGui }
end

return GUI
