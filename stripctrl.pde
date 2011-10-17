/**
 * stripctrl - Simple Arduino sketch to accept commands to control a LPD8806 LED strip via Serial port
 * Author: Craig Calef <craig@dod.net>
 * This code is covered under the MIT License
 */
 
#include "LPD8806.h"
#include <SPI.h>

#define LEDCOUNT 32

/** Uncomment if using the Adafruit LPD8806 library that bit-bangs the serial protocol for the strip
int dataPin = 2;   
int clockPin = 3; 
LPD8806 strip = LPD8806(LEDCOUNT, dataPin, clockPin);
*/

// For cjbaar's deriviative LPD8806 library
LPD8806 strip = LPD8806(LEDCOUNT);

char sbuf[8] = {0, 0, 0, 0, 0, 0, 0, 0};
int si = 0;

void setup() {
  // Start up the LED strip
  strip.begin();
  Serial.begin(115200);
  Serial.println("START");
}


void loop() {
  char rb;
  int l = 0;
  int r = 0;
  int g = 0;
  int b = 0;
  
  if(Serial.available() > 0)
  { 
    rb = (char) Serial.read();
    //Serial.print(rb);

    if(rb == '\n' || rb == '\r')
    {
      // If we get FF then send the LED buffer to the strip.
      if (dhexchartoi(sbuf[0], sbuf[1]) == 255) 
      {
        strip.show();
        Serial.println("SHOWN");
      }
      
 #ifdef GETPXBUF_PATCH
      // If we get FF then print the strip buffer (for debugging)
      if (dhexchartoi(sbuf[0], sbuf[1]) == 254)
      {
        Serial.println("");
        for(int i = 0; i < strip.numPixels(); i++) 
        {
           Serial.print(strip.getPixelBuffer()[i*3], DEC);
           Serial.print(strip.getPixelBuffer()[i*3+1], DEC);
           Serial.println(strip.getPixelBuffer()[i*3+2], DEC);
        }
      }
 #endif
 
      if (dhexchartoi(sbuf[0], sbuf[1]) <= 32) {
        l = dhexchartoi(sbuf[0], sbuf[1]);
        r = dhexchartoi(sbuf[2], sbuf[3]);
        g = dhexchartoi(sbuf[4], sbuf[5]);
        b = dhexchartoi(sbuf[6], sbuf[7]);
        strip.setPixelColor(l, r, g, b);
        Serial.print("SETPIXEL ");
        Serial.print(l); Serial.print(" ");
        Serial.print(r); Serial.print(" ");
        Serial.print(g); Serial.print(" ");
        Serial.println(b);
      }
      si = 0;
    } else {
      if(si < 8)
      {
        sbuf[si] = rb;
        si++;
      } 
    }
  }
}

int dhexchartoi(char a, char b) {
  return (hexchartoi(a) << 4) + hexchartoi(b);
}

int hexchartoi(char a) {
  switch (a) {
    case '0': return 0;
    case '1': return 1;
    case '2': return 2;
    case '3': return 3;
    case '4': return 4;
    case '5': return 5;
    case '6': return 6;
    case '7': return 7;
    case '8': return 8;
    case '9': return 9;
    case 'A':
    case 'a': 
      return 10;
    case 'B': 
    case 'b':
      return 11;
    case 'C':
    case 'c': 
      return 12;
    case 'D':
    case 'd':
      return 13;    
    case 'E':
    case 'e':
      return 14;
    case 'F':
    case 'f':
      return 15;
    default:
      return 0;
  }
}
