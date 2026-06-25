//-----------------------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------------------

#define NAMETAG_DRAW_DISTANCE   (15.0)
#define NAMETAG_COLOR_NORMAL    (0xFFFFFFFF)
#define NAMETAG_COLOR_DAMAGED   (0xFF0000FF)
#define NAMETAG_DAMAGE_DURATION (1500)

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------

static Text3D:s_PlayerNameTag[MAX_PLAYERS] = { Text3D:INVALID_3DTEXT_ID, ... };
static s_NametagResetTimer[MAX_PLAYERS] = { -1, ... };

//-----------------------------------------------------------------------------
// Forwards
//-----------------------------------------------------------------------------

forward Nametag_ResetColor(playerid);

//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

static Nametag_BuildLabel(playerid, output[], len)
{
    new charname[31];
    GetPlayerCharacterName(playerid, charname);

    if (strlen(charname) == 0)
    {
        output[0] = EOS;
        return 0;
    }
    
    // Formato: Nombre_Apellido(ID)
    format(output, len, "%s(%d)", charname, playerid);
    return 1;
}

static Nametag_CreateLabel(playerid, color)
{
    if (s_PlayerNameTag[playerid] != Text3D:INVALID_3DTEXT_ID)
    {
        Delete3DTextLabel(s_PlayerNameTag[playerid]);
        s_PlayerNameTag[playerid] = Text3D:INVALID_3DTEXT_ID;
    }

    new label[64];
    if (!Nametag_BuildLabel(playerid, label, sizeof(label)))
        return 0;

    s_PlayerNameTag[playerid] = Create3DTextLabel(
        label,
        color,
        0.0,
        0.0,
        0.5,
        NAMETAG_DRAW_DISTANCE,
        0,
        true
    );

    if (s_PlayerNameTag[playerid] == Text3D:INVALID_3DTEXT_ID)
        return 0;

    Attach3DTextLabelToPlayer(
        s_PlayerNameTag[playerid],
        playerid,
        0.0,
        0.0,
        0.5
    );

    return 1;
}

Nametag_Show(playerid)
{
    return Nametag_CreateLabel(playerid, NAMETAG_COLOR_NORMAL);
}

Nametag_Hide(playerid)
{
    if (s_NametagResetTimer[playerid] != -1)
    {
        KillTimer(s_NametagResetTimer[playerid]);
        s_NametagResetTimer[playerid] = -1;
    }

    if (s_PlayerNameTag[playerid] != Text3D:INVALID_3DTEXT_ID)
    {
        Delete3DTextLabel(s_PlayerNameTag[playerid]);
        s_PlayerNameTag[playerid] = Text3D:INVALID_3DTEXT_ID;
    }

    return 1;
}

Nametag_Update(playerid)
{
    Nametag_Hide(playerid);
    Nametag_Show(playerid);
    return 1;
}

Nametag_OnDamage(playerid)
{
    if (s_PlayerNameTag[playerid] == Text3D:INVALID_3DTEXT_ID)
        return 0;

    if (s_NametagResetTimer[playerid] != -1)
    {
        KillTimer(s_NametagResetTimer[playerid]);
        s_NametagResetTimer[playerid] = -1;
    }

    Nametag_CreateLabel(playerid, NAMETAG_COLOR_DAMAGED);

    s_NametagResetTimer[playerid] = SetTimerEx(
        "Nametag_ResetColor",
        NAMETAG_DAMAGE_DURATION,
        false,
        "d",
        playerid
    );

    return 1;
}

public Nametag_ResetColor(playerid)
{
    s_NametagResetTimer[playerid] = -1;

    if (!IsPlayerConnected(playerid))
        return 0;

    Nametag_CreateLabel(playerid, NAMETAG_COLOR_NORMAL);
    return 1;
}