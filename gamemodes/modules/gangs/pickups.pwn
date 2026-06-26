//----------------------------------------------------------------------------- 
// Gang pickup entry points
//-----------------------------------------------------------------------------

#define MAX_GANG_PICKUPS 10

new const Float:gGangPickupCoords[MAX_GANG_PICKUPS][4] = {
    {2469.5876, -1650.4285, 13.4718, 181.7289}, // GSF
    {1069.9822, -1105.7804, 24.4855, 89.9556},  // TDF
    {2794.1379, -1944.5647, 13.5469, 269.6470}, // SBF
    {2070.6934, -1593.7333, 13.4990, 179.1023}, // FYB
    {2520.0503, -1488.5048, 23.9974, 359.8798}, // RHB
    {1970.9397, -1271.4243, 23.9844, 359.9033}, // TDB
    {2382.2859, -1933.2955, 13.5469, 357.4721}, // KTB
    {2505.0974, -1246.1855, 35.1471, 180.8580}, // LSV
    {1949.1451, -2061.7173, 13.5469, 359.5697}, // VLA
    {1580.2111, -1634.6788, 13.5617, 89.6916}   // LSPD
};

new g_GangPickupID[MAX_GANG_PICKUPS];
new Text3D:g_GangPickupLabelID[MAX_GANG_PICKUPS][2];
new g_GangPickupName[MAX_GANG_PICKUPS][32] = {
    "Grove Street Families",
    "Temple Drive Families",
    "Seville Boulevard Families",
    "Front Yard Ballas",
    "Rollin' Heights Ballas",
    "Temple Drive Ballas",
    "Kilo Tray Ballas",
    "Los Santos Vagos",
    "Varrio Los Aztecas",
    "Los Santos Police Department"
};
new g_GangPickupTag[MAX_GANG_PICKUPS][8] = {
    "[GSF]",
    "[TDF]",
    "[SBF]",
    "[FYB]",
    "[RHB]",
    "[TDB]",
    "[KTB]",
    "[LSV]",
    "[VLA]",
    "[LSPD]"
};

new g_GangPickupModel[MAX_GANG_PICKUPS] = {
    1314,
    1314,
    1314,
    1314,
    1314,
    1314,
    1314,
    1314,
    1314,
    1247
};

new g_GangPickupColor[MAX_GANG_PICKUPS] = {
    COLOR_GSF,
    COLOR_TDF,
    COLOR_SBF,
    COLOR_FYB,
    COLOR_RHB,
    COLOR_TDB,
    COLOR_KTB,
    COLOR_LSV,
    COLOR_VLA,
    COLOR_LSPD
};

new bool:g_GangPickupSeen[MAX_PLAYERS][MAX_GANG_PICKUPS];
new g_GangPickupPending[MAX_PLAYERS];
new g_PlayerGang[MAX_PLAYERS];

forward GangPickupResetTimer();

public OnGameModeInit()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        g_GangPickupPending[playerid] = -1;
        g_PlayerGang[playerid] = -1;
    }

    for (new i = 0; i < MAX_GANG_PICKUPS; i++)
    {
        g_GangPickupID[i] = CreatePickup(g_GangPickupModel[i], 1,
            gGangPickupCoords[i][0],
            gGangPickupCoords[i][1],
            gGangPickupCoords[i][2],
            0);

        if (g_GangPickupID[i] != INVALID_PICKUP)
        {
            new labelText[64];
            format(labelText, sizeof labelText, "%s", g_GangPickupName[i]);
            g_GangPickupLabelID[i][0] = Create3DTextLabel(
                labelText,
                g_GangPickupColor[i],
                gGangPickupCoords[i][0],
                gGangPickupCoords[i][1],
                gGangPickupCoords[i][2] + 0.8,
                25.0,
                0,
                false);

            g_GangPickupLabelID[i][1] = Create3DTextLabel(
                "[Spawn]",
                COLOR_WHITE,
                gGangPickupCoords[i][0],
                gGangPickupCoords[i][1],
                gGangPickupCoords[i][2] + 0.58,
                25.0,
                0,
                false);
        }
    }

    SetTimer("GangPickupResetTimer", 1000, true);
    return 1;
}

public GangPickupResetTimer()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid))
        {
            continue;
        }

        new Float:px;
        new Float:py;
        new Float:pz;
        GetPlayerPos(playerid, px, py, pz);

        for (new i = 0; i < MAX_GANG_PICKUPS; i++)
        {
            if (!g_GangPickupSeen[playerid][i])
            {
                continue;
            }

            new Float:dx = px - gGangPickupCoords[i][0];
            new Float:dy = py - gGangPickupCoords[i][1];
            new Float:dz = pz - gGangPickupCoords[i][2];
            if (dx*dx + dy*dy + dz*dz > 4.0)
            {
                g_GangPickupSeen[playerid][i] = false;
                if (g_GangPickupPending[playerid] == i)
                {
                    g_GangPickupPending[playerid] = -1;
                }
            }
        }
    }

    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    for (new i = 0; i < MAX_GANG_PICKUPS; i++)
    {
        if (pickupid != g_GangPickupID[i])
        {
            continue;
        }

        if (g_GangPickupSeen[playerid][i])
        {
            break;
        }

        g_GangPickupSeen[playerid][i] = true;
        g_GangPickupPending[playerid] = i;

        new message[256];
        if (i == 9)
        {
            format(message, sizeof message,
                "Interested in serving the city?\nUse /joinlspd to learn the recruitment process and how to join the Los Santos Police Department.");
        }
        else
        {
            format(message, sizeof message,
                "This hood belongs to %s %s.\nUse /joingang to roll with this gang.",
                g_GangPickupName[i], g_GangPickupTag[i]);
        }

        SendClientMessage(playerid, COLOR_FACTION, message);
        break;
    }

    return 1;
}

