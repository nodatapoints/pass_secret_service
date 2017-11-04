#!/usr/bin/env python3

import unittest
import pydbus
from gi.repository import GLib
from common.names import bus_name, base_path

class TestSession(unittest.TestCase):
    def setUp(self):
        self.bus = pydbus.SessionBus()
        self.service = self.bus.get(bus_name)

    def test_session_plain(self):
        output, session_path = self.service.OpenSession('plain', GLib.Variant('s', ''))
        session = self.bus.get(bus_name, session_path)
        session.Close()

    def test_session_error(self):
        with self.assertRaises(GLib.GError):
            output, session_path = self.service.OpenSession('wrong plain', GLib.Variant('s', ''))

if __name__ == "__main__":
    unittest.main()

#  vim: set tw=160 sts=4 ts=8 sw=4 ft=python et noro norl cin si ai :
