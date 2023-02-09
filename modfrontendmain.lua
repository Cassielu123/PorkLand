OnUnloadMod = function()
    local servercreationscreen = GLOBAL.TheFrontEnd:GetOpenScreenOfType("ServerCreationScreen")

    if not (servercreationscreen and servercreationscreen.world_tabs and servercreationscreen.world_tabs[1])  then
        return
    end

    servercreationscreen:SetLevelLocations()

    local world_tab = servercreationscreen.world_tabs[1]

    if world_tab.choose_world_menu then
        world_tab.choose_world_menu:Hide()
    end

    if world_tab.choose_world_button then
        world_tab.choose_world_button:Hide()
    end
end