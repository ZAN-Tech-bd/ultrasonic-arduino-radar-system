/*
  File: radar_display.pde
  Repository: ultrasonic-arduino-radar-system
  Description: Processing IDE script that creates a 2D visual radar display interface.
               It listens to incoming Serial data (Angle, Distance) from the Arduino 
               and renders arc grids, sweeping indicator lines, and detected obstacles.
*/

import processing.serial.*;       // Library for serial communication with Arduino
import java.awt.event.KeyEvent;   // Library for handling key events
import java.io.IOException;

// Serial Communication Objects and Variables
Serial myPort;                    // Serial port object
String angle = "";
String distance = "";
String data = "";
String noObject;

// Coordinate and Angle Calculation Variables
float pixsDistance;
int iAngle, iDistance;
int index1 = 0;
int index2 = 0;
PFont orcFont;

void setup() {
  // Set canvas size (Width: 1200px, Height: 700px)
  size(1200, 700); 
  smooth(); // Enable anti-aliasing for smooth rendering
  
  // Open Serial port communication (Adjust "COM7" to match your Arduino port)
  myPort = new Serial(this, "COM7", 9600); 
  
  // Buffer serial incoming bytes until the termination character '.' is encountered
  myPort.bufferUntil('.'); 
}

void draw() {
  // Set default fill color (Radar Neon Green)
  fill(98, 245, 31);
  
  // Create motion blur effect: draw a translucent black rectangle over previous frame
  noStroke();
  fill(0, 4); 
  rect(0, 0, width, height - height * 0.065); 

  // Re-establish primary drawing color
  fill(98, 245, 31); 
  
  // Render radar visual components frame-by-frame
  drawRadar();  // Background arc grid and angle lines
  drawLine();   // Sweeping sweep line
  drawObject(); // Detected red obstacle indicators
  drawText();   // On-screen telemetry (Angle, Distance, Scale labels)
}

// Automatically triggered whenever new serial data ending with '.' arrives
void serialEvent(Serial myPort) { 
  // Read string up to '.' character and trim off the '.'
  data = myPort.readStringUntil('.');
  data = data.substring(0, data.length() - 1);

  // Locate comma delimiter separating angle and distance ("angle,distance")
  index1 = data.indexOf(","); 
  
  // Extract substrings
  angle = data.substring(0, index1); 
  distance = data.substring(index1 + 1, data.length()); 

  // Convert string values to integer primitives
  iAngle = int(angle);
  iDistance = int(distance);
}

// Draws the static radar grid, radial arcs, and angular guide lines
void drawRadar() {
  pushMatrix();
  // Relocate origin (0,0) to bottom-center of canvas
  translate(width / 2, height - height * 0.074); 
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // Draw concentric range arcs (10cm, 20cm, 30cm, 40cm indicators)
  arc(0, 0, (width - width * 0.0625), (width - width * 0.0625), PI, TWO_PI);
  arc(0, 0, (width - width * 0.27), (width - width * 0.27), PI, TWO_PI);
  arc(0, 0, (width - width * 0.479), (width - width * 0.479), PI, TWO_PI);
  arc(0, 0, (width - width * 0.687), (width - width * 0.687), PI, TWO_PI);
  
  // Draw degree reference vectors (0°, 30°, 60°, 90°, 120°, 150°, 180°)
  line(-width / 2, 0, width / 2, 0);
  line(0, 0, (-width / 2) * cos(radians(30)), (-width / 2) * sin(radians(30)));
  line(0, 0, (-width / 2) * cos(radians(60)), (-width / 2) * sin(radians(60)));
  line(0, 0, (-width / 2) * cos(radians(90)), (-width / 2) * sin(radians(90)));
  line(0, 0, (-width / 2) * cos(radians(120)), (-width / 2) * sin(radians(120)));
  line(0, 0, (-width / 2) * cos(radians(150)), (-width / 2) * sin(radians(150)));
  line((-width / 2) * cos(radians(30)), 0, width / 2, 0);
  popMatrix();
}

// Renders red obstacle lines when an object is detected within 40 cm
void drawObject() {
  pushMatrix();
  // Relocate origin to bottom-center
  translate(width / 2, height - height * 0.074); 
  strokeWeight(9);
  stroke(255, 10, 10); // Bright Red
  
  // Scale distance from centimeters to canvas pixel units
  pixsDistance = iDistance * ((height - height * 0.1666) * 0.025); 
  
  // Render obstacle beam if distance is within active range (< 40 cm)
  if (iDistance < 40) {
    line(
      pixsDistance * cos(radians(iAngle)), 
      -pixsDistance * sin(radians(iAngle)), 
      (width - width * 0.505) * cos(radians(iAngle)), 
      -(width - width * 0.505) * sin(radians(iAngle))
    );
  }
  popMatrix();
}

// Draws the active green sweep line matching current servo angle
void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60); // Bright Green Sweep Line
  translate(width / 2, height - height * 0.074); 
  
  // Draw vector line outward from origin along target angle
  line(0, 0, (height - height * 0.12) * cos(radians(iAngle)), -(height - height * 0.12) * sin(radians(iAngle))); 
  popMatrix();
}

// Draws UI text, scale metrics, angle values, and degree markers
void drawText() { 
  pushMatrix();
  
  // Check detection status
  if (iDistance > 40) {
    noObject = "Out of Range";
  } else {
    noObject = "In Range";
  }
  
  // Clear telemetry footer bar with black background
  fill(0, 0, 0);
  noStroke();
  rect(0, height - height * 0.0648, width, height);
  
  // Render range labels (10cm to 40cm)
  fill(98, 245, 31);
  textSize(25);
  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);
  
  // Render telemetry readout at bottom left / center
  textSize(40);
  text("N_Tech ", width - width * 0.875, height - height * 0.0277);
  text("Angle: " + iAngle + "°", width - width * 0.48, height - height * 0.0277);
  text("Distance: ", width - width * 0.26, height - height * 0.0277);
  
  if (iDistance < 40) {
    text("        " + iDistance + " cm", width - width * 0.225, height - height * 0.0277);
  }
  
  // Draw rotated angle degree numbers (30°, 60°, 90°, 120°, 150°) along arc perimeter
  textSize(25);
  fill(98, 245, 60);
  
  translate((width - width * 0.4994) + width / 2 * cos(radians(30)), (height - height * 0.0907) - width / 2 * sin(radians(30)));
  rotate(-radians(-60));
  text("30", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.503) + width / 2 * cos(radians(60)), (height - height * 0.0888) - width / 2 * sin(radians(60)));
  rotate(-radians(-30));
  text("60", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.507) + width / 2 * cos(radians(90)), (height - height * 0.0833) - width / 2 * sin(radians(90)));
  rotate(radians(0));
  text("90", 0, 0);
  resetMatrix();
  
  translate(width - width * 0.513 + width / 2 * cos(radians(120)), (height - height * 0.07129) - width / 2 * sin(radians(120)));
  rotate(radians(-30));
  text("120", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.5104) + width / 2 * cos(radians(150)), (height - height * 0.0574) - width / 2 * sin(radians(150)));
  rotate(radians(-60));
  text("150", 0, 0);
  
  popMatrix();
}