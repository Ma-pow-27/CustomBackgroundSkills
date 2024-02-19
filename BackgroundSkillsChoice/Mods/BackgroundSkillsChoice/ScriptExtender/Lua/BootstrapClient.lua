math.random(Ext.Utils.MonotonicTime())

function GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local ExcludedProgressions = {
    "CL_",
    "Trips_Aasimar_1"
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
        if(Data.Level == 1 and Data.ProgressionType == 2)
        then
            if(DoNotExclude(Data.Name))
            then
                --_P("Adding " .. Data.Name)
                local iter = 1
                while (iter <= #ReleventProgressions) do
                    if(string.find(tostring(Data.Name), ReleventProgressions[iter].Name) ~= nil)
                    then
                        --_P(string.format("Removing %s", ReleventProgressions[iter].Name))
                        table.remove(ReleventProgressions, iter)
                    end
                    iter = iter + 1
                end
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
            skillchoices[1].Arg3 = "HumanVersatility"
            skillchoices[1].UUID = "f974ebd6-3725-4b90-bb5c-2b647d41615d"
        elseif(#skillchoices > 1)
        then
            _P("Background Skills Choice: unexpected ammount of current SelectSkills from " .. item.Name)
        else
            skillchoices[#skillchoices + 1] = {Amount = 2, Arg3 = "HumanVersatility", UUID = "f974ebd6-3725-4b90-bb5c-2b647d41615d"}
        end
        --_P("Progression Name: " .. item.Name)
        --_D(item.SelectSkills)
    end

    --set default values of the added skills choices
    
    --[[ local SkillsDF = Ext.StaticData.GetAll("SkillDefaultValues")
    local NumDefaultSkills = #SkillsDF

    for num, item  in pairs(ReleventProgressions) do
        local ReleventTableUUID = item.TableUUID
        _P(ReleventTableUUID)

        local NewGuid = GenerateUUID()

        SkillsDF[NumDefaultSkills + num] = NewGuid
        _P(NewGuid)
        _P(Ext.StaticData.Get(NewGuid, "SkillDefaultValues"))

            {
                Add = {
                    "Persuasion",
                    "Survival",
                    "Investigation",
                    "Performance",
                    "History",
                    "Religion",
                    "Perception",
                    "Stealth",
                    "SleightOfHand",
                    "Athletics",
                    "Acrobatics",
                    "Deception",
                    "Intimidation",
                    "AnimalHandling",
                    "Arcana",
                    "Insight",
                    "Medicine",
                    "Nature"
                },
                Level = 1,
                SelectorId = "HumanVersatility",
                TableUUID = ReleventTableUUID,
                ResourceUUID = NewGuid
            }
    end

    for key, value in pairs(SkillsDF) do
        local Data = Ext.StaticData.Get(value,"SkillDefaultValues")
        _D(value)
        _D(Data)
    end  ]]
    
end)