# This file is part of Gajim.
#
# SPDX-License-Identifier: GPL-3.0-only

from unittest.mock import MagicMock

from gajim.common.client_connectivity import check_client_connectivity


class LegacyNbxmppClient:
    pass


def test_network_status_changed_falls_back_for_legacy_nbxmpp() -> None:
    reconnect = MagicMock()
    is_reachable = MagicMock(return_value=False)

    check_client_connectivity(LegacyNbxmppClient(), reconnect, is_reachable)

    is_reachable.assert_called_once_with()
    reconnect.assert_called_once_with()


def test_network_status_changed_uses_nbxmpp_connectivity_check() -> None:
    client = MagicMock()
    reconnect = MagicMock()
    is_reachable = MagicMock()

    check_client_connectivity(client, reconnect, is_reachable)

    client.check_if_connected.assert_called_once_with()
    is_reachable.assert_not_called()
    reconnect.assert_not_called()
