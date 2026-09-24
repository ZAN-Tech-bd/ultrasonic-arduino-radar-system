# Ultrasonic Arduino Radar System

A mini radar built from an Arduino, a servo motor, and an HC-SR04 ultrasonic sensor. The servo sweeps the sensor back and forth, the Arduino streams angle and distance readings over USB, and a Processing sketch draws a live radar screen that marks detected objects in red.

## How It Works

1. **Servo motor** rotates the sensor from 15° to 165° and back.
2. **Ultrasonic sensor** sends a sound pulse (Trig) and times how long the echo takes to return (Echo). Distance is calculated from the speed of sound:

   ```
   distance (cm) = duration (µs) × 0.034 / 2
   ```

3. **Arduino** sends each reading over serial as `angle,distance.` (for example `45,12.`).
4. **Processing** reads the data and draws the sweep line, marking any object closer than 40 cm in red.

## Components

| Component                          | Qty | Purpose                            |
| ---------------------------------- | --- | ---------------------------------- |
| Arduino Uno (or compatible)        | 1   | Main controller                    |
| HC-SR04 ultrasonic sensor          | 1   | Measures distance                  |
| SG90 micro servo motor             | 1   | Sweeps the sensor left and right   |
| Breadboard                         | 1   | Solderless wiring                  |
| Jumper wires                       | ~10 | Connections                        |
| USB Type-A to Type-B cable         | 1   | Connects the Arduino to a computer |

## Software

- [Arduino IDE](https://www.arduino.cc/en/software) — uploads code to the board
- [Processing](https://processing.org/download) — runs the radar display

## Wiring

![Ultrasonic Arduino Radar System pictorial wiring diagram](<Ultrasonic Arduino Radar System pictorial wiring diagram.png>)

**HC-SR04 ultrasonic sensor**

| Sensor pin | Arduino pin |
| ---------- | ----------- |
| VCC        | 5V          |
| GND        | GND         |
| Trig       | D8          |
| Echo       | D9          |

**SG90 servo motor**

| Servo wire               | Arduino pin                                   |
| ------------------------ | --------------------------------------------- |
| Red (power)              | 5V (or an external 5V supply if it stutters) |
| Brown / black (ground)   | GND                                           |
| Yellow / orange (signal) | D11                                           |

> **Tip:** Mount the sensor on the servo horn with tape, glue, or a 3D-printed bracket so it turns with the motor.

## Project Structure

```
ultrasonic-arduino-radar-system/
├── ultrasonic_radar.ino   # Arduino sketch: servo sweep + distance measurement
├── radar_display.pde      # Processing sketch: radar display
├── Ultrasonic Arduino Radar System pictorial wiring diagram.png  # Wiring diagram
├── LICENSE
└── README.md
```

> Both the Arduino IDE and Processing expect a sketch to live in a folder with the same name. If an IDE asks to create a folder when you open a file, click **OK**.

## Code Overview

### `ultrasonic_radar.ino` (Arduino)

- `calculateDistance()` sends a 10 µs trigger pulse, measures the echo with `pulseIn()`, and converts it to centimeters.
- `setup()` configures the sensor pins, attaches the servo to pin 11, and starts serial at 9600 baud.
- `loop()` sweeps 15° → 165° → 15°, printing `angle,distance.` at each step.

### `radar_display.pde` (Processing)

- `serialEvent()` buffers input until `.`, then splits it into angle and distance.
- `drawRadar()` draws the range arcs (10–40 cm) and angle guides.
- `drawLine()` draws the green sweep line at the current angle.
- `drawObject()` draws a red marker when an object is within 40 cm, converting polar coordinates to screen positions with `x = r·cos(θ)`, `y = −r·sin(θ)`.
- `drawText()` shows the angle, distance, and range labels.

## Getting Started

1. **Wire the hardware** as shown above.
2. **Upload the Arduino sketch**
   - Open `ultrasonic_radar.ino` in the Arduino IDE.
   - Select **Tools → Board → Arduino Uno** and your port under **Tools → Port**.
   - Click **Upload**.
3. **Run the radar display**
   - Open `radar_display.pde` in Processing.
   - On line 33, change `"COM7"` to your Arduino's port (for example `"COM3"` on Windows, or `"/dev/cu.usbmodem..."` on macOS):

     ```java
     myPort = new Serial(this, "COM7", 9600);
     ```

   - Close the Arduino Serial Monitor (only one program can use the port at a time).
   - Click **Run**.

## Troubleshooting

| Problem                                    | Fix                                                                                                                  |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Radar screen is blank / sweep doesn't move | Close the Arduino Serial Monitor before starting Processing.                                                        |
| "Port not available" in Processing         | Check the port in Device Manager or the Arduino IDE and update line 33 of `radar_display.pde`.                      |
| Servo jitters or the Arduino resets        | Power the servo from an external 5V supply or battery pack, and connect all grounds together.                       |

## License

Copyright © 2026 ZAN Tech. Released under the [MIT License](LICENSE).
