forward ShowLSPDRecruitmentDialog(playerid);

#define GANG_LSPD 9

command(joingang, playerid, params[])
{
    #pragma unused params

    new gangIndex = g_GangPickupPending[playerid];
    if (gangIndex == GANG_NONE)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You must be at a gang spawn to use this command.");
        return 1;
    }

    if (gangIndex == GANG_LSPD)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}Use /joinlspd to see the LSPD recruitment dialog.");
        return 1;
    }

    if (gettime() < g_PlayerGangCooldown[playerid])
    {
        new secondsLeft = g_PlayerGangCooldown[playerid] - gettime();

        new cooldownMsg[128];
        format(cooldownMsg, sizeof cooldownMsg,
            "{ff6347}[ ! ]: {FFFFFF}You must wait %d seconds before changing your gang.",
            secondsLeft
        );

        SendClientMessage(playerid, -1, cooldownMsg);
        return 1;
    }

    if (g_PlayerGang[playerid] != GANG_NONE)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You must leave your current gang before joining another one. Use /leavegang.");
        return 1;
    }

    g_GangPickupPending[playerid] = GANG_NONE;
    g_PlayerGang[playerid] = gangIndex;
    g_PlayerGangCooldown[playerid] = gettime() + GANG_CHANGE_COOLDOWN;

    new response[160];
    format(response, sizeof(response),
        "{FFFFFF}[ HOMIE ]: You've joined {%06x}%s %s{FFFFFF}. Represent your hood.",
        (g_GangPickupColor[gangIndex] >>> 8),
        g_GangPickupName[gangIndex],
        g_GangPickupTag[gangIndex]
    );

    SendClientMessage(playerid, -1, response);
    return 1;
}

command(leavegang, playerid, params[])
{
    #pragma unused params
    
    if (g_PlayerGang[playerid] == GANG_NONE)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You are not currently part of any gang.");
        return 1;
    }

    if (gettime() < g_PlayerGangCooldown[playerid])
    {
        new secondsLeft = g_PlayerGangCooldown[playerid] - gettime();

        new cooldownMsg[128];
        format(cooldownMsg, sizeof cooldownMsg,
            "{ff6347}[ ! ]: {FFFFFF}You must wait %d seconds before leaving your gang.",
            secondsLeft
        );

        SendClientMessage(playerid, -1, cooldownMsg);
        return 1;
    }

    new oldGang = g_PlayerGang[playerid];

    g_PlayerGang[playerid] = GANG_NONE;
    g_PlayerGangCooldown[playerid] = gettime() + GANG_CHANGE_COOLDOWN;

    new response[160];
    format(response, sizeof response,
        "{FFFFFF}[ HOMIE ]: You left {%06x}%s %s{FFFFFF}. You're back on your own.",
        (g_GangPickupColor[oldGang] >>> 8),
        g_GangPickupName[oldGang],
        g_GangPickupTag[oldGang]
    );

    SendClientMessage(playerid, -1, response);
    return 1;
}

command(joinlspd, playerid, params[])
{
    #pragma unused params

    new gangIndex = g_GangPickupPending[playerid];
    if (gangIndex != GANG_LSPD)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You must be at the LSPD spawn to use /joinlspd.");
        return 1;
    }

    ShowLSPDRecruitmentDialog(playerid);
    return 1;
}
