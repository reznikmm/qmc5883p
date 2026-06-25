# QMC5883P LCD demo

This folder contains a demonstration program showcasing the functionality
of a magnetometer sensor using the STM32 F4VE board
and an LCD display included in the kit. The program features a straightforward
graphical user interface (GUI) for configuring sensor parameters.

## Overview

The demonstration program works with the STM32 F4VE development board and a
compatible LCD display. It provides a GUI interface to configure sensor
parameters such as over-sample rate, full-scale range and output data rate.

The display includes:
* Toggle buttons (`Fx`, `Fy`, `Fz`) for enabling/disabling each field
  component on the plot.
* Yellow buttons (`O1`, `O2`, `O4`, `O8`) for selecting the OSR1
  over-sample rate (1, 2, 4, 8).
* Grey buttons (`2G`, `8G`, `12`, `30`) for selecting the full-scale field
  range in Gauss.
* Dark grey buttons (`R1`..`R4`) for selecting the output data rate
  (10, 50, 100, 200 Hz).

## Requirements

* STM32 F4VE development board
* Any QMC5883P module
* Compatible LCD display/touch panel included in the kit
* Development environment compatible with STM32F4 microcontrollers

## Setup

* Attach QMC5883P by I2C to PB9 (SDA), PB8 (SCL)
* Attach the LCD display to the designated port on the STM32F4VE board.
* Connect the STM32 F4VE board to your development environment.

## Usage

Compile and upload the program to the STM32 F4VE board. Upon successful upload,
the demonstration program will run, displaying sensor data on the LCD screen.
Activate the buttons on the GUI interface using the touch panel.
Simply touch the corresponding button on the LCD screen to toggle its state.
