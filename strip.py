#!/usr/bin/env python2.6
"""
strip.py - Control a strip of LPD8806 driven LEDs in concert with an Arduino program
Author: Craig Calef <craig@dod.net>
This code is covered under the MIT License
"""

import serial, sys, time
from time import sleep

SERIAL_DEVICE = '/dev/cu.usbserial-A900adMy'

def clearreadbuffer(ser):
  print ser.readline().strip()

def bluefadein(ser):
  for ii in range(128, 256):
    print "--"
    for i in range(0, 32):
      outval = "%02X%02X%02X%02X" % (i, 0, 0, ii)
      #print outval
      ser.write("%s\n" % outval)
      clearreadbuffer(ser)

    ser.write('FF\n')
    clearreadbuffer(ser)
    #time.sleep(1)

def show(ser):
  ser.write('FF\n')
  print ser.readline()

def ledset(ser, led, r, g, b):
  outval = "%02X%02X%02X%02X" % (led, r, g, b)
  print outval
  ser.write("%s\n" % outval)
  print ser.readline()

def glitchtest(ser):
  for ii in [0, 0x20, 0x21]:
    for i in range(0, 31):
      ledset(ser, i, 0, 0, ii)
    show(ser)
    sleep(1)
    print "---"

def blinktest(ser):
  while True:
    for i in range(0, 32):
      ledset(ser, i, 0, 0, 0)
    show(ser)
    sleep(0.5)
    for i in range(0, 32):
      ledset(ser, i, 255, 255, 255)
    show(ser)
    sleep(0.5)

def cylon(ser):
  i = last = 0
  direction = 1
  #for i in range(0, 32):
  #  ledset(ser, i, 0, 0, 0)
  #  show(ser)

  while True:
    ledset(ser, last, 0, 0, 0)
    ledset(ser, i, 255, 0, 0)
    show(ser)
    last = i
    i = i + direction
    if i <= 0:
      direction = 1
    if i >= 31:
      direction = -1
    #sleep(0.05) 

if __name__ == '__main__':
  print "Connecting"
  ser = serial.Serial(SERIAL_DEVICE, 115200)
  time.sleep(2)
  print "Running"
  cylon(ser)
