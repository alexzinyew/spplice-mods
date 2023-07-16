import { CBaseEntity, DebugDrawBox, Entities, FrameTime, GetPlayer, IncludeScript, ppmod, printl, Vector } from "peanut-ts-types"
import * as VectorClass from "peanut-ts-types/types/Vector"

//@start
//@ts-ignore
if (!("Entities" in this)) return
IncludeScript("ppmod3")

let blockEnts = [
    "prop_physics", "prop_weighted_cube", "prop_monster_cube", "prop_testchamber_door", "npc_portal_turret_floor",
    "models/props_backstage/item_dropper_wrecked.mdl",
    "models/props_backstage/item_dropper.mdl",
    "models/props_underground/underground_boxdropper.mdl"
]
let loopTime = FrameTime() * 3
//@ts-expect-error
::hurtAmount = 4

let mapSpawn = function(){
    let healthBar = ppmod.text("health", -1, -0.05)
    let plr = GetPlayer()
    let cameras : CBaseEntity[] = []
    let hasCameras = false
    let camera; while(camera = ppmod.get("npc_security_camera", camera)) {
        cameras.push(camera)
        hasCameras = true
    }

    if (hasCameras) {
        ppmod.interval(function(){
            //@ts-expect-error
            for (let index = 0; index < cameras.len(); index++) {
                let camera = cameras[index];
                let playerPosition = plr.EyePosition()
                //@ts-expect-error
                let cameraPosition : VectorClass.Vector = (camera.GetOrigin() + camera.GetForwardVector() * 18)// - Vector(0,0,28)
                //DebugDrawBox(cameraPosition, Vector(-4,-4,-4), Vector(4,4,4), 255, 255, 0, 1, loopTime + FrameTime())

                //@ts-expect-error
                let dir = playerPosition - cameraPosition;
                //@ts-expect-error
                let len = dir.Norm();
                //@ts-expect-error
                let div = [1.0 / dir.x, 1.0 / dir.y, 1.0 / dir.z];

                let worldRay = ppmod.ray(cameraPosition, playerPosition, null, true, [len,div])
                let physRay  = ppmod.ray(cameraPosition, playerPosition, blockEnts, false, [len,div])

                if (physRay == 1 && worldRay == 1) {
                    ppmod.fire(plr, "sethealth", plr.GetHealth() - hurtAmount) //TODO: ppmod.fire value arg should be any
                }
            }
        },loopTime, "stealth_loop")
    }

    ppmod.interval(function(){
        if (plr.GetHealth() <= 0) {
            ppmod.fire("stealth_loop", "Disable")
            healthBar.SetText(`Health: 0`)
        } else healthBar.SetText(`Health: ${plr.GetHealth()}`)
        healthBar.Display()
    })
}

let auto = Entities.CreateByClassname("logic_auto")
ppmod.addscript(auto, "OnNewGame", mapSpawn)
ppmod.addscript(auto, "OnMapTransition", mapSpawn)