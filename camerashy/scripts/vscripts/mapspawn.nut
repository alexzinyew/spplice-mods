//@ts-ignore
if (!("Entities" in this))
    return;
IncludeScript("ppmod3");
local blockEnts = [
    "prop_physics", "prop_weighted_cube", "prop_monster_cube", "prop_testchamber_door", "npc_portal_turret_floor",
    "models/props_backstage/item_dropper_wrecked.mdl",
    "models/props_backstage/item_dropper.mdl",
    "models/props_underground/underground_boxdropper.mdl"
];
local loopTime = FrameTime() * 3;
hurtAmount = 4;
local mapSpawn = function ():(blockEnts,loopTime) {
    local healthBar = ppmod.text("health", -1, -0.05);
    local plr = GetPlayer();
    local cameras = [];
    local hasCameras = false;
    local camera;
    while (camera = ppmod.get("npc_security_camera", camera)) {
        cameras.push(camera);
        hasCameras = true;
    }
    if (hasCameras) {
        ppmod.interval(function ():(blockEnts,loopTime,healthBar,plr,cameras,hasCameras,camera) {
            //@ts-expect-error
            for (local index = 0; index < cameras.len(); index++) {
                local camera = cameras[index];
                local playerPosition = plr.EyePosition();
                //@ts-expect-error
                local cameraPosition = (camera.GetOrigin() + camera.GetForwardVector() * 18); // - Vector(0,0,28)
                //DebugDrawBox(cameraPosition, Vector(-4,-4,-4), Vector(4,4,4), 255, 255, 0, 1, loopTime + FrameTime())
                //@ts-expect-error
                local dir = playerPosition - cameraPosition;
                //@ts-expect-error
                local len = dir.Norm();
                //@ts-expect-error
                local div = [1.0 / dir.x, 1.0 / dir.y, 1.0 / dir.z];
                local worldRay = ppmod.ray(cameraPosition, playerPosition, null, true, [len, div]);
                local physRay = ppmod.ray(cameraPosition, playerPosition, blockEnts, false, [len, div]);
                if (physRay == 1 && worldRay == 1) {
                    ppmod.fire(plr, "sethealth", plr.GetHealth() - hurtAmount); //TODO: ppmod.fire value arg should be any
                }
            }
        }, loopTime, "stealth_loop");
    }
    ppmod.interval(function ():(blockEnts,loopTime,healthBar,plr,cameras,hasCameras,camera) {
        if (plr.GetHealth() <= 0) {
            ppmod.fire("stealth_loop", "Disable");
            healthBar.SetText("Health: 0");
        }
        else
            healthBar.SetText("Health: "+(plr.GetHealth())+"");
        healthBar.Display();
    });
};
local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", mapSpawn);
ppmod.addscript(auto, "OnMapTransition", mapSpawn);
