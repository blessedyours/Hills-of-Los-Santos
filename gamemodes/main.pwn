//-----------------------------------------------------------------------------
// Predefinitions
//-----------------------------------------------------------------------------

// Redefine `MAX_PLAYERS` to match our player slot.  This value must align with
// the `max_players` setting in the `config.json` file to prevent any issues.
#define MAX_PLAYERS (200)

// Allows both American and British English spellings.  It is required to
// preserve compatibility with how it was in SA:MP.
#define MIXED_SPELLINGS

//-----------------------------------------------------------------------------
// Script Dependencies
//-----------------------------------------------------------------------------

// Core
#include <open.mp>

// Plugins
#include <a_mysql>
#include <samp_bcrypt>
#include <crashdetect>
#include <streamer>
#include <PawnPlus>
#include <eSelection>
#include <Pawn.Regex>
#include <sscanf2>
#include <zcmd>
#include <Pawn.RakNet>
#include <strlib>

// YSI
#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------
// Script Modules
//-----------------------------------------------------------------------------

// Utilities
#include "modules/utils/colors.pwn"
#include "modules/utils/dialogs.pwn"

// Server
#include "modules/core/server/database.pwn"

// Player Account
#include "modules/core/player/account/utils.pwn"
#include "modules/core/player/account/core.pwn"

// Player Modules
#include "modules/player/nametag.pwn"
#include "modules/gangs/header.pwn"
#include "modules/visuals/header.pwn"

// -----------------------------------------------------------------------------

main()
{
    Models_AddSkins();
}