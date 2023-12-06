
//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_DM" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "dm" );

	[[ level.gtd_call ]]( "registerSpawn", "mp_deathmatch_spawn", "dm" );

	level.QuickMessageToAll = true;
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
gtRegister( register, post )
{
	// Since CoDaM treats the first registration of a callback as the
	// ... "default" call, must ensure that gametype-specific functions
	// ... are registered first during Init.

	if ( isdefined( post ) )
		return;

	// Script-level	callbacks
	[[ register ]](	   "StartGameType", ::StartGameType );
	[[ register ]](	   "PlayerConnect", codam\callbacks::PlayerConnect );
	[[ register ]](	"PlayerDisconnect", codam\callbacks::PlayerDisconnect );
	[[ register ]](	    "PlayerDamage", codam\callbacks::PlayerDamage );
	[[ register ]](	    "PlayerKilled", codam\callbacks::PlayerKilled );

	// Game-type callbacks
	[[ register ]](   "finishPlayerKilled",
				codam\callbacks::finishPlayerKilled );
	[[ register ]](	        "gt_startGame",
				codam\GameTypes\_tdm::startGame );
	[[ register ]](	      "gt_checkUpdate",
				codam\GameTypes\_tdm::checkUpdate );
	[[ register ]](            "gt_endMap",
				codam\GameTypes\_tdm::endMap );
	[[ register ]](          "gt_endRound",
				codam\GameTypes\_tdm::endRound );
	[[ register ]](       "gt_spawnPlayer",
				codam\GameTypes\_tdm::spawnPlayer );
	[[ register ]](    "gt_spawnSpectator",
				codam\GameTypes\_tdm::spawnSpectator );
	[[ register ]]( "gt_spawnIntermission",
				codam\GameTypes\_tdm::spawnIntermission );
	[[ register ]](		  "gt_respawn",
				codam\GameTypes\_tdm::respawn );
	[[ register ]](       "gt_menuHandler",
				codam\GameTypes\_tdm::menuHandler );
	[[ register ]](  "gt_timeLimitReached",
				codam\GameTypes\_tdm::timeLimitReached );
	[[ register ]]( "gt_scoreLimitReached",
				codam\GameTypes\_tdm::scoreLimitReached );
	[[ register ]](  "gt_playerScoreLimit",
				codam\GameTypes\_tdm::playerScoreLimit );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
StartGameType( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9 )
{
	// Call	the CoDaM initialization function without any args to
	// continue with framework/custom mods initialization.
	codam\init::main();

	if( !isdefined( game[ "gamestarted" ] ) )
	{
		if ( level.ham_shortversion != "1.1" )
		{
			makeCvarServerInfo( "ui_dm_timelimit", "30" );
			makeCvarServerInfo( "ui_dm_scorelimit", "50" );

			game[ "menu_serverinfo" ] = "serverinfo_" +
							level.ham_g_gametype;
			precacheMenu( game[ "menu_serverinfo" ] );
		}
	}

	// Last call to CoDaM init to cause any last-minutes framework to
	// start.
	codam\init::main();

	game[ "gamestarted" ] =	true;
	[[ level.gtd_call ]]( "setClientNameMode", "auto_change" );
	thread [[ level.gtd_call ]]( "gt_startGame" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
