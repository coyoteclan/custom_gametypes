
//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_SD" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "sd", "bombzone;blocker" );

	level._effect[ "bombexplosion" ] =
					loadfx( "fx/explosions/mp_bomb.efx" );

	if ( !isdefined( game[ "attackers" ] ) )
		game[ "attackers" ] = "allies";
	if ( !isdefined( game[ "defenders" ] ) )
		game[ "defenders" ] = "axis";

	level.roundbased = true;		// This is a round-based GT
	level.bombplanted = false;
	level.bombexploded = false;
	level.roundstarted = false;
	level.roundended = false;

	if ( codam\utils::getVar( "scr", "switchroles", "bool", 1|2, false ) )
	{
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_searchanddestroy_spawn_allied", "random", "axis" );
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_searchanddestroy_spawn_axis", "random", "allies" );
	}
	else
	{
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_searchanddestroy_spawn_allied", "random", "allies" );
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_searchanddestroy_spawn_axis", "random", "axis" );
	}

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
	[[ register ]](	        "gt_startGame", ::startGame );
	[[ register ]](	      "gt_autoBalance", ::autoBalance );
	[[ register ]](	      "gt_checkUpdate", ::checkUpdate );
	[[ register ]](	       "gt_startRound", ::startRound );
	[[ register ]](	        "gt_objective", ::bombzones );
	[[ register ]](            "gt_endMap", ::endMap );
	[[ register ]](          "gt_endRound", ::endRound );
	[[ register ]](          "gt_respawn",
				codam\GameTypes\_tdm::respawn );
	[[ register ]](       "gt_spawnPlayer",
				codam\GameTypes\_tdm::spawnPlayer );
	[[ register ]](    "gt_spawnSpectator",
				codam\GameTypes\_tdm::spawnSpectator );
	[[ register ]]( "gt_spawnIntermission",
				codam\GameTypes\_tdm::spawnIntermission );
	[[ register ]](       "gt_menuHandler", ::menuHandler );
	[[ register ]](  "gt_timeLimitReached", ::timeLimitReached );
	[[ register ]]( "gt_scoreLimitReached", ::scoreLimitReached );
	[[ register ]]( "gt_roundLimitReached", ::roundLimitReached );
	[[ register ]](   "gt_checkMatchStart", ::checkMatchStart );
	[[ register ]](  "gt_updateTeamStatus", ::updateTeamStatus );
	[[ register ]](          "gt_roundCam", ::roundCam );
	[[ register ]](       "gt_saveWeapons", ::saveWeapons );
	[[ register ]](      "gt_roundStarted", ::roundStarted );

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

	// If this is a	fresh map start	...
	if( !isdefined( game[ "gamestarted" ] ) )
	{
		if ( level.ham_shortversion != "1.1" )
		{
			makeCvarServerInfo( "ui_sd_timelimit", "0" );
			makeCvarServerInfo( "ui_sd_scorelimit", "10" );
			makeCvarServerInfo( "ui_sd_roundlimit", "0" );

			game[ "menu_serverinfo" ] = "serverinfo_" +
							level.ham_g_gametype;
			precacheMenu( game[ "menu_serverinfo" ] );
		}

		precacheString(	&"SD_MATCHSTARTING" );
		precacheString(	&"SD_MATCHRESUMING" );
		precacheString(	&"SD_EXPLOSIVESPLANTED"	);
		precacheString(	&"SD_EXPLOSIVESDEFUSED"	);
		precacheString(	&"SD_ROUNDDRAW"	);
		precacheString(	&"SD_TIMEHASEXPIRED" );
		precacheString(	&"SD_ALLIEDMISSIONACCOMPLISHED"	);
		precacheString(	&"SD_AXISMISSIONACCOMPLISHED" );
		precacheString(	&"SD_ALLIESHAVEBEENELIMINATED" );
		precacheString(	&"SD_AXISHAVEBEENELIMINATED" );

		precacheShader(	"ui_mp/assets/hud@plantbomb.tga" );
		precacheShader(	"ui_mp/assets/hud@defusebomb.tga" );
		precacheShader(	"gfx/hud/hud@objectiveA.tga" );
		precacheShader(	"gfx/hud/hud@objectiveA_up.tga"	);
		precacheShader(	"gfx/hud/hud@objectiveA_down.tga" );
		precacheShader(	"gfx/hud/hud@objectiveB.tga" );
		precacheShader(	"gfx/hud/hud@objectiveB_up.tga"	);
		precacheShader(	"gfx/hud/hud@objectiveB_down.tga" );
		precacheShader(	"gfx/hud/hud@bombplanted.tga" );
		precacheShader(	"gfx/hud/hud@bombplanted_up.tga" );
		precacheShader(	"gfx/hud/hud@bombplanted_down.tga" );
		precacheShader(	"gfx/hud/hud@bombplanted_down.tga" );
		precacheModel( "xmodel/mp_bomb1_defuse"	);
		precacheModel( "xmodel/mp_bomb1" );

		precacheShader("hudStopwatch");
		precacheShader("hudStopwatchNeedle");

		[[ level.gtd_call ]]( "scoreboard" );
	}

	// Should team roles be switched?
	if ( codam\utils::getVar( "scr", "switchroles", "bool", 1|2, false ) )
	{
		_x = game[ "attackers" ];
		game[ "attackers" ] = game[ "defenders" ];
		game[ "defenders" ] = _x;
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
menuHandler( menu, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	self endon( "end_player" );

	for (;;)
	{
		resp = self [[ level.gtd_call ]]( "menuHandler", menu );
		if ( !isdefined( resp ) || ( resp.size < 2 ) ||
		     !isdefined( resp[ 0 ] ) || !isdefined( resp[ 1 ] ) )
		{
			// Shouldn't happen ... but just in case
			wait( 1 );
			continue;
		}

		val = resp[ 1 ];
		switch ( resp[ 0 ] )
		{
		  case "team":
		  	switch ( val )
		  	{
		  	  case "spectator":
				if ( self.pers[ "team" ] != "spectator" )
					self [[ level.gtd_call ]](
								"goSpectate" );

				menu = undefined;
				break;
		  	  default:
		  	  	if ( ( val == "" ) ||
		  	  	     ![[ level.gtd_call ]]( "isTeam", val ) )
				{
					// Team not playing, try again!
					break;
				}

				if ( isdefined( self.pers[ "team" ] ) &&
				     ( val == self.pers[ "team" ] ) )
				{
					// Same team selected!
					menu = undefined;
					break;
				}

				// Still alive ... changing teams?
				if ( self.sessionstate == "playing" )
					self [[ level.gtd_call ]]( "suicide" );

				// Okay, selected new team ...
				self notify( "end_respawn" );

				// Okay, selected new team ...
				self.pers[ "team" ] = val;
				self.pers[ "weapon" ] = undefined;
				self.pers[ "weapon1" ] = undefined;
				self.pers[ "weapon2" ] = undefined;
				self.pers[ "savedmodel" ] = undefined;
				self.pers[ "spawnweapon" ] = undefined;

				menu = game[ "menu_weapon_" + val ];
				self setClientCvar( "g_scriptMainMenu", menu );
				self setClientCvar( level.ui_weapontab, "1" );

				break;
		  	}

		  	break;
		  case "weapon":
		  	_team = self.pers[ "team" ];
			if ( ![[ level.gtd_call ]]( "isTeam", _team ) )
			{
				// No team selected yet?
				menu = game[ "menu_team" ];
				break;
			}

			if ( !self [[ level.gtd_call ]]( "isWeaponAllowed",
									val ) )
			{
				self iprintln(
					"^3*** Weapon has been disabled." );
				break;
			}

			weapon = val;

			_savemenu = menu;
			menu = undefined;
			if ( isdefined( self.pers[ "weapon" ] ) &&
			     ( self.pers[ "weapon" ] == weapon ) &&
			     !isdefined( self.pers[ "weapon1" ] ) )
				break;

			// Is the weapon available?
			weapon = self [[ level.gtd_call ]]( "assignWeapon",
								weapon );
			if ( !isdefined( weapon ) )
			{
				self iprintln( "^3*** Weapon is unavailable." );
				menu = _savemenu;
				break;
			}

			_spawnPlayer = false;
			if ( isdefined( self.teamForced ) &&
			     ( self.teamForced == "playing" ) )
		 	{
		 		// Forced to a team when alive!
		 		self.teamForced = undefined;
				self.spawned = undefined;
				_spawnPlayer = true;
			}

			if ( !game[ "matchstarted" ] )
			{
			 	if ( isdefined( self.pers[ "weapon" ] ) )
			 	{
			 		// Replace existing weapon
					__weap = self [[ level.gtd_call ]](
							"assignWeaponSlot",
							"primary", weapon );
					self switchToWeapon( __weap );

					self [[ level.gtd_call ]](
								"givePistol" );
					self [[ level.gtd_call ]](
								"giveGrenade",
								weapon );
				}
			 	else
			 	{
					self.spawned = undefined;
					_spawnPlayer = true;
				}

				self.pers[ "weapon" ] = weapon;
			}
			else
			if ( !level.roundstarted )
			{
			 	if ( isdefined( self.pers[ "weapon" ] ) )
			 	{
			 		// Replace existing weapon
					__weap = self [[ level.gtd_call ]](
							"assignWeaponSlot",
							"primary", weapon );
					self switchToWeapon( __weap );
				}
			 	else
			 	{
			 		if ( !level.exist[ _team ] )
						self.spawned = undefined;
					_spawnPlayer = true;
				}

		 		self.pers[ "weapon" ] = weapon;
			}
			else
			{
				// Grace-period expired!
				if ( isdefined( self.pers[ "weapon" ] ) )
					self.oldweapon = self.pers[ "weapon" ];

				self.pers[ "weapon" ] = weapon;
				self.sessionteam = _team;

				if ( self.sessionstate != "playing" )
					self.statusicon =
						"gfx/hud/hud@status_dead.tga";

				if ( _team == "allies" )
					_otherteam = "axis";
				else if ( _team == "axis" )
					_otherteam = "allies";

				if ( !level.didexist[ _otherteam ] &&
				     !level.roundended )
				{
					// No opponents
					self.spawned = undefined;
					_spawnPlayer = true;
				}
				else
				if ( !level.didexist[ _team ] &&
				     !level.roundended )
				{
					// First on team
					self.spawned = undefined;
					_spawnPlayer = true;
				}
				else
				{
					self [[ level.gtd_call ]]( "savePlayer" );

					weaponname = maps\mp\gametypes\_teams::getWeaponName( weapon );

					text = undefined;
					if ( _team == "allies" )
					{
						if ( maps\mp\gametypes\_teams::useAn( weapon ) )
							text = &"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND";
						else
							text = &"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND";
					}
					else
					if ( _team == "axis" )
					{
						if ( maps\mp\gametypes\_teams::useAn( weapon ) )
							text = &"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND";
						else
							text = &"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND";
					}

					if ( isdefined( text ) )
						self iprintln( text,
								weaponname );

					if ( self.sessionstate != "playing" )
						self thread [[ level.gtd_call ]](
							"manageSpectate",
							"round" );
				}
			}

			if ( _spawnPlayer )
			{
				self [[ level.gtd_call ]]( "gt_spawnPlayer" );
				self thread [[ level.gtd_call ]](
						"printJoinedTeam", _team );
			}
		  	break;
		  case "menu":
			if ( ( val == "weapon" ) &&
		  	     isdefined( self.pers[ "team" ] ) )
			  	menu = game[ "menu_weapon_" +
			  				self.pers[ "team" ] ];
		  	break;
		  default:
		  	menu = undefined;
		  	break;
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
startGame( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level.starttime = getTime();

	[[ level.gtd_call ]]( "delayMapStart" );

	thread [[ level.gtd_call ]]( "gt_autoBalance" );

	thread [[ level.gtd_call ]]( "gt_endMap" );
 	thread [[ level.gtd_call ]]( "gt_endRound" );
	thread [[ level.gtd_call ]]( "gt_objective" );

	thread [[ level.gtd_call ]]( "gt_checkUpdate", "timelimit" );
	thread [[ level.gtd_call ]]( "gt_checkUpdate", "scorelimit" );
	thread [[ level.gtd_call ]]( "gt_checkUpdate", "roundlimit" );
	thread [[ level.gtd_call ]]( "gt_checkUpdate", "matchstart" );

	thread [[ level.gtd_call ]]( "gt_roundStarted" );
	thread [[ level.gtd_call ]]( "gt_startRound" );

	level notify( "start_map" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
autoBalance( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );
	level endon( "end_round" );

	level waittill( "round_start" );

	if ( !level.allowrespawn )
	{
		if ( level.teambalance > 0 )
			thread codam\commander::procCmds( "eventeams" );
		return;
	}

	for (;;)
	{
		if ( level.teambalance > 0 )
			thread codam\commander::procCmds( "eventeams" );

		wait( 10 );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
roundStarted( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );
	level endon( "end_round" );

	level waittill( "round_start" );

	// Players on a team but without a weapon show as
	// dead since they can not get in this round
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];

		if ( ( player.sessionteam != "spectator" ) &&
		     !isdefined( player.pers[ "weapon" ] ) )
		{
			player.statusicon = "gfx/hud/hud@status_dead.tga";
			player thread [[ level.gtd_call ]]( "manageSpectate",
								"round" );
		}
	}

	// Override spawn points when respawning is enabled
	if ( level.allowrespawn )
	{
		// Provide at least 10 seconds of spawning using
		// ... map's "intended" spawn points before enabling
		// ... respawn-points
		if ( level.graceperiod < 10 )
			wait ( 10 - level.graceperiod );

		switch ( level.respawnpoints )
		{
		  case "dm":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"dm", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"dm", "axis" );
			break;
		  case "dm-random":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"random", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"random", "axis" );
			break;
		  case "dm-nearteam":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"nearteam", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_deathmatch_spawn",
						"nearteam", "axis" );
			break;
		  case "tdm-dm":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"dm", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"dm", "axis" );
			break;
		  case "random":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"random", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"random", "axis" );
			break;
		  case "nearteam":
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"nearteam", "allies" );
			[[ level.gtd_call ]]( "registerSpawn",
						"mp_teamdeathmatch_spawn",
						"nearteam", "axis" );
			break;
		}
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
checkUpdate( var, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level endon( "end_map" );
	level endon( "end_round" );

	for (;;)
	{
		level waittill( "update_" + var );

		switch ( var )
		{
		  case "timelimit":
			game[ "starttime" ] = getTime();
		  	break;
		  case "scorelimit":
		  	[[ level.gtd_call ]]( "checkScoreLimit",
		  				"gt_scoreLimitReached" );
		  	break;
		  case "roundlimit":
		  	[[ level.gtd_call ]]( "checkRoundLimit",
		  				"gt_roundLimitReached" );
		  	break;
		  case "matchstart":
		  	[[ level.gtd_call ]]( "gt_checkMatchStart" );
		  	break;
		  case "teamstatus":
	 	 	[[ level.gtd_call ]]( "gt_updateTeamStatus" );
		  	break;
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
timeLimitReached( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	timepassed = ( getTime() - game[ "starttime" ] ) / 60000.0;

	if ( timepassed < limit )
		return ( false );

	return ( true );
}

scoreLimitReached( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( ( game[ "alliedscore" ] >= limit ) ||
	     ( game[ "axisscore" ] >= limit ) )
		return ( true );

	return ( false );
}

roundLimitReached( limit, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( game[ "roundsplayed" ] >= limit )
		return ( true );

	return ( false );
}

//
///////////////////////////////////////////////////////////////////////////////
startRound( _winner, _text, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )

{
	thread maps\mp\gametypes\_teams::sayMoveIn();

	[[ level.gtd_call ]]( "roundClock" );

	if ( level.roundended )
		return;

	switch ( level.ham_g_gametype )
	{
	  case "re":
		if ( !level.exist[ game[ "re_attackers" ] ] ||
		     !level.exist[ game[ "re_defenders" ] ] )
			_winner = "draw";
		else
			_winner = game[ "re_defenders" ];

		_text = &"RE_TIMEEXPIRED";
		break;
	  case "sd":
		if ( level.bombplanted &&
		     !codam\utils::getVar( "scr_sd", "ignorebomb", "bool",
		     						 2, false ) )
			return;

		if ( !level.exist[ game[ "attackers" ] ] ||
		     !level.exist[ game[ "defenders" ] ] )
			_winner = "draw";
		else
			_winner = game[ "defenders" ];

		_text = &"SD_TIMEHASEXPIRED";
		break;
	  default:
	  	// New gametype?
		break;
	}

	if ( isdefined( _text ) )
		level notify( "end_round", _text, _winner , undefined, true );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
checkMatchStart( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 50, "checkMatchStart" );

	if ( !game[ "mapstarted" ] )
		return;

	didexist[ "teams" ] = level.exist[ "teams" ];
	level.exist[ "teams" ] = false;

	// If teams currently exist
	if ( level.exist[ "allies" ] &&
	     level.exist[ "axis" ] )
		level.exist[ "teams" ] = true;

	// If teams previously did not exist and now they do
	if ( !didexist[ "teams" ] &&
	     level.exist[ "teams" ] &&
	     !level.roundended )
	{
		if ( !game[ "matchstarted" ] )
		{
			_outcome = "reset";
			switch( level.ham_g_gametype )
			{
			  case "re":
				_announce = &"RE_MATCHSTARTING";
				break;
			  default:
				_announce = &"SD_MATCHSTARTING";
				break;
			}
		}
		else
		{
			_outcome = "draw";
			switch( level.ham_g_gametype )
			{
			  case "re":
				_announce = &"RE_MATCHRESUMING";
				break;
			  default:
				_announce = &"SD_MATCHRESUMING";
				break;
			}
		}

		level notify( "end_round", _announce, _outcome );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
endRound( announce, roundwinner, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isdefined( announce ) &&
	     !isdefined( roundwinner ) )
		level waittill( "end_round", announce, roundwinner, cam,
								timeexpired );

	codam\utils::debug( 0, "endRound:: |", announce, "|", roundwinner, "|",
						cam, "|", timeexpired, "|" );

	level thread [[ level.gtd_call ]]( "hud_announce", announce );

	if ( level.roundended )
		return;

	if ( roundwinner == "reset" )
	{
		// Starting a new match ...

		wait( 2 );	// Allow time to view "start" message

		if ( game[ "mapstarted" ] ||
		     ( level.exist[ "allies" ] && level.exist[ "axis" ] ) )
			game[ "matchstarted" ] = true;
		[[ level.gtd_call ]]( "resetScores" );
		game[ "roundsplayed" ] = 0;

		level.roundended = true;
	}
	else
	{
		_announce = "MP_announcer_round_draw";

		if ( roundwinner == "allies" )
		{
			roundloser = "axis";
			game[ "alliedscore" ]++;
			score = game[ "alliedscore" ];
			_announce = "MP_announcer_allies_win";
		}
		else if ( roundwinner == "axis" )
		{
			roundloser = "allies";
			game[ "axisscore" ]++;
			score = game[ "axisscore" ];
			_announce = "MP_announcer_axis_win";
		}

		winners = [];
		losers = [];

		players = getentarray( "player", "classname" );
		for ( i = 0; i < players.size; i++ )
		{
			player = players[ i ];

			if ( roundwinner != "draw" )
			{
				_team = player.pers[ "team" ];
				if ( isdefined( _team ) )
				{
					if ( _team == roundwinner )
						winners[ winners.size ] = player;
					else if ( _team == roundloser )
						losers[ losers.size ] = player;
				}
			}

			player playLocalSound( _announce );
		}

		[[ level.gtd_call ]]( "gt_saveWeapons" );

		if ( roundwinner != "draw" )
		{
			[[ level.gtd_call ]]( "setTeamScore", roundwinner,
									score );

			if ( game[ "matchstarted" ] )
			{
				[[ level.gtd_call ]]( "logPrint", "winner",
							roundwinner, winners );
				[[ level.gtd_call ]]( "logPrint", "loser",
							roundloser, losers );
			}

			if ( !isdefined( timeexpired ) )
				[[ level.gtd_call ]]( "gt_roundCam",
							cam, roundwinner );
			else
				wait( 3 );	// Allow time to view winner

			[[ level.gtd_call ]]( "checkScoreLimit",
			  			"gt_scoreLimitReached" );
		}
		else
			wait( 3 );	// Allow time to view draw message

		game[ "roundsplayed" ]++;
		[[ level.gtd_call ]]( "checkRoundLimit",
						"gt_roundLimitReached" );
		level.roundended = true;
		[[ level.gtd_call ]]( "checkTimeLimit", "gt_timeLimitReached" );
	}

	if ( level.mapended )
		return;
	level.mapended = true;

	[[ level.gtd_call ]]( "saveAllPlayers" );
	[[ level.gtd_call ]]( "map_restart", true );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
endMap( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level waittill( "end_map" );
	level.mapended = true;

	game[ "state" ] = "intermission";
	level notify( "intermission" );

	if ( game[ "alliedscore" ] == game[ "axisscore" ] )
		text = &"MPSCRIPT_THE_GAME_IS_A_TIE";
	else if ( game[ "alliedscore"] > game[ "axisscore" ] )
		text = &"MPSCRIPT_ALLIES_WIN";
	else
		text = &"MPSCRIPT_AXIS_WIN";

	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];

		player closeMenu();
		player setClientCvar( "g_scriptMainMenu", "main" );
		player setClientCvar( "cg_objectiveText", text );
		player [[ level.gtd_call ]]( "gt_spawnIntermission" );
	}

	wait( 7 );

	[[ level.gtd_call ]]( "saveAllPlayers"  );
	[[ level.gtd_call ]]( "exitLevel", false );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
updateTeamStatus( delay, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 50, "sd/updateTeamStatus" );

	if ( isdefined( delay ) )
		wait( 0.5 );

	resettimeout();

	didexist = [[ level.gtd_call ]]( "playersInTeams" );

	if ( level.roundended ||
	     !game[ "mapstarted" ] )
		return;

	if ( level.allowrespawn )
	{
		if ( !game[ "matchstarted" ] )
			level notify( "update_matchstart" );
		return;
	}

	_winner = undefined;

	if ( didexist[ "allies" ] && !level.exist[ "allies" ] &&
	     didexist[ "axis" ] && !level.exist[ "axis" ] )
	{
		if ( level.ham_g_gametype == "re" )
		{
			_announce = &"RE_ROUND_DRAW";
			_winner = "draw";
		}
		else if ( !level.bombplanted )
		{
			_announce = &"SD_ROUNDDRAW";
			_winner = "draw";
		}
		else if( game[ "attackers" ] == "allies" )
		{
			_announce = &"SD_ALLIEDMISSIONACCOMPLISHED";
			_winner = "allies";
		}
		else
		{
			_announce = &"SD_AXISMISSIONACCOMPLISHED";
			_winner = "axis";
		}
	}
	else if ( didexist[ "allies" ] && !level.exist[ "allies" ] )
	{
		_winner = "axis";
		if ( level.ham_g_gametype == "re" )
			_announce = &"RE_ELIMINATED_ALLIES";
		else if ( !level.bombplanted )
		{
			// no bomb planted, axis win
			_announce = &"SD_ALLIESHAVEBEENELIMINATED";
		}
		else if ( game[ "attackers" ] == "allies" )
			return;
		else if ( level.exist[ "axis" ] )
		{
			// allies just died and axis have planted the bomb
			_announce = &"SD_ALLIESHAVEBEENELIMINATED";
		}
		else
			_announce = &"SD_AXISMISSIONACCOMPLISHED";
	}
	else if ( didexist[ "axis" ] && !level.exist[ "axis" ] )
	{
		_winner = "allies";
		if ( level.ham_g_gametype == "re" )
			_announce = &"RE_ELIMINATED_AXIS";
		else if ( !level.bombplanted )
		{
			// no bomb planted, axis win
			_announce = &"SD_AXISHAVEBEENELIMINATED";
 		}
		else if ( game[ "attackers" ] == "axis" )
			return;
		else if ( level.exist[ "allies" ] )
		{
			// axis just died and allies have planted the bomb
			_announce = &"SD_AXISHAVEBEENELIMINATED";
		}
		else
			_announce = &"SD_ALLIEDMISSIONACCOMPLISHED";
	}

	if ( isdefined( _winner ) )
		level notify( "end_round", _announce , _winner,
							level.playercam );
	else if ( !game[ "matchstarted" ] )
		level notify( "update_matchstart" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
saveWeapons( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !codam\utils::getVar( "scr", "saveweapons", "bool", 1|2, true ) )
		return;

	// for all living players, store their weapons
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];

		_team = player.pers[ "team" ];
		if ( isdefined( _team ) && ( _team != "spectator" ) &&
		     ( player.sessionstate == "playing" ) )
		{
			primary = player getWeaponSlotWeapon( "primary" );
			primaryb = player getWeaponSlotWeapon( "primaryb" );

			// If a menu selection was made
			if ( isdefined( player.oldweapon ) )
			{
				// If a new weapon has since been picked up
				// (this fails when a player picks up a weapon
				//  the same as his original)
				if ( ( player.oldweapon != primary ) &&
				     ( player.oldweapon != primaryb ) &&
				     ( primary != "none" ) )
				{
					player.pers[ "weapon1" ] = primary;
					player.pers[ "weapon2" ] = primaryb;
					player.pers[ "spawnweapon" ] =
						player getCurrentWeapon();
				}
				// If the player's menu chosen weapon is the
				// same as what is in the primaryb slot, swap
				else
				if( player.pers[ "weapon" ] == primaryb )
				{
					player.pers[ "weapon1" ] = primaryb;
					player.pers[ "weapon2" ] = primary;
					player.pers[ "spawnweapon" ] =
						player.pers[ "weapon1" ];
				}
				// Give them the weapon they chose from menu
				else
				{
					player.pers[ "weapon1" ] =
						player.pers[ "weapon" ];
					player.pers[ "weapon2" ] = primaryb;
					player.pers[ "spawnweapon" ] =
						player.pers[ "weapon1" ];
				}
			}
			// No menu choice was ever made, so keep their
			// weapons and spawn them with what they're holding,
			// unless it's a pistol or grenade
			else
			{
				if ( primary == "none" )
					player.pers[ "weapon1" ] =
						player.pers[ "weapon" ];
				else
					player.pers[ "weapon1" ] = primary;

				player.pers[ "weapon2" ] = primaryb;

				spawnweapon = player getCurrentWeapon();
				if ( !maps\mp\gametypes\_teams::isPistolOrGrenade( spawnweapon ) )
					player.pers[ "spawnweapon" ] =
								spawnweapon;
				else
					player.pers[ "spawnweapon" ] =
						player.pers[ "weapon1" ];
			}
		}
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
roundCam( cam, roundwinner, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !codam\utils::getVar( "scr", "roundcam", "bool", 1|2, false ) ||
	     !isdefined( cam ) ||
	     !isdefined( roundwinner ) )
	{
		wait( 3 );
		return;
	}

	delay = 2;	// Wait for player/objective to finish death anim!
	wait( delay );

	if ( roundwinner == "allies" )
		text = &"MPSCRIPT_ALLIES_WIN";
	else if ( roundwinner == "axis" )
		text = &"MPSCRIPT_AXIS_WIN";
	else
		text = undefined;

	viewers = 0;
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];

		if ( isdefined( player.killcam ) ||
		     ( player.archivetime > 0 ) )
		{
			// Already running killcam, stop it!
			player notify( "spawned" );
			wait( 0.05 );
			player.spectatorclient = -1;
			player.archivetime = 0;
		}

		player thread [[ level.gtd_call ]]( "roundcam", cam, delay,
									text );
		viewers++;
	}

	if ( viewers )
		level waittill( "roundcam_ended" );
	else
		wait( 3 - delay );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

bombzones( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level.barsize = 288;
	//level.planttime = 5;		// seconds to plant a bomb
	//level.defusetime = 10;		// seconds to defuse a bomb

	level.planttime = codam\utils::getVar( "scr", "bombplant", "float",
							1|2, 5, 0.01, 10 );
	level.defusetime =  codam\utils::getVar( "scr", "bombdefuse", "float",
							1|2, 10, 0.01, 15 );

	bombtrigger = getent( "bombtrigger", "targetname" );
	if ( !isdefined( bombtrigger ) )
	{
		codam\utils::_debug( "^1ERROR^7: no bomb trigger" );
		[[ level.gtd_call ]]( "exitLevel", false );
		wait( 9999 );
	}

	bombtrigger maps\mp\_utility::triggerOff();

	bombzone_A = getent( "bombzone_A", "targetname" );
	bombzone_B = getent( "bombzone_B", "targetname" );
	if ( !isdefined( bombzone_A ) ||
	     !isdefined( bombzone_B ) )
	{
		codam\utils::_debug( "^1ERROR^7: map is missing bomb zones" );
		[[ level.gtd_call ]]( "exitLevel", false );
		wait( 9999 );
	}

	bombzone_A thread bombzone_think( bombzone_B );
	bombzone_B thread bombzone_think( bombzone_A );

	wait( 1 );	// TEMP: without this one of the objective icon is the
			// default. Carl says we're overflowing something.
	objective_add( 0, "current", bombzone_A.origin,
						"gfx/hud/hud@objectiveA.tga" );
	objective_add( 1, "current", bombzone_B.origin,
						"gfx/hud/hud@objectiveB.tga" );
}

bombzone_think(bombzone_other)
{
	level.barincrement = (level.barsize / (20.0 * level.planttime));

	for(;;)
	{
		self waittill("trigger", other);

		if(isdefined(bombzone_other.planting))
		{
			if(isdefined(other.planticon))
				other.planticon destroy();

			continue;
		}

		if(isPlayer(other) && (other.pers["team"] == game["attackers"]) && other isOnGround())
		{
			if(!isdefined(other.planticon))
			{
				other.planticon = newClientHudElem(other);
				other.planticon.alignX = "center";
				other.planticon.alignY = "middle";
				other.planticon.x = 320;
				other.planticon.y = 345;
				other.planticon setShader("ui_mp/assets/hud@plantbomb.tga", 64, 64);
			}

			while(other istouching(self) && isalive(other) && other useButtonPressed())
			{
				other notify("kill_check_bombzone");

				self.planting = true;

				if(!isdefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);
					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.x = 320;
					other.progressbackground.y = 385;
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);

				if(!isdefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);
					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.x = (320 - (level.barsize / 2.0));
					other.progressbar.y = 385;
				}
				other.progressbar setShader("white", 0, 8);
				other.progressbar scaleOverTime(level.planttime, level.barsize, 8);

				other playsound("MP_bomb_plant");
				other linkTo(self);
				other [[ level.gtd_call ]]( "disableWeapon" );

				self.progresstime = 0;
				while(isalive(other) && other useButtonPressed() && (self.progresstime < level.planttime))
				{
					self.progresstime += 0.05;
					wait 0.05;
				}

				if(self.progresstime >= level.planttime)
				{
					other.planticon destroy();
					other.progressbackground destroy();
					other.progressbar destroy();

					if ( isdefined( self.target ) )
						level.goalcam = getent(self.target, "targetname");
					level.bombexploder = self.script_noteworthy;

					bombzone_A = getent("bombzone_A", "targetname");
					bombzone_B = getent("bombzone_B", "targetname");
					bombzone_A delete();
					bombzone_B delete();
					objective_delete(0);
					objective_delete(1);

					plant = other maps\mp\_utility::getPlant();

					level.bombmodel = spawn("script_model", plant.origin);
					level.bombmodel.angles = plant.angles;
					level.bombmodel setmodel("xmodel/mp_bomb1_defuse");
					level.bombmodel playSound("Explo_plant_no_tick");

					bombtrigger = getent("bombtrigger", "targetname");
					bombtrigger.origin = level.bombmodel.origin;

					if ( isdefined( level.goalcam ) )
						level.goalcam.angles = vectortoangles(level.bombmodel.origin - level.goalcam.origin);

					objective_add(0, "current", bombtrigger.origin, "gfx/hud/hud@bombplanted.tga");

					level.bombplanted = true;
					other [[ level.gtd_call ]]( "enableWeapon" );

					[[ level.gtd_call ]]( "logPrint", "action", other, game["attackers"], other.name, "bomb_plant" );

					level thread [[ level.gtd_call ]]( "hud_announce", &"SD_EXPLOSIVESPLANTED" );

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
						players[i] playLocalSound("MP_announcer_bomb_planted");

					bombtrigger thread bomb_think();
					bombtrigger thread bomb_countdown();

					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					other.progressbackground destroy();
					other.progressbar destroy();
					other unlink();
					other [[ level.gtd_call ]]( "enableWeapon" );
				}

				wait .05;
			}

			self.planting = undefined;
			other thread check_bombzone(self);
		}
	}
}

check_bombzone(trigger)
{
	self notify("kill_check_bombzone");
	self endon("kill_check_bombzone");

	while(isdefined(trigger) && !isdefined(trigger.planting) && self istouching(trigger) && isalive(self))
		wait 0.05;

	if(isdefined(self.planticon))
		self.planticon destroy();
}

bomb_countdown()
{
	self endon ("bomb_defused");

	level.bombmodel playLoopSound("bomb_tick");

	// set the countdown time
	// Ham
	countdowntime = codam\utils::getVar( "scr", "bombtimer", "float",
							1|2, 60, 15, 120 );
	if ( codam\utils::getVar( "ham", "stopwatch", "bool", 1|2, true ) )
	{
		self._stopwatch = newHudElem();
		self._stopwatch.x = 36;
		self._stopwatch.y = 240;
		self._stopwatch.alignX = "center";
		self._stopwatch.alignY = "middle";
		self._stopwatch setClock(countdowntime, 60, "hudStopwatch", 48, 48);
	}
	self thread bombRemoveStopwatch();

	wait countdowntime;

	// bomb timer is up

	// Ham
	if ( isdefined( self._stopwatch ) )
		self._stopwatch destroy();

	objective_delete(0);

	level.bombexploded = true;
	self notify ("bomb_exploded");

	// trigger exploder if it exists
	if(isdefined(level.bombexploder))
		maps\mp\_utility::exploder(level.bombexploder);

	// explode bomb
	origin = self getorigin();
	range = 500;
	maxdamage = 2000;
	mindamage = 1000;

	self delete(); // delete the defuse trigger
	level.bombmodel stopLoopSound();
	level.bombmodel delete();

	playfx(level._effect["bombexplosion"], origin);
	radiusDamage(origin, range, maxdamage, mindamage);

	if( game[ "attackers" ] == "allies" )
		_announce = &"SD_ALLIEDMISSIONACCOMPLISHED";
	else
		_announce = &"SD_AXISMISSIONACCOMPLISHED";
	level notify( "end_round", _announce, game["attackers"],
							level.goalcam );
}

bombRemoveStopwatch()
{
	self endon( "bomb_exploded" );

	self waittill( "bomb_defused" );
	if ( isdefined( self._stopwatch ) )
		self._stopwatch destroy();
	return;
}

bomb_think()
{
	self endon ("bomb_exploded");
	level.barincrement = (level.barsize / (20.0 * level.defusetime));

	for(;;)
	{
		self waittill("trigger", other);

		// check for having been triggered by a valid player
		if(isPlayer(other) && (other.pers["team"] == game["defenders"]) && other isOnGround())
		{
			if(!isdefined(other.defuseicon))
			{
				other.defuseicon = newClientHudElem(other);
				other.defuseicon.alignX = "center";
				other.defuseicon.alignY = "middle";
				other.defuseicon.x = 320;
				other.defuseicon.y = 345;
				other.defuseicon setShader("ui_mp/assets/hud@defusebomb.tga", 64, 64);
			}

			self thread clearBombDefuse( other );

			while(other islookingat(self) && distance(other.origin, self.origin) < 64 && isalive(other) && other useButtonPressed())
			{
				other notify("kill_check_bomb");

				self.defusing = true;

				if(!isdefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);
					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.x = 320;
					other.progressbackground.y = 385;
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);

				if(!isdefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);
					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.x = (320 - (level.barsize / 2.0));
					other.progressbar.y = 385;
				}
				other.progressbar setShader("white", 0, 8);
				other.progressbar scaleOverTime(level.defusetime, level.barsize, 8);

				other playsound("MP_bomb_defuse");
				other linkTo(self);
				other [[ level.gtd_call ]]( "disableWeapon" );

				self.progresstime = 0;
				while(isalive(other) && other useButtonPressed() && (self.progresstime < level.defusetime))
				{
					self.progresstime += 0.05;
					wait 0.05;
				}

				if(self.progresstime >= level.defusetime)
				{
					other.defuseicon destroy();
					other.progressbackground destroy();
					other.progressbar destroy();

					objective_delete(0);

					self notify ("bomb_defused");
					level.bombmodel setmodel("xmodel/mp_bomb1");
					level.bombmodel stopLoopSound();
					self delete();

					other [[ level.gtd_call ]]( "enableWeapon" );

					[[ level.gtd_call ]]( "logPrint", "action", other, game["defenders"], other.name, "bomb_defuse" );

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
						players[i] playLocalSound("MP_announcer_bomb_defused");

					level notify( "end_round", &"SD_EXPLOSIVESDEFUSED", game["defenders"], level.goalcam );
					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					other.progressbackground destroy();
					other.progressbar destroy();
					other unlink();
					other [[ level.gtd_call ]]( "enableWeapon" );
				}

				wait .05;
			}

			self.defusing = undefined;
			other thread check_bomb(self);
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
check_bomb( trigger )
{
	trigger endon( "bomb_exploded" );
	self notify( "kill_check_bomb" );
	self endon( "kill_check_bomb" );

	while ( isdefined( trigger ) &&
	        !isdefined( trigger.defusing ) &&
	        ( distance( self.origin, trigger.origin ) < 32 ) &&
	        ( self islookingat( trigger ) ) &&
	        isalive( self ) )
		wait( 0.05 );

	if ( isdefined( self.defuseicon ) )
		self.defuseicon destroy();
}

//
///////////////////////////////////////////////////////////////////////////////
clearBombDefuse( player )
{
	self notify( "bomb_not_defused" );
	self endon( "bomb_not_defused" );
	self endon( "bomb_defused" );

	self waittill( "bomb_exploded" );

  	if ( isdefined( player.defuseicon ) )
		player.defuseicon destroy();
  	if ( isdefined( player.progressbackground ) )
		player.progressbackground destroy();
  	if ( isdefined( player.progressbar ) )
		player.progressbar destroy();
	player unlink();
	player [[ level.gtd_call ]]( "enableWeapon" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
