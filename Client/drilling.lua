Scaleforms = {}

-- Load scaleforms
Scaleforms.LoadMovie = function(name)
  local scaleform = RequestScaleformMovie(name)
  while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
  return scaleform
end

Scaleforms.LoadInteractive = function(name)
  local scaleform = RequestScaleformMovieInteractive(name)
  while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
  return scaleform
end

Scaleforms.UnloadMovie = function(scaleform)
  SetScaleformMovieAsNoLongerNeeded(scaleform)
end

-- Text & labels
Scaleforms.LoadAdditionalText = function(gxt,count)
  for i=0,count,1 do
    if not HasThisAdditionalTextLoaded(gxt,i) then
      ClearAdditionalText(i, true)
      RequestAdditionalText(gxt, i)
      while not HasThisAdditionalTextLoaded(gxt,i) do Wait(0); end
    end
  end
end

Scaleforms.SetLabels = function(scaleform,labels)
  PushScaleformMovieFunction(scaleform, "SET_LABELS")
  for i=1,#labels,1 do
    local txt = labels[i]
    BeginTextCommandScaleformString(txt)
    EndTextCommandScaleformString()
  end
  PopScaleformMovieFunctionVoid()
end

-- Push method vals wrappers
Scaleforms.PopMulti = function(scaleform,method,...)
  PushScaleformMovieFunction(scaleform,method)
  for _,v in pairs({...}) do
    local trueType = Scaleforms.TrueType(v)
    if trueType == "string" then      
      PushScaleformMovieFunctionParameterString(v)
    elseif trueType == "boolean" then
      PushScaleformMovieFunctionParameterBool(v)
    elseif trueType == "int" then
      PushScaleformMovieFunctionParameterInt(v)
    elseif trueType == "float" then
      PushScaleformMovieFunctionParameterFloat(v)
    end
  end
  PopScaleformMovieFunctionVoid()
end

Scaleforms.PopFloat = function(scaleform,method,val)
  PushScaleformMovieFunction(scaleform,method)
  PushScaleformMovieFunctionParameterFloat(val)
  PopScaleformMovieFunctionVoid()
end

Scaleforms.PopInt = function(scaleform,method,val)
  PushScaleformMovieFunction(scaleform,method)
  PushScaleformMovieFunctionParameterInt(val)
  PopScaleformMovieFunctionVoid()
end

Scaleforms.PopBool = function(scaleform,method,val)
  PushScaleformMovieFunction(scaleform,method)
  PushScaleformMovieFunctionParameterBool(val)
  PopScaleformMovieFunctionVoid()
end

-- Push no args
Scaleforms.PopRet = function(scaleform,method)                
  PushScaleformMovieFunction(scaleform, method)
  return PopScaleformMovieFunction()
end

Scaleforms.PopVoid = function(scaleform,method)
  PushScaleformMovieFunction(scaleform, method)
  PopScaleformMovieFunctionVoid()
end

-- Get return
Scaleforms.RetBool = function(ret)
  return GetScaleformMovieFunctionReturnBool(ret)
end

Scaleforms.RetInt = function(ret)
  return GetScaleformMovieFunctionReturnInt(ret)
end

-- Util functions
Scaleforms.TrueType = function(val)
  if type(val) ~= "number" then return type(val); end

  local s = tostring(val)
  if string.find(s,'.') then 
    return "float"
  else
    return "int"
  end
end

Drilling = {}

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local function SetupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 172, true))
    ButtonMessage("Góra")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 173, true))
    ButtonMessage("Dół")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage("Zwiększ prędkość")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 174, true))
    ButtonMessage("Zmniejsz prędkość")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

Drilling.DisabledControls = {30,31,32,33,34,35}

Drilling.Start = function(callback)
    if not Drilling.Active then
        Drilling.Active = true
        if not Drilling.Pause then 
            Drilling.Init()
        end
        Drilling.Update(callback)
    end
end

Drilling.Stop = function()
    if Drilling.Active then
        Drilling.Active = false
        Drilling.Result = 3
        Drilling.Pause = true
    end
end

Drilling.Init = function()
    if Drilling.Scaleform then
        Scaleforms.UnloadMovie(Drilling.Scaleform)
    end

    Drilling.Scaleform = Scaleforms.LoadMovie("VAULT_DRILL")

    Drilling.DrillSpeed = 0.0
    Drilling.DrillPos   = 0.0
    Drilling.DrillTemp  = 0.0
    Drilling.HoleDepth  = 0.0

    Scaleforms.PopVoid(Drilling.Scaleform, "REVEAL")
    Scaleforms.PopFloat(Drilling.Scaleform, "SET_SPEED", 0.0)
    Scaleforms.PopFloat(Drilling.Scaleform, "SET_DRILL_POSITION", 0.0)
    Scaleforms.PopFloat(Drilling.Scaleform, "SET_TEMPERATURE", 0.0)
    Scaleforms.PopFloat(Drilling.Scaleform, "SET_HOLE_DEPTH", 0.0)
    Scaleforms.PopInt(Drilling.Scaleform, "SET_NUM_DISCS", 3)
end

Drilling.Update = function(callback)
    local form = SetupScaleform("instructional_buttons")
    while Drilling.Active do
        Drilling.Draw()
        Drilling.DisableControls()
        Drilling.HandleControls()
        DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
        Wait(0)
    end
    callback(Drilling.Result)
end

Drilling.Draw = function()
    DrawScaleformMovieFullscreen(Drilling.Scaleform,255,255,255,255,255)
end

Drilling.HandleControls = function()
    local last_pos = Drilling.DrillPos
    if IsControlJustPressed(0,172) then
        Drilling.DrillPos = math.min(1.0, Drilling.DrillPos + 0.01)
    elseif IsControlPressed(0,172) then
        Drilling.DrillPos = math.min(1.0, Drilling.DrillPos + (0.1 * GetFrameTime() / ( math.max(0.1, Drilling.DrillTemp) * 10)))
    elseif IsControlJustPressed(0,173) then
        Drilling.DrillPos = math.max(0.0, Drilling.DrillPos - 0.01)
    elseif IsControlPressed(0,173) then
        Drilling.DrillPos = math.max(0.0, Drilling.DrillPos - (0.1 * GetFrameTime()))
    end
    local last_speed = Drilling.DrillSpeed
    if IsControlJustPressed(0,175) then
        Drilling.DrillSpeed = math.min(1.0, Drilling.DrillSpeed + 0.05)
    elseif IsControlPressed(0,175) then
        Drilling.DrillSpeed = math.min(1.0, Drilling.DrillSpeed + (0.5 * GetFrameTime()))
    elseif IsControlJustPressed(0,174) then
        Drilling.DrillSpeed = math.max(0.0, Drilling.DrillSpeed - 0.05)
    elseif IsControlPressed(0,174) then
      Drilling.DrillSpeed = math.max(0.0, Drilling.DrillSpeed - (0.5 * GetFrameTime()))
    end 
    local last_temp = Drilling.DrillTemp
    if last_pos < Drilling.DrillPos then
        if Drilling.DrillSpeed > 0.4 then
            Drilling.DrillTemp = math.min(1.0, Drilling.DrillTemp + ((0.05 * GetFrameTime()) * (Drilling.DrillSpeed * 10)))
            Scaleforms.PopFloat(Drilling.Scaleform, "SET_DRILL_POSITION", Drilling.DrillPos)
        else
            if Drilling.DrillPos < 0.1 or Drilling.DrillPos < Drilling.HoleDepth then
                Scaleforms.PopFloat(Drilling.Scaleform, "SET_DRILL_POSITION", Drilling.DrillPos)
            else
                Drilling.DrillPos = last_pos
                Drilling.DrillTemp = math.min(1.0,Drilling.DrillTemp + (0.01 * GetFrameTime()))
            end
        end
    else
        if Drilling.DrillPos < Drilling.HoleDepth then
            Drilling.DrillTemp = math.max(0.0, Drilling.DrillTemp - ( (0.05 * GetFrameTime()) *  math.max(0.005, (Drilling.DrillSpeed * 10) / 2)) )
        end
        if Drilling.DrillPos ~= Drilling.HoleDepth then
            Scaleforms.PopFloat(Drilling.Scaleform, "SET_DRILL_POSITION", Drilling.DrillPos)
        end
    end 
    if last_speed ~= Drilling.DrillSpeed then
        Scaleforms.PopFloat(Drilling.Scaleform, "SET_SPEED", Drilling.DrillSpeed)
    end 
    if last_temp ~= Drilling.DrillTemp then    
        Scaleforms.PopFloat(Drilling.Scaleform, "SET_TEMPERATURE", Drilling.DrillTemp)
    end 
    if Drilling.DrillTemp >= 1.0 then
        Drilling.Result = 2
        Drilling.Active = false
        Drilling.Pause = false
        Scaleforms.PopVoid(Drilling.Scaleform, "RESET")
    elseif Drilling.DrillPos >= 1.0 then
        Drilling.Result = 1
        Drilling.Active = false
        Drilling.Pause = false
        Scaleforms.PopVoid(Drilling.Scaleform, "RESET")
    end 
    Drilling.HoleDepth = (Drilling.DrillPos > Drilling.HoleDepth and Drilling.DrillPos or Drilling.HoleDepth)
end

Drilling.DisableControls = function()
    for _,control in ipairs(Drilling.DisabledControls) do
        DisableControlAction(0,control,true)
    end
end

Drilling.EnableControls = function()
    for _,control in ipairs(Drilling.DisabledControls) do
        DisableControlAction(0,control,true)
    end
end

AddEventHandler("Drilling:Start",Drilling.Start)
AddEventHandler('Drilling:Stop', Drilling.Stop)
