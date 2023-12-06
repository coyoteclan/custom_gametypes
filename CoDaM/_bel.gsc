
//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_BEL" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "bel" );

	[[ level.gtd_call ]]( "registerSpawn", "mp_teamdeathmatch_spawn",
								"middle3rd" );

	level.AlivePointTime = codam\utils::getVar( "scr_bel", "alivepointtime",
							"int", 2, 10, 0 );

	level.PositionUpdateTime = codam\utils::getVar( "scr_bel", "positiontime",
							"int", 2, 6, 0 );

	if( getcvar( "scr_bel_respawndelay") == "" )
		setcvar( "scr_bel_respawndelay", "0" );

	if ( getcvar( "scr_bel_showoncompass") == "" )
		setcvar ( "scr_bel_showoncompass", "1" );

	level.alliesallowed = 1;

	level.objused = [];
	for (i=0;i<16;i++)
		level.objused[i] = false;

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
	{
		// Need to override these methods from the default
		[[ register ]]( "isWeaponMenu", ::isWeapMenu,	"takeover" );
		[[ register ]](   "goSpectate", ::goSpectate,	"takeover" );
		return;
	}

	// Script-level	callbacks
	[[ register ]](	   "StartGameType", ::StartGameType );
	[[ register ]](	   "PlayerConnect", codam\callbacks::PlayerConnect );
	[[ register ]](	"PlayerDisconnect", codam\callbacks::PlayerDisconnect );
	[[ register ]](	    "PlayerDamage", codam\callbacks::PlayerDamage );
	[[ register ]](	    "PlayerKilled", codam\callbacks::PlayerKilled );

	// Game-type callbacks
	[[ register ]](   "finishPlayerKilled", ::finishPlayerKilled );
	[[ register ]](	        "gt_startGame",
					codam\GameTypes\_tdm::startGame );
	[[ register ]](	      "gt_checkUpdate",
					codam\GameTypes\_tdm::checkUpdate );
	[[ register ]](            "gt_endMap",
					codam\GameTypes\_tdm::endMap );
	[[ register ]](          "gt_endRound",
					codam\GameTypes\_tdm::endRound );
	[[ register ]](       "gt_spawnPlayer", ::spawnPlayer );
	[[ register ]](    "gt_spawnSpectator", ::spawnSpectator );
	[[ register ]]( "gt_spawnIntermission", ::spawnIntermission );
	[[ register ]](		  "gt_respawn", ::respawn );
	[[ register ]](       "gt_menuHandler", ::menuHandler );
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
			makeCvarServerInfo( "ui_bel_timelimit", "30" );
			makeCvarServerInfo( "ui_bel_scorelimit", "50" );

			game[ "menu_serverinfo" ] = "serverinfo_" +
							level.ham_g_gametype;
			precacheMenu( game[ "menu_serverinfo" ] );
		}

		game[ "menu_team" ] = "team_germanonly";
		game[ "menu_weapon_all" ] = "weapon_" +
					game[ "allies" ] + game[ "axis" ];
		game[ "menu_weapon_allies_only" ] = "weapon_" +
							game[ "allies" ];
		game[ "menu_weapon_axis_only" ] = "weapon_" + game[ "axis" ];
		precacheString( &"BEL_TIME_ALIVE" );
		precacheString( &"BEL_TIME_TILL_SPAWN" );
		precacheString( &"BEL_PRESS_TO_RESPAWN" );
		precacheString( &"BEL_POINTS_EARNED" );
		precacheString( &"BEL_WONTBE_ALLIED" );
		precacheString( &"BEL_BLACKSCREEN_KILLEDALLIED" );
		precacheString( &"BEL_BLACKSCREEN_WILLSPAWN" );

		precacheMenu( game[ "menu_team" ] );
		precacheMenu( game[ "menu_weapon_all" ] );
		precacheMenu( game[ "menu_weapon_allies_only" ] );
		precacheMenu( game[ "menu_weapon_axis_only" ] );

		precacheShader( "gfx/hud/hud@objective_bel.tga" );
		precacheShader( "gfx/hud/hud@objective_bel_up.tga" );
		precacheShader( "gfx/hud/hud@objective_bel_down.tga" );

		[[ level.gtd_call ]]( "scoreboard" );
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
finishPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath,
				sWeapon, vDir, sHitLoc,	a7, a8,	a9,
				b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9 )
{
	self [[	level.gtd_call ]]( "playerDeath", eAttacker );
	wait( 0.1 );	// Get some air ...
	self updateDeathArray();

	if ( isPlayer( eAttacker ) )
	{
		if ( eAttacker == self )	// killed himself
		{
			if ( self.pers[ "team" ] == "allies" )
			{
				if ( Number_On_Team( "axis" ) < 1 )
					self thread [[ level.gtd_call ]](
							"gt_respawn", "auto" );
				else
				{
					self move_to_axis();
					CheckAllies_andMoveAxis_to_Allies(
							undefined, self );
				}
			}
			else
				self thread [[ level.gtd_call ]]( "gt_respawn" );
		}
		else
		if ( !isdefined( eAttacker.pers[ "team" ] ) ||
		     ( eAttacker.pers[ "team" ] == "spectator" ) )
		{  // Kicked for TD/TK
			self thread [[ level.gtd_call ]]( "gt_respawn" );
		}
		else
		if ( self.pers[ "team" ] == eAttacker.pers[ "team" ] )
		{
			if ( eAttacker.pers[ "team" ] == "allies" )
			{
				eAttacker move_to_axis();
				CheckAllies_andMoveAxis_to_Allies( undefined,
								eAttacker);
			}

			self thread [[ level.gtd_call ]]( "gt_respawn" );
		}
		else
		{
			if ( self.pers[ "team" ] == "allies" )
			{ //Allied player was killed by an Axis
				eAttacker.god = true;
				iprintln( &"BEL_KILLED_ALLIED_SOLDIER",
								eAttacker );

				//"allies to axis");
				self thread move_to_axis( 2, "nodelay on respawn" );

				Set_Number_Allowed_Allies( Number_On_Team( "axis" ) );

				if ( Number_On_Team( "allies" ) <
							level.alliesallowed )
					eAttacker move_to_allies( undefined, 2,
						"nodelay on respawn", 1 );
				else
				{
					eAttacker.god = false;
					eAttacker thread client_print(
							&"BEL_WONTBE_ALLIED" );
				}

				return;
			}
			else
			{ //Axis player was killed by Allies
				eAttacker [[ level.gtd_call ]](
							"checkScoreLimit",
							"gt_playerScoreLimit" );

				// Stop thread if map ended on this death
				if ( level.mapended )
					return;

				//"axis to axis");
				if ( !isAlive( self ) )
					self thread [[ level.gtd_call ]](
						"gt_respawn", "auto", 0 );

				return;
			}
		}
	}
	else //	You were in the	wrong place at the wrong time
	{
		if ( self.pers[ "team" ] == "allies" )
		{
			if ( Number_On_Team( "axis" ) < 1 )
				self thread [[ level.gtd_call ]]( "gt_respawn",
								"auto" );
			else
			{
				self move_to_axis();
				CheckAllies_andMoveAxis_to_Allies( undefined,
									self );
			}
		}
		else
			self thread [[ level.gtd_call ]]( "gt_respawn" );
	}

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
			menu = undefined;
		  	switch ( val )
		  	{
		  	  case "spectator":
				if ( self.pers[ "team" ] != "spectator" )
					self [[ level.gtd_call ]](
								"goSpectate" );

				break;
		  	  default:
				if ( [[ level.gtd_call ]]( "isTeam",
							self.pers[ "team" ] ) )
					break;	// Already on a team!

				self setClientCvar( "g_scriptMainMenu",
					game[ "menu_weapon_axis_only" ] );
				self.pers[ "team" ] = "axis";
				self removeBlackScreen();
				CheckAllies_andMoveAxis_to_Allies( self );
				self thread [[ level.gtd_call ]](
							"printJoinedTeam",
							 self.pers[ "team" ] );
				if ( self.pers[ "team" ] == "axis" )
					self move_to_axis();
				self setClientCvar( level.ui_weapontab, "1" );
				break;
		  	}
		  	break;
		  case "weapon":
		  	team = self.pers[ "team" ];
			if ( ![[ level.gtd_call ]]( "isTeam", team ) )
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

			if ( isdefined( self.pers[ "weapon" ] ) &&
			     ( self.pers[ "weapon" ] == weapon ) )
			{
				menu = undefined;
				break;	// Same weapon selected!
			}

			axisweapon = false;
			_team = "allies";
			switch ( weapon )
			{
			  case "kar98k_mp":
			  case "mp40_mp":
			  case "mp44_mp":
			  case "kar98k_sniper_mp":
				axisweapon = true;
				_team = "axis";
				break;
			}

			// Is the weapon available?
			weapon = self [[ level.gtd_call ]]( "assignWeapon",
						weapon, undefined, _team );
			if ( !isdefined( weapon ) )
			{
				self iprintln(
					"^3*** Weapon is unavailable." );
				break;
			}

			if ( !isdefined( self.pers[ "weapon" ] ) )
			{
				// First selected weapon ...

				if ( axisweapon )
					self.pers[ "LastAxisWeapon" ] = weapon;
				else
					self.pers[ "LastAlliedWeapon" ] =
									weapon;

				if ( !self.respawnwait )
				{
					if ( axisweapon &&
					     ( team == "allies" ) )
						break;
					else
					if ( !axisweapon &&
					     ( team == "axis" ) )
						break;

					menu = undefined;

					self.pers[ "weapon" ] = weapon;
					self [[ level.gtd_call ]](
							"gt_spawnPlayer" );
				}
			}
			else
			{
				// Already have a weapon, wait 'til next spawn

			  	team = self.pers[ "team" ];
				if ( ( self.sessionstate != "playing" ) &&
				     !self.respawnwait )
				{
					if ( isDefined( team ) )  // WHY????
					{
						if ( !axisweapon &&
						     ( team == "allies" ) )
							self.pers[ "LastAlliedWeapon" ] = weapon;
						else
						if ( axisweapon &&
						     ( team == "axis" ) )
							self.pers[ "LastAxisWeapon" ] = weapon;
						else
							break;	// Why???

						self.pers[ "weapon" ] = weapon;
						self [[ level.gtd_call ]](
							"gt_spawnPlayer" );
					}
				}
				else
				{
					if ( axisweapon )
					{
						self.pers[ "LastAxisWeapon" ] =
									weapon;
						if ( maps\mp\gametypes\_teams::useAn( weapon ) )
							text = &"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_AN";
						else
							text = &"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_A";
					}
					else
					{
						self.pers[ "LastAlliedWeapon" ] =
									weapon;
						if ( maps\mp\gametypes\_teams::useAn( weapon ) )
							text = &"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_AN";
						else
							text = &"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_A";
					}

					weaponname = maps\mp\gametypes\_teams::getWeaponName( weapon );
					self iprintln( text, weaponname );

					if ( !axisweapon &&
					     ( team == "allies" ) )
						self.pers[ "nextWeapon" ] =
									weapon;
					else
					if ( axisweapon &&
					     ( team == "axis" ) )
						self.pers[ "nextWeapon" ] =
									weapon;
					else
						break;	// Why???
				}

				if ( isdefined( team ) )
				{
					if ( !axisweapon &&
					     ( self.pers["team"] ==
					     		"allies" ) )
						self.pers[ "LastAlliedWeapon" ] = weapon;
					else
					if ( axisweapon &&
					     ( self.pers["team"] ==
					     		"axis" ) )
						self.pers[ "LastAxisWeapon" ] = weapon;
				}
			}
		  	break;
		  case "menu":
			if ( ( val == "weapon" ) &&
		  	     isdefined( self.pers[ "team" ] ) )
			  	menu = game[ "menu_weapon_all" ];
		  	break;
		  default:
		  	menu = undefined;
		  	break;
		}
	}
}

//
///////////////////////////////////////////////////////////////////////////////
isWeapMenu( menu, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( isdefined( menu ) &&
	     ( ( menu == game[ "menu_weapon_all" ] ) ||
	       ( menu == game[ "menu_weapon_allies_only" ] ) ||
	       ( menu == game[ "menu_weapon_axis_only" ] ) ) )
		return ( true );

	return ( false );
}

//
///////////////////////////////////////////////////////////////////////////////
goSpectate( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	if ( self.sessionstate == "playing" )
		self [[ level.gtd_call ]]( "suicide" );

	self.pers[ "team" ] = "spectator";
	self.sessionteam = "spectator";
	self.pers[ "weapon" ] = undefined;
	self.pers[ "savedmodel" ] = undefined;

	self.pers[ "LastAxisWeapon" ] = undefined;
	self.pers[ "LastAlliedWeapon" ] = undefined;
	self removeBlackScreen();
	self setClientCvar( "g_scriptMainMenu", game[ "menu_team" ] );
	self setClientCvar( level.ui_weapontab, "0" );

	self [[ level.gtd_call ]]( "gt_spawnSpectator" );
	CheckAllies_andMoveAxis_to_Allies();
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
spawnPlayer( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 80, "bel/spawnPlayer:: |", self.name, "|",
			self.pers[ "team" ], "|", self.pers[ "weapon" ], "|" );

	self notify( "stop weapon timeout" );
	self notify( "do_timer_cleanup" );

	self.respawnwait = false;
	//self.lastteam = self.pers[ "team" ];

	if ( isdefined( self.spawnMsg ) )
		self.spawnMsg destroy();

	_team = self.pers[ "team" ];

	self.sessionteam = self [[ level.gtd_call ]]( "sessionteam" );

	// Save player's info across map rotations
	//self [[ level.gtd_call ]]( "savePlayer" );

	// Make it so ...
	self [[ level.gtd_call ]]( "spawnPlayer" );

	self setClientCvar( level.ui_weapontab, "1" );
	self setClientCvar( "g_scriptMainMenu", game[ "menu_weapon_all" ] );

	if ( _team == "allies" )
		_weap = "LastAlliedWeapon";
	else
	if ( _team == "axis" )
		_weap = "LastAxisWeapon";

	if ( isdefined( self.pers[ _weap ] ) )
		self.pers[ "weapon" ] = self.pers[ _weap ];
	else
	if ( isdefined( self.pers[ "nextWeapon" ] ) )
	{
		self.pers[ "weapon" ] = self.pers[ "nextWeapon" ];
		self.pers[ "nextWeapon" ] = undefined;
	}

	_weap = self.pers[ "weapon" ];
	__weap = self [[ level.gtd_call ]]( "assignWeaponSlot", "primary",
									_weap );
	self setSpawnWeapon( __weap );
	self switchToWeapon( __weap );

	self [[ level.gtd_call ]]( "givePistol" );
	self [[ level.gtd_call ]]( "giveGrenade", _weap );

	if ( self.pers[ "team" ] == "allies" )
	{
		self thread make_obj_marker();
		text = &"BEL_OBJ_ALLIED";
	}
	else
		text = &"BEL_OBJ_AXIS";
	self setClientCvar( "cg_objectiveText", text );

	self.god = false;
	wait 0.05;
	if ( isdefined( self ) )
		self removeBlackScreen();

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
spawnSpectator( origin, angles, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	self check_delete_objective();

	codam\GameTypes\_tdm::spawnSpectator( origin, angles,
					"mp_teamdeathmatch_intermission",
					"spawn_random", &"BEL_SPECTATOR_OBJS" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
spawnIntermission( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	self [[ level.gtd_call ]]( "spawnIntermission",
					"mp_teamdeathmatch_intermission",
					"spawn_middle3rd" );
	self removeBlackScreen();

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
GetNextObjNum()
{
	for (i=0;i<16;i++)
	{
		if (level.objused[i] == true)
			continue;

		level.objused[i] = true;
		//return ( i + 1 );
		return ( i );
	}
	return -1;
}

//
///////////////////////////////////////////////////////////////////////////////
removeBlackScreen()
{
	if ( isdefined( self.blackscreen ) )
		self.blackscreen destroy();
	if ( isdefined( self.blackscreentext ) )
		self.blackscreentext destroy();
	if ( isdefined( self.blackscreentext2 ) )
		self.blackscreentext2 destroy();
	if ( isdefined( self.blackscreentimer ) )
		self.blackscreentimer destroy();
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
respawn(noclick, delay, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9 )
{
	self endon( "end_respawn" );

	if (!isdefined (delay))
		delay = 2;
	wait delay;

	// If killcam active, wait for it to finish ...
	while ( isdefined( self.killcam ) ||
		self.archivetime )
		wait( 0.05 );

	if (isdefined (self))
	{
		if (!isdefined (noclick))
		{
			if(getcvarint("scr_bel_respawndelay") > 0)
			{
				self thread waitForceRespawnTime();
				self waittill("respawn");
			}
			else
			{
				self thread [[ level.gtd_call ]](
							"gt_spawnPlayer" );
				return;
			}
		}
		else
			self thread [[ level.gtd_call ]]( "gt_spawnPlayer" );
	}
}

Respawn_HUD_Timer_Cleanup()
{
	self waittill("do_timer_cleanup");

	if (self.spawnTimer)
		self.spawnTimer destroy();
}

Respawn_HUD_Timer_Cleanup_Wait(message)
{
	self endon("do_timer_cleanup");

	self waittill(message);
	self notify("do_timer_cleanup");
}

Respawn_HUD_Timer()
{
	self endon ("respawn");
	self endon ("end_respawn");

	respawntime = getcvarint("scr_bel_respawndelay");
	wait .1;

	if (!isdefined(self.toppart))
	{
		self.spawnMsg = newClientHudElem(self);
		self.spawnMsg.alignX = "center";
		self.spawnMsg.alignY = "middle";
		self.spawnMsg.x = 305;
		self.spawnMsg.y = 140;
		self.spawnMsg.fontScale = 1.5;
	}
	self.spawnMsg setText(&"BEL_TIME_TILL_SPAWN");

	if (!isdefined(self.spawnTimer))
	{
		self.spawnTimer = newClientHudElem(self);
		self.spawnTimer.alignX = "center";
		self.spawnTimer.alignY = "middle";
		self.spawnTimer.x = 305;
		self.spawnTimer.y = 155;
		self.spawnTimer.fontScale = 1.5;
	}
	self.spawnTimer setTimer(respawntime);

	self thread Respawn_HUD_Timer_Cleanup_Wait("respawn");
	self thread Respawn_HUD_Timer_Cleanup_Wait("end_respawn");
	self thread Respawn_HUD_Timer_Cleanup();

	wait (respawntime);

	self notify("do_timer_cleanup");
	self.spawnMsg setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
}

Respawn_HUD_NoTimer()
{
	self endon ("respawn");
	self endon ("end_respawn");

	wait .1;
	if (!isdefined(self.spawnMsg))
	{
		self.spawnMsg = newClientHudElem(self);
		self.spawnMsg.alignX = "center";
		self.spawnMsg.alignY = "middle";
		self.spawnMsg.x = 305;
		self.spawnMsg.y = 140;
		self.spawnMsg.fontScale = 1.5;
	}
	self.spawnMsg setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
}

waitForceRespawnTime()
{
	self endon("end_respawn");
	self endon("respawn");

	self.respawnwait = true;
	self thread Respawn_HUD_Timer();
	wait getcvarint("scr_bel_respawndelay");
	self thread waitForceRespawnButton();
}

waitForceRespawnButton()
{
	self endon("end_respawn");
	self endon("respawn");

	while(self useButtonPressed() != true)
		wait .05;

	self notify("respawn");
}


CheckAllies_andMoveAxis_to_Allies(playertomove, playernottomove)
{
	numOnTeam["allies"] = 0;
	numOnTeam["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "allies")
		{
			alliedplayers = [];
			alliedplayers[alliedplayers.size] = players[i];
			numOnTeam["allies"]++;
		}
		else if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "axis")
		{
			axisplayers = [];
			axisplayers[axisplayers.size] = players[i];
			numOnTeam["axis"]++;
		}
	}

	Set_Number_Allowed_Allies(numOnTeam["axis"]);

	if (numOnTeam["allies"] == level.alliesallowed)
		return;

	if (numOnTeam["allies"] < level.alliesallowed)
	{
		if ( (isdefined (playertomove)) && (playertomove.pers["team"] != "allies") )
		{
			playertomove move_to_allies(undefined, undefined, undefined, 2);
			if(!isDefined(playertomove.blackscreen))
				playertomove blackscreen(2);
		}
		else if (isdefined (playernottomove))
			move_random_axis_to_allied(playernottomove);
		else
			move_random_axis_to_allied();

		if (level.alliesallowed > 1)
			iprintln(&"BEL_ADDING_ALLIED");

		return;
	}

	if (numOnTeam["allies"] > (level.alliesallowed + 1))
	{
		move_random_allied_to_axis();
		iprintln(&"BEL_REMOVING_ALLIED");
		return;
	}
	if ( (numOnTeam["allies"] > level.alliesallowed) && (level.alliesallowed == 1) )
	{
		move_random_allied_to_axis();
		iprintln(&"BEL_REMOVING_ALLIED");
		return;
	}
}

Set_Number_Allowed_Allies(axis)
{
	if(axis > 48)
		level.alliesallowed = 16;
	else if(axis > 45)
		level.alliesallowed = 15;
	else if(axis > 42)
		level.alliesallowed = 14;
	else if(axis > 39)
		level.alliesallowed = 13;
	else if(axis > 36)
		level.alliesallowed = 12;
	else if(axis > 30)
		level.alliesallowed = 11;
	else if (axis > 27)
		level.alliesallowed = 10;
	else if (axis > 24)
		level.alliesallowed = 9;
	else if (axis > 21)
		level.alliesallowed = 8;
	else if (axis > 18)
		level.alliesallowed = 7;
	else if (axis > 15)
		level.alliesallowed = 6;
	else if (axis > 12)
		level.alliesallowed = 5;
	else if (axis > 9)
		level.alliesallowed = 4;
	else if (axis > 6)
		level.alliesallowed = 3;
	else if (axis > 3)
		level.alliesallowed = 2;
	else
		level.alliesallowed = 1;
}

move_random_axis_to_allied(playernottoinclude)
{
	candidates = [];
	axisplayers = [];
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "axis")
		{
			axisplayers[axisplayers.size] = players[i];
			if ( (isdefined (playernottoinclude)) && (playernottoinclude == players[i]) )
				continue;
			candidates[candidates.size] = players[i];
		}
	}
	if (axisplayers.size == 1)
	{
		num = randomint(axisplayers.size);
		iprintln(&"BEL_IS_NOW_ALLIED",axisplayers[num]);
		axisplayers[num] move_to_allies(undefined, undefined, undefined, 2);
		if(!isDefined(axisplayers[num].blackscreen))
			axisplayers[num] blackscreen(2);
	}
	else if (axisplayers.size > 1)
	{
		if (candidates.size > 0)
		{
			num = randomint(candidates.size);
			iprintln(&"BEL_IS_NOW_ALLIED",candidates[num]);
			candidates[num] move_to_allies(undefined, undefined, undefined, 2);
			if(!isDefined(candidates[num].blackscreen))
				candidates[num] blackscreen(2);
			return;
		}
		else
		{
			num = randomint(axisplayers.size);
			iprintln(&"BEL_IS_NOW_ALLIED",axisplayers[num]);
			axisplayers[num] move_to_allies(undefined, undefined, undefined, 2);
			if(!isDefined(axisplayers[num].blackscreen))
				axisplayers[num] blackscreen(2);
			return;
		}
	}
}

move_random_allied_to_axis()
{
	numOnTeam["allies"] = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "allies")
		{
			alliedplayers = [];
			alliedplayers[alliedplayers.size] = players[i];
			numOnTeam["allies"]++;
		}
	}
	if (numOnTeam["allies"] > 0)
	{
		num = randomint(alliedplayers.size);
		iprintln(&"BEL_MOVED_TO_AXIS",alliedplayers[num]);
		alliedplayers[num] move_to_axis();
	}
}

move_to_axis(delay, respawnoption)
{
	if (isplayer (self))
	{
		self check_delete_objective();
		self.pers["nextWeapon"] = undefined;
		//self.pers["lastweapon1"] = undefined;
		//self.pers["lastweapon2"] = undefined;
		self.pers["savedmodel"] = undefined;
		self.pers["team"] = "axis";
		self.sessionteam = "axis";

		if (isdefined (delay))
			wait delay;

		if (isplayer (self))
		{
			if (!isdefined (self.pers["LastAxisWeapon"]))
			{
				self [[ level.gtd_call ]]( "gt_spawnSpectator" );

				self setClientCvar(level.ui_weapontab, "1");
				self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis_only"]);
				self openMenu(game["menu_weapon_axis_only"]);
			}
			else
			{
				self setClientCvar(level.ui_weapontab, "1");
				self setClientCvar("g_scriptMainMenu", game["menu_weapon_all"]);

				if ( (isdefined (delay)) && (isdefined (respawnoption)) && (respawnoption == "nodelay on respawn") )
					self thread [[ level.gtd_call ]]( "gt_respawn", "auto",0);
				else
					self thread [[ level.gtd_call ]]( "gt_respawn", "auto");
			}
		}
	}
}

move_to_allies(nospawn, delay, respawnoption, blackscreen)
{
	if (isplayer (self))
	{
		self.god = true;
		self.pers["team"] = "allies";
		self.sessionteam = "allies";
		//self.lastteam = "allies";
		self.pers["nextWeapon"] = undefined;
		//self.pers["lastweapon1"] = undefined;
		//self.pers["lastweapon2"] = undefined;
		self.pers["savedmodel"] = undefined;

		if (isdefined (delay))
		{
			if (blackscreen == 1)
			{
				if (!isdefined (self.blackscreen))
					self blackscreen();
			}
			else if (blackscreen == 2)
			{
				if (!isdefined (self.blackscreen))
					self blackscreen(2);
			}
			wait 2;
		}

		if (isplayer (self))
		{
			if (!isdefined (self.pers["LastAlliedWeapon"]))
			{
				self [[ level.gtd_call ]]( "gt_spawnSpectator" );

				self setClientCvar(level.ui_weapontab, "1");
				self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies_only"]);
				self openMenu(game["menu_weapon_allies_only"]);

				self thread auto_giveweapon_allied();
				return;
			}
			else
			{
				self setClientCvar(level.ui_weapontab, "1");
				self setClientCvar("g_scriptMainMenu", game["menu_weapon_all"]);

				if ( (isdefined (delay)) && (isdefined (respawnoption)) && (respawnoption == "nodelay on respawn") )
					self thread [[ level.gtd_call ]]( "gt_respawn", "auto",0);
				else
					self thread [[ level.gtd_call ]]( "gt_respawn", "auto");
			}
		}
		else
		{
			self.god = false;
		}
	}
}

allied_hud_element()
{
	wait .1;

	if (!isdefined(self.hud_bgnd))
	{
		self.hud_bgnd = newClientHudElem(self);
		self.hud_bgnd.alpha = 0.2;
		self.hud_bgnd.x = 505;
		self.hud_bgnd.y = 382;
		self.hud_bgnd.sort = -1;
		self.hud_bgnd setShader("black", 130, 35);
	}

	if (!isdefined(self.hud_clock))
	{
		self.hud_clock = newClientHudElem(self);
		self.hud_clock.alignx = "right";
		self.hud_clock.x = 620;
		self.hud_clock.y = 385;
		self.hud_clock.label = &"BEL_TIME_ALIVE";
	}
	self.hud_clock setTimerUp(0);

	if (!isdefined(self.hud_points))
	{
		self.hud_points = newClientHudElem(self);
		self.hud_points.alignx = "right";
		self.hud_points.x = 620;
		self.hud_points.y = 401;
		self.hud_points.label = &"BEL_POINTS_EARNED";
		self.hud_points setValue(1);
	}

	self thread give_allied_points();
}

check_delete_objective()
{
	if (isdefined(self.hud_points))
		self.hud_points destroy();
	if (isdefined(self.hud_clock))
		self.hud_clock destroy();
	if (isdefined(self.hud_bgnd))
		self.hud_bgnd destroy();

	self notify ("Stop Blip");
	//objnum = ((self getEntityNumber()) + 1);
	if (isdefined (self.objnum))
	{
		objective_delete(self.objnum);
		level.objused[(self.objnum - 1)] = false;
		self.objnum = undefined;
	}
}

make_obj_marker()
{
	level endon ("end_map");
	self endon ("Stop Blip");
	self endon ("death");
	count1 = 1;
	count2 = 1;

	if(getcvar("scr_bel_showoncompass") == "1")
	{
		//objnum = ((self getEntityNumber()) + 1);
		objnum = GetNextObjNum();
		self.objnum = objnum;
		objective_add(objnum, "current", self.origin, "gfx/hud/hud@objective_bel.tga");
		objective_icon(objnum,"gfx/hud/hud@objective_bel.tga");
		objective_team(objnum,"axis");
		objective_position(objnum, self.origin);
		lastobjpos = self.origin;
		newobjpos = self.origin;
	}
	self.pers[ "score" ]++;
	self.score = self.pers[	"score"	];
	self [[ level.gtd_call ]]( "checkScoreLimit", "gt_playerScoreLimit" );

	self thread allied_hud_element();

	while ((isplayer (self)) && (isalive(self)))
	{
		wait( 1 );

		if (self.health < 100)
			self.health = (self.health + 3);

		if ( count1 < level.PositionUpdateTime )
			count1++;
		else
		{
			count1 = 1;
			if(getcvar("scr_bel_showoncompass") == "1")
			{
				lastobjpos = newobjpos;
				newobjpos = ( ((lastobjpos[0] + self.origin[0]) * 0.5), ((lastobjpos[1] + self.origin[1]) * 0.5), ((lastobjpos[2] + self.origin[2]) * 0.5) );
				objective_position(objnum, newobjpos);
			}
		}
	}
}

give_allied_points()
{
	level endon ("end_map");
	self endon ("Stop give points");
	self endon ("Stop Blip");
	self endon ("death");

	PointsEarned = 1;
	while ((isplayer (self)) && (isalive(self)))
	{
		wait level.AlivePointTime;
		self.pers[ "score" ]++;
		self.score = self.pers[	"score"	];
		PointsEarned++;
		self.god = false; //failsafe to fix a very rare bug
		[[ level.gtd_call ]]( "logPrint", "action", self, "allies", self.name, "bel_alive_tick" );
		self.hud_points setValue(PointsEarned);
		self [[ level.gtd_call ]]( "checkScoreLimit",
						"gt_playerScoreLimit" );
	}
}

auto_giveweapon_allied()
{
	self endon ("end_respawn");
	self endon ("stop weapon timeout");

	wait 6;
	if ( (isplayer (self)) && (self.sessionstate == "spectator") )
	{
		self notify("end_respawn");

		switch(game["allies"])
		{
			case "american":
				self.pers["weapon"] = "m1garand_mp";
				break;
			case "british":
				self.pers["weapon"] = "enfield_mp";
				break;
			case "russian":
				self.pers["weapon"] = "mosin_nagant_mp";
				break;
		}
		self.pers["LastAlliedWeapon"] = self.pers["weapon"];
		self closeMenu();
		self thread [[ level.gtd_call ]]( "gt_respawn", "auto");
	}
}

blackscreen(didntkill)
{
	if (!isdefined (didntkill))
	{
		self.blackscreentext = newClientHudElem(self);
		self.blackscreentext.sort = -1;
		self.blackscreentext.archived = false;
		self.blackscreentext.alignX = "center";
		self.blackscreentext.alignY = "middle";
		self.blackscreentext.x = 320;
		self.blackscreentext.y = 220;
		self.blackscreentext settext (&"BEL_BLACKSCREEN_KILLEDALLIED");
	}

	self.blackscreentext2 = newClientHudElem(self);
	self.blackscreentext2.sort = -1;
	self.blackscreentext2.archived = false;
	self.blackscreentext2.alignX = "center";
	self.blackscreentext2.alignY = "middle";
	self.blackscreentext2.x = 320;
	self.blackscreentext2.y = 240;
	self.blackscreentext2 settext (&"BEL_BLACKSCREEN_WILLSPAWN");

	self.blackscreentimer = newClientHudElem(self);
	self.blackscreentimer.sort = -1;
	self.blackscreentimer.archived = false;
	self.blackscreentimer.alignX = "center";
	self.blackscreentimer.alignY = "middle";
	self.blackscreentimer.x = 320;
	self.blackscreentimer.y = 260;
	self.blackscreentimer settimer (2);

	self.blackscreen = newClientHudElem(self);
	self.blackscreen.sort = -2;
	self.blackscreen.archived = false;
	self.blackscreen.alignX = "left";
	self.blackscreen.alignY = "top";
	self.blackscreen.x = 0;
	self.blackscreen.y = 0;
	self.blackscreen.alpha = 1;
	self.blackscreen setShader("black", 640, 480);
	if (!isdefined (didntkill))
	{
		self.blackscreen.alpha = 0;
		self.blackscreen fadeOverTime(1.5);
	}
	self.blackscreen.alpha = 1;

	//level thread remove_blackscreen(self);
}
/*
remove_blackscreen(player)
{
	wait 4;
	if(isDefined(player))
	{
		if ( (isalive (player)) && (player.pers["team"] == "axis") )
		{
			if(isDefined(player.blackscreen))
				player.blackscreen destroy();
			if(isDefined(player.blackscreentext))
				player.blackscreentext destroy();
			if(isDefined(player.blackscreentext2))
				player.blackscreentext2 destroy();
			if(isDefined(player.blackscreentimer))
				player.blackscreentimer destroy();
		}
	}
}
*/
Number_On_Team(team)
{
	players = getentarray("player", "classname");

	if (team == "axis")
	{
		numOnTeam["axis"] = 0;
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "axis")
				numOnTeam["axis"]++;
		}
		return numOnTeam["axis"];
	}
	else if (team == "allies")
	{
		numOnTeam["allies"] = 0;
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == "allies")
				numOnTeam["allies"]++;
		}
		return numOnTeam["allies"];
	}
}

updateDeathArray()
{
	if(!isdefined(level.deatharray))
	{
		level.deatharray[0] = self.origin;
		level.deatharraycurrent = 1;
		return;
	}

	if(level.deatharraycurrent < 4)
		level.deatharray[level.deatharraycurrent] = self.origin;
	else
	{
		level.deatharray[0] = self.origin;
		level.deatharraycurrent = 1;
		return;
	}

	level.deatharraycurrent++;
}

client_print(text)
{
	self notify ("stop client print");
	self endon ("stop client print");

	if (!isdefined(self.print))
	{
		self.print = newClientHudElem(self);
		self.print.alignX = "center";
		self.print.alignY = "middle";
		self.print.x = 320;
		self.print.y = 176;
	}
	self.print.alpha = 1;
	self.print setText(text);

	wait 3;
	self.print.alpha = .9;
	wait .9;
	self.print destroy();
}

