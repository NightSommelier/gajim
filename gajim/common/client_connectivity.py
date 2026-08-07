# This file is part of Gajim.
#
# SPDX-License-Identifier: GPL-3.0-only

from collections.abc import Callable
from typing import Any


def check_client_connectivity(
    client: Any, reconnect: Callable[[], None]
) -> None:
    check_if_connected = getattr(client, "check_if_connected", None)
    if check_if_connected is not None:
        check_if_connected()
        return

    reconnect()
