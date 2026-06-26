forward ShowLSPDRecruitmentDialog(playerid);

command(joingang, playerid, params[])
{
    new arg[64];
    if (sscanf(params, "s", arg, sizeof arg) < 0)
    {
        arg[0] = '\0';
    }

    new gangIndex = g_GangPickupPending[playerid];
    if (gangIndex < 0)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You must be at a gang spawn to use this command.");
        return 1;
    }

    if (gangIndex == 9)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}Use /joinlspd to see the LSPD recruitment dialog.");
        return 1;
    }

    g_GangPickupPending[playerid] = -1;
    g_PlayerGang[playerid] = gangIndex;

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

command(joinlspd, playerid, params[])
{
    new arg[64];
    if (sscanf(params, "s", arg, sizeof arg) < 0)
    {
        arg[0] = '\0';
    }

    new gangIndex = g_GangPickupPending[playerid];
    if (gangIndex != 9)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}You must be at the LSPD spawn to use /joinlspd.");
        return 1;
    }

    ShowLSPDRecruitmentDialog(playerid);
    return 1;
}
