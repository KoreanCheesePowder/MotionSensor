C.P MotionSensor v1.0.9

Author: CheesePowder
Version: v1.0.9
Package key: cheesepowder.ewelink-ms01-motion

Default settings
- Detection hold time: 60 seconds
- Inactive lock time: 0 seconds
- Extend active timer on motion: On
- Experimental hardware writes: Off
- Hardware interval: 60 / DP 102 (0x66)
- Hardware sensitivity: 2 / DP 10 (0x0A)
- Hardware mode: 1 / DP 9 (0x09)
- Lux threshold: 100 / DP 4 (0x04)

[v1.0.9]
- Inactive lock can be set to 0 seconds.
- A 0-second inactive lock immediately allows the next hardware motion report.
- Default software Active hold changed to 60 seconds to match the observed DP 0x66 value.
- DP 0x09 is treated as an Enum hardware mode, not a 60-second duration.
- Experimental DP write logs now show outgoing writes and matching read-back confirmation.
- Experimental hardware writes remain OFF by default.

Important
- DP meanings are based on observed device reports and are still experimental.
- The physical sensor may not transmit another motion report until its own hardware interval expires.
