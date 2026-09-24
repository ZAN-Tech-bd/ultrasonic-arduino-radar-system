/*
  File: ultrasonic_radar.ino
  Repository: ultrasonic-arduino-radar-system
  Description: Sweeps an HC-SR04 ultrasonic sensor using a servo motor (15° to 165°)
               and transmits angle and distance data via Serial.
*/

#include <Servo.h>

// Hardware Pin Definitions
#define trigPin 8 // Trigger pin on HC-SR04 ultrasonic sensor
#define echoPin 9 // Echo pin on HC-SR04 ultrasonic sensor

// Global Variables
long duration; // Time taken for ultrasonic pulse to bounce back (in microseconds)
int distance;  // Calculated distance in centimeters

// Servo Object Initialization
Servo myservo;

// Helper function to measure distance using the HC-SR04 sensor
int calculateDistance()
{
    // Clear the trigger pin to ensure a clean HIGH pulse
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);

    // Transmit a 10-microsecond HIGH pulse to trigger the ultrasonic burst
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);

    // Measure the duration (in microseconds) for the echo signal to return
    duration = pulseIn(echoPin, HIGH);

    // Calculate distance in centimeters:
    // Speed of sound = 340 m/s = 0.034 cm/us. Distance = (time * speed) / 2 (for round trip)
    distance = duration * 0.034 / 2;

    return distance;
}

void setup()
{
    // Set pin modes for the ultrasonic sensor
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);

    // Attach the servo motor control pin to digital pin 11
    myservo.attach(11);

    // Initialize Serial Communication at 9600 baud rate (used for radar UI e.g., Processing)
    Serial.begin(9600);
}

void loop()
{
    int i;

    // Sweep the servo from 15 degrees to 165 degrees (Forward Sweep)
    for (i = 15; i <= 165; i++)
    {
        myservo.write(i);    // Move servo to position 'i'
        delay(15);           // Pause to allow servo to reach position
        calculateDistance(); // Measure object distance at current angle

        // Output formatted string: "angle,distance." (e.g., "90,25.")
        Serial.print(i);
        Serial.print(",");
        Serial.print(distance);
        Serial.print(".");
    }

    // Sweep the servo back from 165 degrees to 15 degrees (Reverse Sweep)
    for (i = 165; i >= 15; i--)
    {
        myservo.write(i);    // Move servo to position 'i'
        delay(15);           // Pause to allow servo to reach position
        calculateDistance(); // Measure object distance at current angle

        // Output formatted string: "angle,distance."
        Serial.print(i);
        Serial.print(",");
        Serial.print(distance);
        Serial.print(".");
    }
}