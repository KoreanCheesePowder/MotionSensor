C.P MotionSensor v1.0.4

Author: CheesePowder
Version: v1.0.4
Package key: cheesepowder.ewelink-ms01-motion

Settings
- Detection interval: 0.1 to 3600 seconds
- Inactive interval: 0.1 to 3600 seconds
- Extend inactive timer on motion: On/Off

Behavior
- Detection interval is a software debounce interval for incoming motion reports.
- It cannot make the physical sensor transmit faster than its hardware allows.
- With extension enabled, every accepted motion report restarts the inactive timer.
- With extension disabled, the timer started by the first motion report is not extended.

Install
1. Extract the ZIP.
2. Run SETUP-AND-INSTALL.cmd.
