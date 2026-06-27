#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------
// Forwards
//-----------------------------------------------------------------------------

forward public OnPlayerAccountCheck(playerid);
forward public OnPasswordHash(playerid);
forward public OnPlayerRegister(playerid);
forward public OnPasswordCheck(playerid, bool:match);
forward public OnPlayerLogin(playerid);
forward public OnCharacterNameLoaded(playerid);
forward public OnCharacterNameUpdated(playerid);
forward public OnCharacterNameCheck(playerid);
forward public ForcePlayerSpawn(playerid);
forward public ApplyLoadedPosition(playerid);
forward public ResetPlayerCamera(playerid);  // ✓ AGREGAR ESTA LÍNEA

//-----------------------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------------------

#define MAX_LOGIN_ATTEMPTS (3)
#define MAIN_MENU_TEXT     "Login\nCreate Account\nCredits"

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------

static s_PlayerLoginAttempts[MAX_PLAYERS]           = { 0,     ... };
static bool:s_IsFirstLogin[MAX_PLAYERS]             = { false, ... };
static bool:s_CharacterNameSaved[MAX_PLAYERS]       = { false, ... };
static bool:s_IsRegistering[MAX_PLAYERS]            = { false, ... };
static bool:s_InLoginMenu[MAX_PLAYERS]              = { false, ... };
static bool:s_CharacterNameWarningShown[MAX_PLAYERS] = { false, ... };

static const ForbiddenNames[][] =
{
    "Carl_Johnson",
    "Michael_Jackson",
    "Sweet_Johnson",
    "Myke_Tyson",
    "Big_Smoke",
    "Sean_Johnson",
    "Cesar_Vialpando",
    "Jefferey_Cross",
    "Jefferey_Lamar",
    "John_Cena",
    "Madd_Dogg",
    "Mike_Toreno",
    "Eddie_Pulaski",
    "Frank_Tenpenny",
    "Administrador_Servidor",
    "Server_Admin",
    "Console_Admin",
    "Nombre_Apellido"
};

static ApplyPlayerName(playerid, const charname[])
{
    SetPlayerName(playerid, charname);
    return 1;
}

static SetLoginCamera(playerid)
{
    SetPlayerCameraPos(playerid, 1533.2587, -1763.7717, 73.6204);
    SetPlayerCameraLookAt(playerid, 1532.9288, -1762.8286, 73.0504);
    return 1;
}

//-----------------------------------------------------------------------------
// Hooks principales
//-----------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    SetLoginCamera(playerid);
    s_InLoginMenu[playerid] = true;
    return 1;
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if (IsPlayerLoggedIn(playerid))
    {
        Nametag_OnDamage(playerid);
    }
    return 1;
}

hook OnPlayerRequestSpawn(playerid)
{
    if (!IsPlayerLoggedIn(playerid))
        return 0;

    SetPlayerPos(playerid, 1479.4623, -1677.1764, 14.0469);
    SetPlayerFacingAngle(playerid, 0.0);
    s_InLoginMenu[playerid] = false;
    return 1;
}

hook OnPlayerFinishedDownloading(playerid, virtualworld)
{
    if (IsPlayerLoggedIn(playerid))
        return 1;

    // Restaurar camera del login
    SetLoginCamera(playerid);
    s_InLoginMenu[playerid] = true;

    ShowPlayerDialog(
        playerid,
        DIALOG_MAIN_ACCOUNT,
        DIALOG_STYLE_LIST,
        "> Hills of Los Santos",
        MAIN_MENU_TEXT,
        "Select",
        ""
    );

    return 1;
}


hook OnGameModeInit()
{
    AddPlayerClass(
        0,
        1479.4623, -1677.1764, 14.0469,
        269.1526,
        WEAPON:0, 0,
        WEAPON:0, 0,
        WEAPON:0, 0
    );

    ShowNameTags(false);

    return 1;
}

hook OnPlayerSpawn(playerid)
{
    if (IsPlayerLoggedIn(playerid))
    {
        s_InLoginMenu[playerid] = false;
        TogglePlayerControllable(playerid, true);
        SetCameraBehindPlayer(playerid);
        Nametag_Update(playerid);
    }
    return 1;
}

// Mantener la cámara fija durante el login
hook OnPlayerUpdate(playerid)
{
    if (s_InLoginMenu[playerid])
    {
        SetLoginCamera(playerid);
        TogglePlayerControllable(playerid, false);
    }
    return 1;
}

//-----------------------------------------------------------------------------
// Account check callback
//-----------------------------------------------------------------------------

hook OnPlayerAccountCheck(playerid)
{
    new bool:accountExists = (cache_num_rows() > 0);

    if (s_IsRegistering[playerid])
    {
        if (accountExists)
        {
            SendClientMessage(playerid, -1,
                "{FF6347}[ ! ]: {FFFFFF}That account name or character name is already taken. Please choose another one.");

            ShowPlayerDialog(
                playerid,
                DIALOG_ACCOUNT_NAME,
                DIALOG_STYLE_INPUT,
                "> Hills of Los Santos",
                "{FFFFFF}Enter the account name you wish to create:",
                "Continue",
                "Back"
            );
            return 1;
        }

        Account_ShowCharacterNameDialog(playerid);
        return 1;
    }

    if (!accountExists)
    {
        SendClientMessage(playerid, -1,
            "{FF6347}[ ! ]: {FFFFFF}The account does not exist. Please register to create a new account.");

        ShowPlayerDialog(
            playerid,
            DIALOG_MAIN_ACCOUNT,
            DIALOG_STYLE_LIST,
            "> Hills of Los Santos",
            MAIN_MENU_TEXT,
            "Select",
            ""
        );
        return 1;
    }

    new tempPassword[BCRYPT_HASH_LENGTH];
    cache_get_value_name(0, "password_hash", tempPassword);
    SetPVarString(playerid, "tempPassword", tempPassword);

    new accountID;
    cache_get_value_name_int(0, "account_id", accountID);
    SetPlayerAccountID(playerid, accountID);

    new Float:posX, Float:posY, Float:posZ, Float:posAngle;

    cache_get_value_name_float(0, "pos_x", posX);
    cache_get_value_name_float(0, "pos_y", posY);
    cache_get_value_name_float(0, "pos_z", posZ);
    cache_get_value_name_float(0, "pos_angle", posAngle);

    SetPVarFloat(playerid, "LoadPosX", posX);
    SetPVarFloat(playerid, "LoadPosY", posY);
    SetPVarFloat(playerid, "LoadPosZ", posZ);
    SetPVarFloat(playerid, "LoadPosAngle", posAngle);

    new charname[31];
    cache_get_value_name(0, "character_name", charname);
    SetPVarString(playerid, "cachedCharName", charname);

    Account_ShowLoginDialog(playerid);
    return 1;
}

//-----------------------------------------------------------------------------
// Character name check callback
//-----------------------------------------------------------------------------

hook OnCharacterNameCheck(playerid)
{
    new charname[31];
    GetPVarString(playerid, "tempCharName", charname, sizeof(charname));
    DeletePVar(playerid, "tempCharName");

    if (cache_num_rows() > 0)
    {
        SendClientMessage(playerid, -1,
            "{FF6347}[ ! ]: {FFFFFF}That character name is already taken in the database. Please choose another.");

        Account_ShowCharacterNameDialog(playerid);
        return 1;
    }

    SetPlayerCharacterName(playerid, charname);
    Account_ShowRegistrationDialog(playerid);
    
    return 1;
}

//-----------------------------------------------------------------------------
// Dialog responses
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Dialog responses
//-----------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_MAIN_ACCOUNT:
        {
            if (!response)
                return Kick(playerid);

            switch (listitem)
            {
                case 0: // Login
                {
                    s_IsRegistering[playerid] = false;

                    ShowPlayerDialog(
                        playerid,
                        DIALOG_ACCOUNT_NAME,
                        DIALOG_STYLE_INPUT,
                        "> Hills of Los Santos",
                        "{FFFFFF}Enter your account name:",
                        "Next",
                        "Back"
                    );
                    return 1;
                }

                case 1: // Register
                {
                    s_IsRegistering[playerid] = true;

                    ShowPlayerDialog(
                        playerid,
                        DIALOG_ACCOUNT_NAME,
                        DIALOG_STYLE_INPUT,
                        "> Hills of Los Santos",
                        "{FFFFFF}Enter the account name you wish to create:",
                        "Continue",
                        "Back"
                    );
                    return 1;
                }

                case 2: // Credits
                {
                    ShowPlayerDialog(
                        playerid,
                        DIALOG_CREDITS,
                        DIALOG_STYLE_MSGBOX,
                        "> Hills of Los Santos",
                        "{FFFFFF}Hills of Los Santos\n\n{FF6347}Version v0.1b\n{FFFFFF}Developed by: ZipLoc and Peluchon\n\n{FF6347}Special thanks to: Open.mp, YSI, and the SA:MP community.",
                        "Back",
                        ""
                    );
                    return 1;
                }
            }
            return 1;
        }

        case DIALOG_CREDITS:
        {
            ShowPlayerDialog(
                playerid,
                DIALOG_MAIN_ACCOUNT,
                DIALOG_STYLE_LIST,
                "> Hills of Los Santos",
                MAIN_MENU_TEXT,
                "Select",
                ""
            );
            return 1;
        }

        case DIALOG_ACCOUNT_NAME:
        {
            if (!response)
            {
                ShowPlayerDialog(
                    playerid,
                    DIALOG_MAIN_ACCOUNT,
                    DIALOG_STYLE_LIST,
                    "> Hills of Los Santos",
                    MAIN_MENU_TEXT,
                    "Select",
                    ""
                );
                return 1;
            }

            new len = strlen(inputtext);

            if (len < 4 || len > 23)
            {
                SendClientMessage(playerid, -1,
                    "{FF6347}[ ! ]: {FFFFFF}Account name must be between 4 and 23 characters.");

                if (s_IsRegistering[playerid])
                {
                    ShowPlayerDialog(
                        playerid,
                        DIALOG_ACCOUNT_NAME,
                        DIALOG_STYLE_INPUT,
                        "> Hills of Los Santos",
                        "{FFFFFF}Enter the account name you wish to create:",
                        "Continue",
                        "Back"
                    );
                }
                else
                {
                    ShowPlayerDialog(
                        playerid,
                        DIALOG_ACCOUNT_NAME,
                        DIALOG_STYLE_INPUT,
                        "> Hills of Los Santos",
                        "{FFFFFF}Enter your account name:",
                        "Next",
                        "Back"
                    );
                }
                return 1;
            }

            SetPlayerAccountName(playerid, inputtext);
            Account_Check(playerid);
            return 1;
        }

        case DIALOG_REGISTRATION:
        {
            if (!response)
            {
                s_CharacterNameWarningShown[playerid] = false;
                Account_ShowCharacterNameDialog(playerid);
                return 1;
            }

            if (!IsValidPassword(inputtext))
            {
                Account_ShowRegistrationDialog(playerid, true);
                return 1;
            }
            else
            {
                HashPassword(playerid, inputtext);
                return 1;
            }
        }

        case DIALOG_CHARACTER_NAME:
        {
            if (!response)
            {
                s_IsRegistering[playerid] = false;
                s_CharacterNameWarningShown[playerid] = false;
                
                ShowPlayerDialog(
                    playerid,
                    DIALOG_MAIN_ACCOUNT,
                    DIALOG_STYLE_LIST,
                    "> Hills of Los Santos",
                    MAIN_MENU_TEXT,
                    "Select",
                    ""
                );
                return 1;
            }

            if (!IsValidCharacterName(inputtext))
            {
                SendClientMessage(playerid, -1,
                    "{FF6347}[ ! ]: {FFFFFF}Invalid format. Use First_Last_Name.");

                Account_ShowCharacterNameDialog(playerid);
                return 1;
            }

            for (new i = 0; i < sizeof(ForbiddenNames); i++)
            {
                if (strcmp(inputtext, ForbiddenNames[i], true) == 0)
                {
                    SendClientMessage(playerid, -1,
                        "{FF6347}[ ! ]: {FFFFFF}That character name is not allowed.");

                    Account_ShowCharacterNameDialog(playerid);
                    return 1;
                }
            }

            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (i == playerid || !IsPlayerConnected(i))
                    continue;

                new otherCharname[31];
                GetPlayerCharacterName(i, otherCharname, sizeof(otherCharname));

                if (strlen(otherCharname) > 0 && strcmp(inputtext, otherCharname, true) == 0)
                {
                    SendClientMessage(playerid, -1,
                        "{FF6347}[ ! ]: {FFFFFF}That character name is already in use. Please choose another.");

                    Account_ShowCharacterNameDialog(playerid);
                    return 1;
                }
            }

            SetPVarString(playerid, "tempCharName", inputtext);
            
            new query[256];
            mysql_format(
                g_DatabaseHandle,
                query,
                sizeof(query),
                "SELECT `account_id` FROM `player_accounts` WHERE LOWER(`character_name`) = LOWER('%e') LIMIT 1;",
                inputtext
            );
            
            mysql_tquery(
                g_DatabaseHandle,
                query,
                "OnCharacterNameCheck",
                "d",
                playerid
            );
            
            return 1;
        }

        case DIALOG_LOGIN:
        {
            if (!response)
            {
                s_PlayerLoginAttempts[playerid] = 0;
                ShowPlayerDialog(
                    playerid,
                    DIALOG_MAIN_ACCOUNT,
                    DIALOG_STYLE_LIST,
                    "> Hills of Los Santos",
                    MAIN_MENU_TEXT,
                    "Select",
                    ""
                );
                return 1;
            }

            new hash[BCRYPT_HASH_LENGTH];
            GetPVarString(playerid, "tempPassword", hash, sizeof(hash));

            bcrypt_verify(playerid, "OnPasswordCheck", inputtext, hash);
            return 1;
        }
    }

    return 0;
}
//-----------------------------------------------------------------------------
// Password hash callback
//-----------------------------------------------------------------------------

hook OnPasswordHash(playerid)
{
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash);

    Account_Create(playerid, hash);
    return 1;
}

//-----------------------------------------------------------------------------
// Register callback
//-----------------------------------------------------------------------------

hook OnPlayerRegister(playerid)
{
    new const accountID = cache_insert_id();

    SetPlayerAccountID(playerid, accountID);
    SetPlayerLoggedIn(playerid, true);

    s_IsFirstLogin[playerid] = true;
    s_CharacterNameSaved[playerid] = false;

    SendClientMessage(playerid, -1,
        "{36906b}[ ! ]: {FFFFFF}Welcome to Hills of Los Santos! Your account has been created successfully.");
    
    new charname[31];
    GetPlayerCharacterName(playerid, charname, sizeof(charname));
    ApplyPlayerName(playerid, charname);
    
    SetTimerEx("ForcePlayerSpawn", 800, false, "d", playerid);
    
    return 1;
}
//-----------------------------------------------------------------------------
// Force spawn timer
//-----------------------------------------------------------------------------

forward ResetPlayerCamera(playerid);
public ResetPlayerCamera(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        SetCameraBehindPlayer(playerid);
    }
    return 1;
}

public ForcePlayerSpawn(playerid)
{
    if (IsPlayerConnected(playerid) && IsPlayerLoggedIn(playerid))
    {
        s_InLoginMenu[playerid] = false;

        SpawnPlayer(playerid);

        SetTimerEx("ApplyLoadedPosition", 300, false, "d", playerid);
        SetTimerEx("ResetPlayerCamera", 500, false, "d", playerid);
    }
    return 1;
}

public ApplyLoadedPosition(playerid)
{
    if (!IsPlayerConnected(playerid) || !IsPlayerLoggedIn(playerid))
        return 0;

    new Float:x = GetPVarFloat(playerid, "LoadPosX");
    new Float:y = GetPVarFloat(playerid, "LoadPosY");
    new Float:z = GetPVarFloat(playerid, "LoadPosZ");
    new Float:a = GetPVarFloat(playerid, "LoadPosAngle");

    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, a);
    SetCameraBehindPlayer(playerid);

    return 1;
}

//-----------------------------------------------------------------------------
// Password check callback
//-----------------------------------------------------------------------------

hook OnPasswordCheck(playerid, bool:match)
{
    if (match)
    {
        SetPlayerLoggedIn(playerid, true);
        DeletePVar(playerid, "tempPassword");

        s_PlayerLoginAttempts[playerid] = 0;
        s_IsFirstLogin[playerid] = false;
        s_CharacterNameSaved[playerid] = false;

        new charname[31];
        GetPVarString(playerid, "cachedCharName", charname, sizeof(charname));
        DeletePVar(playerid, "cachedCharName");

        SetPlayerCharacterName(playerid, charname);

        SendClientMessage(playerid, -1,
            "{36906b}[ ! ]: {FFFFFF}Welcome back to Hills of Los Santos!");

        ApplyPlayerName(playerid, charname);
        
        // ✓ Mostrar nametag inmediatamente
        Nametag_Show(playerid);
        
        s_InLoginMenu[playerid] = false;
        
        SetTimerEx("ForcePlayerSpawn", 100, false, "d", playerid);
    }
    else
    {
        s_PlayerLoginAttempts[playerid]++;

        if (s_PlayerLoginAttempts[playerid] >= MAX_LOGIN_ATTEMPTS)
        {
            SendClientMessage(playerid, -1,
                "{ff6347}[ ! ]: {FFFFFF}You have been disconnected for security reasons after exceeding the maximum number of login attempts.");
            Kick(playerid);
        }
        else
        {
            Account_ShowLoginDialog(playerid);

            new attemptsLeft = MAX_LOGIN_ATTEMPTS - s_PlayerLoginAttempts[playerid];
            new msg[128];
            format(msg, sizeof(msg),
                "{ff6347}[ ! ]: {FFFFFF}You have %d %s remaining before your session is terminated.",
                attemptsLeft,
                attemptsLeft == 1 ? "attempt" : "attempts"
            );
            SendClientMessage(playerid, -1, msg);
        }
    }

    return 1;
}

//-----------------------------------------------------------------------------
// Disconnect
//-----------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    if (IsPlayerLoggedIn(playerid))
    {
        new accountID = GetPlayerAccountID(playerid);

        if (accountID > 0)
        {
            new Float:x, Float:y, Float:z, Float:a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);

            new query[256];
            mysql_format(
                g_DatabaseHandle,
                query,
                sizeof(query),
                "UPDATE `player_accounts` SET `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `pos_angle` = %f WHERE `account_id` = %d LIMIT 1;",
                x, y, z, a, accountID
            );

            mysql_tquery(g_DatabaseHandle, query);
        }
    }

    Nametag_Hide(playerid);

    SetPlayerLoggedIn(playerid, false);
    SetPlayerCharacterName(playerid, "");

    s_IsFirstLogin[playerid] = false;
    s_CharacterNameSaved[playerid] = false;
    s_IsRegistering[playerid] = false;
    s_PlayerLoginAttempts[playerid] = 0;
    s_InLoginMenu[playerid] = false;
    s_CharacterNameWarningShown[playerid] = false;

    DeletePVar(playerid, "tempPassword");
    DeletePVar(playerid, "tempCharName");
    DeletePVar(playerid, "cachedCharName");

    return 1;
}

public OnCharacterNameLoaded(playerid)
{
    return 1;
}

public OnCharacterNameUpdated(playerid)
{
    s_CharacterNameSaved[playerid] = true;
    return 1;
}