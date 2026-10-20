
---@diagnostic disable: param-type-mismatch, assign-type-mismatch

-----------------------------
-----Localized Functions-----
-----------------------------

-- Improves performance, which is needed since this is a lot of code to run
local play_sound = play_sound
local spawn_non_sync_object = spawn_non_sync_object
local obj_copy_pos_and_angle = obj_copy_pos_and_angle
local obj_set_model_extended = obj_set_model_extended
local network_init_object = network_init_object
local network_send_object = network_send_object
local obj_check_if_collided_with_object = obj_check_if_collided_with_object
local set_mario_action = set_mario_action
local cur_obj_was_attacked_or_ground_pounded = cur_obj_was_attacked_or_ground_pounded
local load_object_collision_model = load_object_collision_model
local cur_obj_is_mario_on_platform = cur_obj_is_mario_on_platform
local spawn_mist_particles = spawn_mist_particles
local cur_obj_play_sound_1 = cur_obj_play_sound_1
local cur_obj_hide = cur_obj_hide
local cur_obj_unhide = cur_obj_unhide
local coss = coss
local sins = sins
local obj_copy_pos = obj_copy_pos
local cur_obj_rotate_face_angle_using_vel = cur_obj_rotate_face_angle_using_vel
local cur_obj_move_using_vel = cur_obj_move_using_vel
local nearest_player_to_object = nearest_player_to_object
local spawn_red_coin_cutscene_star = spawn_red_coin_cutscene_star
local cur_obj_play_sound_2 = cur_obj_play_sound_2
local cur_obj_init_animation = cur_obj_init_animation
local obj_return_home_if_safe = obj_return_home_if_safe
local obj_turn_toward_object = obj_turn_toward_object
local is_point_within_radius_of_mario = is_point_within_radius_of_mario
local object_step = object_step
local obj_scale = obj_scale
local cur_obj_scale = cur_obj_scale
local cur_obj_update_floor_and_walls = cur_obj_update_floor_and_walls
local cur_obj_if_hit_wall_bounce_away = cur_obj_if_hit_wall_bounce_away
local cur_obj_move_standard = cur_obj_move_standard
local cur_obj_update_floor_height_and_get_floor = cur_obj_update_floor_height_and_get_floor
local cur_obj_become_tangible = cur_obj_become_tangible
local obj_get_first_with_behavior_id = obj_get_first_with_behavior_id
local obj_get_next_with_same_behavior_id = obj_get_next_with_same_behavior_id
local cur_obj_scale_over_time = cur_obj_scale_over_time
local cur_obj_shake_screen = cur_obj_shake_screen
local lateral_dist_between_objects = lateral_dist_between_objects
local dist_between_objects = dist_between_objects
local obj_mark_for_deletion = obj_mark_for_deletion
local mario_stop_riding_object = mario_stop_riding_object
local obj_get_next_with_behavior_id = obj_get_next_with_behavior_id
local obj_count_objects_with_behavior_id = obj_count_objects_with_behavior_id

-- Packing and unpacking like this allows for C-like type conversions
local string_pack = string.pack
local string_unpack = string.unpack
---@param value number
---@param pack_fmt string
---@param unpack_fmt string
local repack = function (value, pack_fmt, unpack_fmt)
    return string_unpack(unpack_fmt, string_pack(pack_fmt, value))
end

--------------------------
-----Helper Variables-----
--------------------------

local id_bhvFlipswap_Platform_Border_MOP = id_bhvUnused05A8
local id_bhvShrink_Platform_Border_MOP = id_bhvUnused05A8
local id_bhvGreen_Switchboard_Gears_MOP = id_bhvUnused05A8

local PURPLE_SWITCH_IDLE = 0
local PURPLE_SWITCH_PRESSED = 1
local PURPLE_SWITCH_TICKING = 2
local PURPLE_SWITCH_UNPRESSED = 3
local PURPLE_SWITCH_WAIT_FOR_MARIO_TO_GET_OFF = 4

local ANM_swim = 0
local ANM_attack = 1

local BLARGG_ACT_SWIM = 0
local BLARGG_ACT_CHASE = 1
local BLARGG_ACT_KNOCKBACK = 2
local BLARGG_ACT_BACKUP = 3

local FRIENDLY_BLARGG_ACT_IDLE = 0
local FRIENDLY_BLARGG_ACT_BEING_RIDDEN = 1

--------------------------
-----Helper Functions-----
--------------------------

-- ##### Switch statements are only faster when there's several different states
-- ##### This is because each lookup of the switch statement creates an entirely new function
-- ##### However the performance overhead isn't significant at all so use it whenever you feel like it
---@param param any
---@param case_table table<any, function>
---@return function?
local function switch(param, case_table)
    local case = case_table[param]
    if case then return case() end
    local def = case_table['default']
    return def and def() or nil
end

--- Moves Mario to the top of the object, then sets his Y speed and resets his fall.
---@param m MarioState
---@param obj Object
---@param new_velY integer
local function bounce_off_object(m, obj, new_velY)
    m.pos.y = obj.oPosY + obj.hitboxHeight
    m.vel.y = new_velY

    -- MARIO_UNKNOWN_8 is the flag that controls Mario's screaming when he falls from a high place
    -- This removes the flag so he can scream again
    m.flags = m.flags & ~MARIO_UNKNOWN_08

    play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, m.marioObj.header.gfx.cameraToObject)
end

--- Gets closer to a goal value by the increment when ran
---@param goal integer
---@param src integer
---@param inc integer
local function approach_by_increment(goal, src, inc)
    local diff = goal - src
    if diff > inc then
        return src + inc
    elseif diff < -inc then
        return src - inc
    else
        return goal
    end
end

---@param m MarioState
---@return boolean
local function is_bubbled(m)
    return m.action == ACT_BUBBLED
end

---@param parent Object
---@param model ModelExtendedId
---@param behaviorId BehaviorId
local function spawn_object(parent, model, behaviorId)
    local obj = spawn_non_sync_object(behaviorId, model, 0, 0, 0, nil)
    if not obj then return nil end

    obj_copy_pos_and_angle(obj, parent)
    return obj
end

---@return boolean
local function is_current_area_sync_valid()
    local np = gNetworkPlayers
    for i = 1, MAX_PLAYERS - 1, 1 do
        if np[i] and np[i].connected and
        (not np[i].currLevelSyncValid or not np[i].currAreaSyncValid) and
        is_player_in_local_area(gMarioStates[i]) ~= 0 then
            return false
        end
    end
    return true
end

---@param start_point number
---@param end_point number
---@param time number
---@return number
local function lerp(start_point, end_point, time)
    return start_point * (1 - time) + end_point * time
end

local function bhv_koopa_shell_flame_spawn(obj)
    for i = 0, 2 do
        spawn_object(obj, E_MODEL_RED_FLAME, id_bhvKoopaShellFlame)
    end
end

--- @param obj Object
--- @param hitbox ObjectHitbox
local function obj_set_hitbox(obj, hitbox)
    if not obj or not hitbox then return end
    -- Sets other hitbox values once
    if (obj.oFlags & OBJ_FLAG_30) == 0 then
        obj.oFlags = obj.oFlags | OBJ_FLAG_30

        obj.oInteractType = hitbox.interactType
        obj.oDamageOrCoinValue = hitbox.damageOrCoinValue
        obj.oHealth = hitbox.health
        obj.oNumLootCoins = hitbox.numLootCoins

        cur_obj_become_tangible()
    end

    -- Set actual hitboxes
    obj.hitboxRadius = obj.header.gfx.scale.x * hitbox.radius
    obj.hitboxHeight = obj.header.gfx.scale.y * hitbox.height
    obj.hurtboxRadius = obj.header.gfx.scale.x * hitbox.hurtboxRadius
    obj.hurtboxHeight = obj.header.gfx.scale.y * hitbox.hurtboxHeight
    obj.hitboxDownOffset = obj.header.gfx.scale.y * hitbox.downOffset
end

-- --- Global Switch State (Shared) ---
local START_STATE = 1
local switch_block_state = START_STATE
local scalar_timer = 0
local StarSpawned = false

hook_event(HOOK_ON_PACKET_RECEIVE, function (datatable)
    if datatable.timer then scalar_timer = datatable.timer end
    if datatable.state then switch_block_state = datatable.state end
end)

hook_event(HOOK_ON_LEVEL_INIT, function ()
    switch_block_state = START_STATE
    StarSpawned = false
end)
-- bhvGreen_Switchboard_MOP

local E_MODEL_GREEN_SWITCHBOARD = smlua_model_util_get_id("Green_Switchboard_MOP")
local E_MODEL_GREEN_SWITCHBOARD_GEARS = smlua_model_util_get_id("Green_Switchboard_Gears_MOP")

function bhv_Green_Switchboard_init(obj)
    obj_set_model_extended(obj, E_MODEL_GREEN_SWITCHBOARD)
    obj.oIntroLakituCloud = spawn_object(obj, E_MODEL_GREEN_SWITCHBOARD_GEARS, id_bhvGreen_Switchboard_Gears_MOP)
end

function bhv_Green_Switchboard_loop(obj)
    local MAX_SPEED = 20.0
    local SPEED_INC = 2.0
    local child = obj.oIntroLakituCloud
    local dot = 0
    local dotH = 0

    child.oFaceAnglePitch = child.oFaceAnglePitch + (obj.oForwardVel * 200)
    obj_copy_pos(child, obj)

    if cur_obj_is_mario_on_platform() == 1 and not is_bubbled(gMarioStates[0]) then
        local m = gMarioStates[0]

        local dx = m.pos.x - obj.oPosX
        local dz = m.pos.z - obj.oPosZ
        local dHx = obj.oPosX - obj.oHomeX
        local dHz = obj.oPosZ - obj.oHomeZ
        local facingZ = coss(obj.oFaceAngleYaw)
        local facingX = sins(obj.oFaceAngleYaw)

        dot = facingZ * dz + facingX * dx
        dotH = facingZ * dHz + facingX * dHx

        if dot > 0 then
            if dotH < ((obj.oBehParams >> 24) & 0xFF) * 16 then
                obj.oForwardVel = approach_by_increment(MAX_SPEED, obj.oForwardVel, SPEED_INC)
            else
                obj.oForwardVel = 0
            end
            obj.oFaceAnglePitch = approach_by_increment(2048.0, obj.oFaceAnglePitch, 128.0)
        else
            if dotH > obj.oBehParams2ndByte * -16 then
                obj.oForwardVel = approach_by_increment(-MAX_SPEED, obj.oForwardVel, SPEED_INC)
            else
                obj.oForwardVel = 0
            end
            if (obj.oFaceAnglePitch > -2048) then
                obj.oFaceAnglePitch = approach_by_increment(-2048.0, obj.oFaceAnglePitch, 128.0)
            end
        end
    else
        obj.oForwardVel = approach_by_increment(0.0, obj.oForwardVel, SPEED_INC)
        obj.oFaceAnglePitch = approach_by_increment(0.0, obj.oFaceAnglePitch, 128.0)
    end

    cur_obj_move_using_vel()
    load_object_collision_model()
end

function bhv_Green_Switchboard_Gears_loop(obj)
    local parent = obj.parentObj
    if not parent then return end

    obj_copy_pos(obj, parent)
    obj.oFaceAnglePitch = obj.oFaceAnglePitch + parent.oForwardVel * 200
end

-- bhvNoteblock_MOP

local E_MODEL_NOTEBLOCK = smlua_model_util_get_id("Noteblock_MOP")
local NOTEBLOCK_ACT_IDLE = 0
local NOTEBLOCK_ACT_BOUNCING = 1

function bhv_noteblock_init(obj)
    obj_set_model_extended(obj, E_MODEL_NOTEBLOCK)
end

function bhv_noteblock_loop(obj)
    local m = gMarioStates[0]
    local y_spd = 64

    if cur_obj_is_mario_on_platform() == 1 and not is_bubbled(m) then
        -- Jump. If A is pressed during the jump, increase y_spd.
        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            y_spd = y_spd + 12
            spawn_mist_particles()
        end
        set_mario_action(m, ACT_DOUBLE_JUMP, 0)

        -- Calculates y speed
        local intermediate_y_spd = repack(y_spd, "f", "I")
		intermediate_y_spd = intermediate_y_spd + (obj.oBehParams2ndByte << 16)
		y_spd = repack(intermediate_y_spd, "I", "f")
		m.vel.y = y_spd

        obj.oAction = NOTEBLOCK_ACT_BOUNCING
    end

    if obj.oAction == NOTEBLOCK_ACT_BOUNCING then
        if obj.oTimer == 4 then
            obj.oAction = NOTEBLOCK_ACT_IDLE
            obj.oPosY = obj.oHomeY
        else
            -- Moves the noteblock slightly up and down, to give it a "bounce"
            if obj.oTimer > 2 then
                obj.oPosY = obj.oHomeY + (obj.oTimer % 3) * 6
            else
                obj.oPosY = obj.oHomeY - obj.oTimer * 6
            end
        end
    end
end

-- bhvShell_1_MOP

function bhv_shell_init(obj)
    obj_mark_for_deletion(obj)
end

-- bhvShell_2_MOP

function bhv_shell_init(obj)
    obj_mark_for_deletion(obj)
end

-- bhvSpring_MOP

local E_MODEL_SPRING = smlua_model_util_get_id("Spring_MOP")
local SPRING_ACT_READY = 0
local SPRING_ACT_USED = 1

function bhv_Spring_init(obj)
    obj_set_model_extended(obj, E_MODEL_SPRING)
end

function bhv_Spring_loop(obj)
    local m = gMarioStates[0]
    if is_bubbled(m) then return end

    -- Initial y speed
    local Yspd = 56.0
    local y_vel = nil
    local forward_vel = nil

    if obj.oAction == SPRING_ACT_READY then
        if obj_check_if_collided_with_object(obj, m.marioObj) ~= 0 then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
            m.faceAngle.y = obj.oFaceAngleYaw

            y_vel = repack(Yspd, "f", "I")
            -- Calculates how fast Mario should go using oBehParams2ndByte
            forward_vel = repack(y_vel + (obj.oBehParams & 0x00FF0000), "I", "f")
            m.forwardVel = forward_vel

            -- Calculates how high Mario should go using the 1st byte
            y_vel = y_vel + (((obj.oBehParams >> 24) & 0xFF) << 16)
            bounce_off_object(m, obj, repack(y_vel, "I", "f"))

            -- Prevent interaction for some time
            obj.oAction = SPRING_ACT_USED
        end
    else
        if obj.oTimer == 15 then
            obj.oAction = SPRING_ACT_READY
        end
    end
end

-- bhvSwitchblock_MOP

local E_MODEL_SWITCHBLOCK = smlua_model_util_get_id("Switchblock_MOP")
local SWITCHBLOCK_ACT_ACTIVE = 0
local SWITCHBLOCK_ACT_INACTIVE = 1

function bhv_Switchblock_init(obj)
    obj_set_model_extended(obj, E_MODEL_SWITCHBLOCK)
end

function bhv_Switchblock_loop(obj)
    -- Determines which block color this becomes
    obj.oAnimState = obj.oBehParams2ndByte + obj.oAction

    -- Only loads collision if the corresponding switch is pressed
    if switch_block_state == obj.oBehParams2ndByte >> 1 then
        load_object_collision_model()
        obj.oAction = SWITCHBLOCK_ACT_ACTIVE
    else
        obj.oAction = SWITCHBLOCK_ACT_INACTIVE
    end
end

-- bhvSwitchblock_Switch_MOP

local E_MODEL_SWITCHBLOCK_SWITCH = smlua_model_util_get_id("Switchblock_Switch_MOP")

function bhv_Switchblock_Switch_init(obj)
    obj_set_model_extended(obj, E_MODEL_SWITCHBLOCK_SWITCH)
end

function bhv_Switchblock_Switch_loop(obj)
    obj.oAnimState = obj.oBehParams2ndByte
    local old_state = switch_block_state
    if cur_obj_is_mario_on_platform() == 1 and not is_bubbled(gMarioStates[0]) then
        switch_block_state = obj.oBehParams2ndByte
    end

    local scalar = 0
    if switch_block_state ~= obj.oBehParams2ndByte then
        scalar = 1
    end

    -- Whenever the switch block state changes
    if old_state ~= switch_block_state then
        scalar_timer = 0
        local np = gNetworkPlayers
        for i = 1, MAX_PLAYERS - 1, 1 do
            if is_current_area_sync_valid() and np[0].currLevelNum == np[i].currLevelNum then
                network_send_to(i, true, { timer = 0, state = switch_block_state })
            end
        end
    end

    -- Slowly raise and lower the switch
    if scalar_timer < 100 then
        scalar_timer = scalar_timer + 1
    end

    local result = scalar * 0.9 + 0.1
    local current_scale = obj.header.gfx.scale.y

    -- Make smaller if the switch is pressed
    obj.header.gfx.scale.y = lerp(current_scale, result, scalar_timer * 0.01)
end
