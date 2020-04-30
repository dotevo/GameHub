/*
This file is part of GameHub.
Copyright (C) 2018-2019 Anatoliy Kashkin
Copyright (C) 2020 Adam Jordanek

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gee;
using GameHub.Data.DB;
using GameHub.Utils;

namespace GameHub.Data.Sources.EpicGames
{
	public class EpicGamesGame: Game
	{
		public EpicGamesGame(EpicGames src, string nameP, string idP)
		{
			source = src;
			name = nameP;
			id = idP;
			icon = "";
			platforms.add(Platform.LINUX);

			install_dir = null;
			executable_path = "$game_dir/start.sh";
			work_dir_path = "$game_dir";
			info_detailed = @"{}";

			mount_overlays.begin();
			update_status();
		}

		public override void update_status()
		{
			var state = Game.State.UNINSTALLED;
			if (((EpicGames)source).legendary_wrapper.is_installed(id)) {
				state = Game.State.INSTALLED;
				debug ("New installed game: \tname = %s\t", name);
			} else {

				debug ("New not installed game: \tname = %s\t", name);
			}
			
			if(state == Game.State.INSTALLED)
			{
				remove_tag(Tables.Tags.BUILTIN_UNINSTALLED);
				add_tag(Tables.Tags.BUILTIN_INSTALLED);
			}
			else
			{
				add_tag(Tables.Tags.BUILTIN_UNINSTALLED);
				remove_tag(Tables.Tags.BUILTIN_INSTALLED);
			}
			status = new Game.Status(state, this);
		}

		public EpicGamesGame.from_db(EpicGames src, Sqlite.Statement s)
		{
			source = src;
			id = Tables.Games.ID.get(s);
			name = Tables.Games.NAME.get(s);
			info = Tables.Games.INFO.get(s);
			info_detailed = Tables.Games.INFO_DETAILED.get(s);
			icon = Tables.Games.ICON.get(s);
			image = Tables.Games.IMAGE.get(s);
			install_dir = Tables.Games.INSTALL_PATH.get(s) != null ? FSUtils.file(Tables.Games.INSTALL_PATH.get(s)) : null;
			executable_path = Tables.Games.EXECUTABLE.get(s);
			work_dir_path = Tables.Games.WORK_DIR.get(s);
			compat_tool = Tables.Games.COMPAT_TOOL.get(s);
			compat_tool_settings = Tables.Games.COMPAT_TOOL_SETTINGS.get(s);
			arguments = Tables.Games.ARGUMENTS.get(s);
			last_launch = Tables.Games.LAST_LAUNCH.get_int64(s);
			playtime_source = Tables.Games.PLAYTIME_SOURCE.get_int64(s);
			playtime_tracked = Tables.Games.PLAYTIME_TRACKED.get_int64(s);
			image_vertical = Tables.Games.IMAGE_VERTICAL.get(s);

			platforms.clear();
			var pls = Tables.Games.PLATFORMS.get(s).split(",");
			foreach(var pl in pls)
			{
				foreach(var p in Platform.PLATFORMS)
				{
					if(pl == p.id())
					{
						platforms.add(p);
						break;
					}
				}
			}
			update_status();
		}

		public override async void install(Runnable.Installer.InstallMode install_mode=Runnable.Installer.InstallMode.INTERACTIVE)
		{
			((EpicGames)source).legendary_wrapper.install(id);
			update_status();
		}
		public override async void uninstall()
		{
			((EpicGames)source).legendary_wrapper.uninstall(id);
			update_status();
		}

		public override async void run()
		{
			((EpicGames)source).legendary_wrapper.run(id);
		
		}

	}
}
