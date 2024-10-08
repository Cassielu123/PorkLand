local prefabs = {
    "ash",
}

local function onHammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i = 1, math.random(3, 4) do
        local fx = SpawnPrefab("robot_leaf_fx")
        fx.Transform:SetPosition(x + (math.random() * 2) , y + math.random() * 0.5, z + (math.random() * 2))
        if math.random() < 0.5 then
            fx.Transform:SetScale(-1, 1, -1)
        end
    end

    if not inst.components.fixable then
        inst.components.lootdropper:DropLoot()
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_straw")
    inst:Remove()
end

local function onHit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)

    local fx = SpawnPrefab("robot_leaf_fx")
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x, y + math.random() * 0.5, z)

    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_hack")
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/lawnornaments/repair")
end

local function MakeLawnornament(n)
    local assets = {
        Asset("ANIM", "anim/topiary0"..n..".zip"),
        Asset("MINIMAP_IMAGE", "lawnornaments_"..n),
    }

    local function fn(Sim)
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .5)

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("lawnornament_"..n..".tex")

        inst.entity:AddSoundEmitter()
        inst:AddTag("structure")

        inst.AnimState:SetBank("topiary0".. n)
        inst.AnimState:SetBuild("topiary0".. n)

        inst.AnimState:PlayAnimation("idle")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onHammered)
        inst.components.workable:SetOnWorkCallback(onHit)

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "lawnornament"

        MakeSnowCovered(inst)

        inst:ListenForEvent("onbuilt", OnBuilt)

        inst:AddComponent("fixable")
        inst.components.fixable:AddReconstructionStageData("burnt", "topiary0".. n, "topiary0".. n)

        MakeMediumBurnable(inst, nil, nil, true)
        MakeMediumPropagator(inst)

        inst:ListenForEvent("burntup", inst.Remove)

        MakeHauntableWork(inst)

        return inst
    end

    return Prefab("lawnornament_"..n, fn, assets, prefabs)
end

local function MakeLawnornamentPlacer(n)
    return MakePlacer("lawnornament_"..n.."_placer", "topiary0"..n, "topiary0"..n, "idle")
end

local ret = {}

for i=1, 7 do
    table.insert(ret, MakeLawnornament(i))
    table.insert(ret, MakeLawnornamentPlacer(i))
end

return unpack(ret)
