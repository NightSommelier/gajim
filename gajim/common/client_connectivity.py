# This file is part of Gajim.
#
# SPDX-License-Identifier: GPL-3.0-only

from typing import Any

from collections.abc import Callable


def check_client_connectivity(
    client: Any,
    reconnect: Callable[[], None],
    is_reachable: Callable[[], bool],
) -> None:
    check_if_connected = getattr(client, "check_if_connected", None)
    if check_if_connected is not None:
        check_if_connected()
        return

    if not is_reachable():
        reconnect()
