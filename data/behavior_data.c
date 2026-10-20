// bhvGreen_Switchboard_MOP

const BehaviorScript bhvGreen_Switchboard_MOP[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    LOAD_COLLISION_DATA(col_Green_Switchboard_MOP_0x7ddc38),
    SET_FLOAT(oCollisionDistance, 1024),
    CALL_NATIVE(bhv_Green_Switchboard_init),
    BEGIN_LOOP(),
    CALL_NATIVE(bhv_Green_Switchboard_loop),
    END_LOOP(),
};

const BehaviorScript bhvGreen_Switchboard_Gears_MOP[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    BEGIN_LOOP(),
    CALL_NATIVE(bhv_Green_Switchboard_Gears_loop),
    END_LOOP(),
};


// bhvNoteblock_MOP

const BehaviorScript bhvNoteblock_MOP[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    SET_HOME(),
    LOAD_COLLISION_DATA(col_Noteblock_MOP_0xaa6444),
    SCALE(0, 64),
    CALL_NATIVE(bhv_noteblock_init),
    BEGIN_LOOP(),
    CALL_NATIVE(bhv_noteblock_loop),
    CALL_NATIVE(load_object_collision_model),
    END_LOOP(),
};


// bhvShell_1_MOP

const BehaviorScript bhvShell_1_MOP[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    CALL_NATIVE(bhv_shell_init),
    BREAK(),
};


// bhvShell_2_MOP

const BehaviorScript bhvShell_2_MOP[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    CALL_NATIVE(bhv_shell_init),
    BREAK(),
};


// bhvSpring_MOP

const BehaviorScript bhvSpring_MOP[] = {
    BEGIN(OBJ_LIST_LEVEL),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    SET_HITBOX(160, 160),
    SET_INTERACT_TYPE(INTERACT_COIN),
    SET_INT(oIntangibleTimer, 0),
    CALL_NATIVE(bhv_Spring_init),
    BEGIN_LOOP(),
    CALL_NATIVE(bhv_Spring_loop),
    END_LOOP(),
};


// bhvSwitchblock_MOP

const BehaviorScript bhvSwitchblock_MOP[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    LOAD_COLLISION_DATA(col_Switchblock_MOP_0x7d3058),
    SET_FLOAT(oCollisionDistance, 512),
    CALL_NATIVE(bhv_Switchblock_init),
    BEGIN_LOOP(),
    CALL_NATIVE(bhv_Switchblock_loop),
    END_LOOP(),
};


// bhvSwitchblock_Switch_MOP

const BehaviorScript bhvSwitchblock_Switch_MOP[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    LOAD_COLLISION_DATA(col_Switchblock_Switch_MOP_0x7d7348),
    SET_FLOAT(oCollisionDistance, 512),
    CALL_NATIVE(bhv_Switchblock_Switch_init),
    BEGIN_LOOP(),
    CALL_NATIVE(load_object_collision_model),
    CALL_NATIVE(bhv_Switchblock_Switch_loop),
    END_LOOP(),
};

