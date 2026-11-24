# EfficientSensorDisplays

Reworks text and equipment sensors to use multiple threads to reduce the time taken per frame.

> [!WARNING]
> This mod relies on a feature not currently in stable releases.
> As a result, this requires the latest bleeding-edge build.

Fully configurable in the config menu to change how much the HUD updates:
- Sensor tick rate (hz) -> How many times the HUD runs the sensor update poll
- Packet count -> How many batches the sensors should be split into, with one batch processed per update poll.
- Only update valid sensor outputs -> Doesn't update sensors if their output is invalid.

Highly granularity for update rate: Ranges from 225 times slower to 4 times faster than the Vanilla update rate through a mix of the mod's configs.

Does not currently support: LIDAR, cargo scanner (both on-board and remote), autopilot overlay, manual vector display, and OMS system display.