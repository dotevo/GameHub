/*
This file is part of GameHub.
Copyright (C) 2018-2019 Anatoliy Kashkin

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

using Gtk;

using GameHub.Utils;
using GameHub.UI.Widgets;

namespace GameHub.UI.Dialogs.SettingsDialog.Pages.Sources
{
	public class EpicGames: SettingsDialogPage
	{
		private Settings.Auth.Epic epic_auth;
		private FileChooserEntry games_dir_chooser;

		public EpicGames(SettingsDialog dlg)
		{
			Object(
				dialog: dlg,
				title: "EpicGames",
				description: _("Disabled"),
				icon_name: "source-epicgames-symbolic",
				activatable: true
			);
			status = description;
		}

		construct
		{
			var paths = FSUtils.Paths.Settings.instance;
			epic_auth = Settings.Auth.Epic.instance;

			games_dir_chooser = add_file_chooser(_("Games directory"), FileChooserAction.SELECT_FOLDER, paths.epic_games, v => { paths.epic_games = v; request_restart(); update(); }).get_children().last().data as FileChooserEntry;

			add_separator();

			//add_apikey_entry();
			//add_link(_("Generate key"), "https://itch.io/api-keys");

			add_separator();

			status_switch.active = epic_auth.enabled;
			status_switch.notify["active"].connect(() => {
				epic_auth.enabled = status_switch.active;
				update();
				request_restart();
			});



			update();
		}

		private void update()
		{
			var epic = GameHub.Data.Sources.EpicGames.EpicGames.instance;

			content_area.sensitive = epic.enabled;

			if(!epic.enabled)
			{
				status = description = _("Disabled");
			}
			else if(!epic.is_installed())
			{
				status = description = _("Missing Legendary");
			}
			else if(!epic.is_authenticated())
			{
				status = description = _("Not authenticated");
			}
			else
			{
				status = description = epic.user_name != null ? _("Authenticated as <b>%s</b>").printf(epic.user_name) : _("Authenticated");
			}

		}

	}
}
