//-----------------------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------------------

#define ACCOUNT_MIN_PASSWORD_LENGTH (6)
#define INVALID_ACCOUNT_ID          (0)

//-----------------------------------------------------------------------------
// Player account data variables
//-----------------------------------------------------------------------------

static
        s_PlayerAccountID[MAX_PLAYERS]                = { INVALID_ACCOUNT_ID, ... },
        bool:s_IsPlayerLoggedIn[MAX_PLAYERS]          = { false,              ... },
        s_PlayerCharacterName[MAX_PLAYERS][31]        = { "",                 ... },
        s_PlayerAccountName[MAX_PLAYERS][24],
        bool:s_CharacterNameWarningShown[MAX_PLAYERS] = { false,              ... };

//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

Account_Check(playerid)
{
    new query[256];
    new accountname[24];

    GetPlayerAccountName(playerid, accountname);

    mysql_format(
        g_DatabaseHandle,
        query,
        sizeof(query),
        "SELECT `account_id`, `character_name`, `password_hash`, `pos_x`, `pos_y`, `pos_z`, `pos_angle` \
        FROM `player_accounts` \
        WHERE `username` = '%e' \
        LIMIT 1;",
        accountname
    );

    mysql_tquery(
        g_DatabaseHandle,
        query,
        "OnPlayerAccountCheck",
        "d",
        playerid
    );

    return 1;
}

Account_ShowRegistrationDialog(playerid, bool:badpass = false)
{
    new dialogText[512];

    format(dialogText, sizeof(dialogText), "{FFFFFF}Welcome to {36906b}Hills of Los Santos{FFFFFF}.\n\n{FFFFFF}This account has not been registered yet.\nTo continue, you must create a password that will be used to protect your account and save your progress on the server.\nFor security reasons, your password must contain at least %d characters.\nYou have a maximum of {D68924}3 registration attempts {FFFFFF}and {D68924}3 minutes {FFFFFF}to complete this form.\nPlease enter a password below to complete your registration:", ACCOUNT_MIN_PASSWORD_LENGTH);

    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTRATION,
        DIALOG_STYLE_PASSWORD,
        "> Hills of Los Santos",
        dialogText,
        "Register",
        "Back"
    );

    if (badpass)
    {
        SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}Password requirements not met. The password you entered is too short. Please choose a longer password and try again.");
    }

    return 1;
}

Account_ShowLoginDialog(playerid)
{
    new dialogText[512];
    new charname[31];
    GetPlayerCharacterName(playerid, charname, sizeof(charname));

    format(
        dialogText,
        sizeof(dialogText),
        "{FFFFFF}Welcome back to {36906b}Hills of Los Santos{FFFFFF}, {FFFF00}%s{FFFFFF}.\n\nAn account associated with this character has been found.\nTo continue, please enter your password to access your account and restore your saved progress.\nFor security reasons, you have a maximum of {D68924}3 login attempts{FFFFFF}.\nExceeding this limit will result in your session being terminated.\nPlease enter your password below to continue:",
        charname
    );

    ShowPlayerDialog(
        playerid,
        DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "> Hills of Los Santos",
        dialogText,
        "Login",
        "Back"
    );

    return 1;
}

bool:IsValidPassword(const password[])
{
    if (strlen(password) < ACCOUNT_MIN_PASSWORD_LENGTH)
    {
        return false;
    }

    return true;
}

HashPassword(playerid, const password[])
{
    bcrypt_hash(playerid, "OnPasswordHash", password, BCRYPT_COST);
}

Account_Create(playerid, const hash[])
{
    new query[256];
    new charname[31];
    new accountname[24];

    GetPlayerCharacterName(playerid, charname, sizeof(charname));
    GetPlayerAccountName(playerid, accountname, sizeof(accountname));

    mysql_format(
        g_DatabaseHandle,
        query,
        sizeof(query),
        "INSERT INTO `player_accounts` (`username`, `character_name`, `password_hash`) VALUES ('%e', '%e', '%e');",
        accountname,
        charname,
        hash
    );

    mysql_tquery(
        g_DatabaseHandle,
        query,
        "OnPlayerRegister",
        "d",
        playerid
    );

    return 1;
}

SetPlayerAccountID(playerid, accountid)
{
    s_PlayerAccountID[playerid] = accountid;
    return 1;
}

stock GetPlayerAccountID(playerid)
{
    return IsPlayerConnected(playerid)
    ? s_PlayerAccountID[playerid]
    : INVALID_ACCOUNT_ID;
}

SetPlayerLoggedIn(playerid, bool:set)
{
    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    s_IsPlayerLoggedIn[playerid] = set;

    return 1;
}

stock bool:IsPlayerLoggedIn(playerid)
{
    return IsPlayerConnected(playerid) ? s_IsPlayerLoggedIn[playerid] : false;
}

Account_ShowCharacterNameDialog(playerid)
{
    new dialogText[512];

    // ✓ Solo mostrar el mensaje si no se ha mostrado aún
    if (!s_CharacterNameWarningShown[playerid])
    {
        SendClientMessage(playerid, -1, "{FFCC00} [ ! ]: Avoid using troll names or celebrity names, or you could be banned by an administrator.");
        s_CharacterNameWarningShown[playerid] = true;
    }

    format(dialogText, sizeof(dialogText), "{FFFFFF}Welcome to {36906b}Hills of Los Santos{FFFFFF}.\n\nBefore entering the server for the first time, you must create a {FFFF00}FirstName_LastName{FFFFFF} to identify the character you will play.\n\nExample: {D68924}Jeffery_Lamar{FFFFFF}\nYour character name must contain between {D68924}3 and 30 characters{FFFFFF}.\nOnly letters and the underscore ({D68924}_{FFFFFF}) are allowed.\nNumbers, spaces and other symbols are not permitted.\n\n{FFD700}Enter your character name:");

    ShowPlayerDialog(
        playerid,
        DIALOG_CHARACTER_NAME,
        DIALOG_STYLE_INPUT,
        "> Hills of Los Santos",
        dialogText,
        "Create",
        "Back"
    );

    return 1;
}

bool:IsValidCharacterName(const charname[])
{
    new len = strlen(charname);
    new underscorePos = -1;

    if (len < 7 || len > 30)
    {
        return false;
    }

    for (new i = 0; i < len; i++)
    {
        if (charname[i] == '_')
        {
            if (underscorePos != -1)
            {
                return false;
            }
            underscorePos = i;
        }
    }

    if (underscorePos == -1)
    {
        return false;
    }

    if (underscorePos < 3)
    {
        return false;
    }

    if ((len - underscorePos - 1) < 3)
    {
        return false;
    }

    for (new i = 0; i < len; i++)
    {
        if (i == underscorePos)
        {
            continue;
        }

        if (!((charname[i] >= 'A' && charname[i] <= 'Z') ||
              (charname[i] >= 'a' && charname[i] <= 'z')))
        {
            return false;
        }
    }

    return true;
}

stock Account_UpdateCharacterName(playerid, const charname[])
{
    new query[256];

    mysql_format(g_DatabaseHandle, query, sizeof(query),
        "UPDATE `player_accounts` SET `character_name` = '%e' WHERE `account_id` = %d;",
        charname, GetPlayerAccountID(playerid)
    );
    mysql_tquery(g_DatabaseHandle, query, "OnCharacterNameUpdated", "d", playerid);

    return 1;
}

stock Account_LoadCharacterName(playerid)
{
    new query[128];

    mysql_format(g_DatabaseHandle, query, sizeof(query),
        "SELECT `character_name` FROM `player_accounts` WHERE `account_id` = %d LIMIT 1;",
        GetPlayerAccountID(playerid)
    );
    mysql_tquery(g_DatabaseHandle, query, "OnCharacterNameLoaded", "d", playerid);

    return 1;
}

SetPlayerCharacterName(playerid, const charname[])
{
    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    strcpy(s_PlayerCharacterName[playerid], charname, 31);

    return 1;
}

stock GetPlayerCharacterName(playerid, charname[], len = 31)
{
    if (!IsPlayerConnected(playerid))
        return 0;

    format(charname, len, "%s", s_PlayerCharacterName[playerid]);
    return 1;
}

stock SetPlayerAccountName(playerid, const account[])
{
    if(!IsPlayerConnected(playerid))
        return 0;

    strcpy(s_PlayerAccountName[playerid], account, 24);
    return 1;
}

stock GetPlayerAccountName(playerid, account[], len = 24)
{
    if (!IsPlayerConnected(playerid))
        return 0;

    format(account, len, "%s", s_PlayerAccountName[playerid]);
    return 1;
}