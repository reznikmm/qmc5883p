# QMC5883P

[![Build status](https://github.com/reznikmm/qmc5883p/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/qmc5883p/actions/workflows/alire.yml)
[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/qmc5883p.json)](https://alire.ada.dev/crates/qmc5883p.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/qmc5883p)](https://api.reuse.software/info/github.com/reznikmm/qmc5883p)


Driver for QMC5883P 3-axis magnetic sensor (I2C address 0x2C).

> Note: For QMC5883L (I2C address 0x0D), use the dedicated driver:
[reznikmm/qmc5883](https://github.com/reznikmm/qmc5883).

- Datasheet PDF: [C2847467.pdf](https://www.lcsc.com/datasheet/C2847467.pdf)

QMC5883P is a 3-axis magnetic sensor with 16-bit ADC, I2C interface,
temperature compensation, and selectable full-scale ranges up to +/-30 Gauss.

The QMC5883P driver provides:

- Sensor presence check by chip ID.
- Sensor configuration (range, set/reset mode, self-test, rates, operating mode).
- Raw and scaled magnetic field measurements.
- Generic package and tagged-type APIs for single or multiple sensors.

## Install

Add `qmc5883p` as a dependency to your crate with Alire:

    alr with qmc5883p

## Usage

The driver supports two usage models:

- Generic package `QMC5883P.Sensor` for a single sensor.
- Tagged type `QMC5883P.Sensors.QMC5883P_Sensor` for one or more sensors.

Generic instantiation example:

```ada
declare
   package QMC5883P_I2C is new QMC5883P.Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);
begin
   if QMC5883P_I2C.Check_Chip_Id then
      ...
```

Tagged type object example:

```ada
declare
   Sensor : QMC5883P.Sensors.QMC5883P_Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);
begin
   if Sensor.Check_Chip_Id then
      ...
```

### Sensor Configuration

Use `Configure` and related setters to set:

- `Field_Range`: +/-2, +/-8, +/-12, +/-30 Gauss.
- `Set_Reset`: `Set_And_Reset_On`, `Set_Only_On`, `Set_And_Reset_Off`.
- `Self_Test`: built-in self-test enable.
- `Over_Sample` (OSR1): 1, 2, 4, 8.
- `Down_Sample` (OSR2): 1, 2, 4, 8.
- `Data_Rate` in Normal mode: 10, 50, 100, 200 Hz.
- `Mode`: `Suspend`, `Normal`, `Single`, `Continuous`.

### Sensor Mode

`Set_Rates_And_Mode` can switch between:

- `Suspend` (low power, default after reset).
- `Normal` (continuous measurements at configured ODR).
- `Single` (one measurement, then returns to `Suspend`).
- `Continuous` (maximum throughput mode).

Data readiness can be checked by `Is_Data_Ready`.

### Read Measurement

- `Read_Raw_Measurement` returns raw 16-bit values.
- `Read_Measurement` returns scaled values in Gauss.
- Check `Is_Overflow` before relying on scaled output.
- Check `Is_Data_Ready` before reading to avoid stale data.

### Important Practical Note

In my setup, I managed to make the sensor work reliably only when:

- configuration registers are written twice;
- and the code explicitly switches to `Suspend` mode first ("Ыгызутв" mode).

See the working sequence in the LCD example:
[examples/qmc5883p_lcd/main.adb](examples/qmc5883p_lcd/main.adb).

## Low-Level Interface: `QMC5883P.Raw`

Package `QMC5883P.Raw` provides low-level register encoding/decoding without
depending on HAL. It is useful when implementing custom I2C/DMA transfers.

It includes helpers to:

- encode register values for write operations;
- decode register values after read operations;
- prepare arrays for I2C register write/read transactions.

## Examples

Examples use Ada Drivers Library (installed by Alire).

Build examples:

    alr -C examples build

### GNAT Studio

Launch GNAT Studio with Alire:

    alr -C examples exec gnatstudio -- -P qmc5883p_put/qmc5883p_put.gpr

### VS Code

Make sure `alr` is in `PATH`.
Open the `examples` folder in VS Code. Use pre-configured tasks to build,
flash, and debug.

- [Simple example for STM32 F4VE board](examples/qmc5883p_put)
- [Advanced example for STM32 F4VE board with LCD and touch panel](examples/qmc5883p_lcd)