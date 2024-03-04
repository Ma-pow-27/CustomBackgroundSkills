math.random(Ext.Utils.MonotonicTime())

function GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local ExcludedProgressions = {
    "NPC_",
    "Origin_",
    "MulticlassSpellSlots",
    "Phasm"
}

function DoNotExclude(ProgressionName)
    -- write exclusion function for certian progressions
    for index, value in ipairs(ExcludedProgressions) do
        if (string.find(ProgressionName, value) ~= nil) 
        then
            return false
        end
    end
    return true
    -- returns true or false if the input should be excluded from the ReleventProgressions array
end

GenerateUUID()



Ext.Events.StatsLoaded:Subscribe(function (e)

    local Passives = Ext.Stats.GetStats("PassiveData")
    local Progressions = Ext.StaticData.GetAll("Progression")
    
    --Passive Background skill proficencies removal
    for _,name in pairs(Passives) do
        local Data = Ext.Stats.Get(name)
        if(string.find(tostring(name), "Background_") ~= nil)
        then
            --_P("\n".. name)
            Data.Boosts = ""
            --_D(Data.Boosts) 
        end
    end

    -- Progressions skill proficencies choices added
    
    -- Identify progressions to update
    local ReleventProgressions = {}


    for _,guid in pairs(Progressions) do
        local Data = Ext.StaticData.Get(guid,"Progression")
        if(Data.Level == 1 and Data.ProgressionType == 0)
        then
            if(DoNotExclude(Data.Name))
            then
                --_P("Adding " .. Data.Name)
                table.insert(ReleventProgressions, Data)
            end
        end
    end

    -- add skill choices to progressions
    for _, item  in pairs(ReleventProgressions) do
        local skillchoices = item.SelectSkills

        if(#skillchoices == 1)
        then
            skillchoices[1].Amount =  skillchoices[1].Amount + 2
        else
            _P("Background Skills Choice: unexpected ammount of current SelectSkills from " .. item.Name)
            _P("Not Adding More Skill Choices to " .. item.Name)
        end
        --_P("Progression Name: " .. item.Name)
        --_D(item.SelectSkills)
    end
end)