--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  This package offers a way to set up multiple QMC5883P sensors connected
--  via I2C using a tagged type. If you only need a single sensor, it may
--  be simpler to use the QMC5883P.Sensor generic package.

with HAL.I2C;

package QMC5883P.Sensors is

   type QMC5883P_Sensor
     (I2C_Port : not null HAL.I2C.Any_I2C_Port) is tagged limited private;

   function Check_Chip_Id (Self : QMC5883P_Sensor) return Boolean;
   --  Read the chip ID register and check that it matches Chip_Id.

   procedure Reset
     (Self    : in out QMC5883P_Sensor;
      Success : out Boolean);
   --  Soft reset: restore default values of all registers.

   procedure Set_Rates_And_Mode
     (Self    : QMC5883P_Sensor;
      Value   : Rates_And_Mode_Configuration;
      Success : out Boolean);
   --  Write Control Register 1 (0x0A): operating mode, ODR, OSR1, OSR2.

   procedure Set_Full_Range
     (Self    : in out QMC5883P_Sensor;
      Value   : Full_Range_Configuration;
      Success : out Boolean);
   --  Write Control Register 2 (0x0B): full-scale range, set/reset, self-test.
   --  The configured Field_Range is remembered for subsequent Read_Measurement
   --  calls.

   function Is_Data_Ready (Self : QMC5883P_Sensor) return Boolean;
   --  Return the DRDY flag from Status Register (0x09).
   --  Set when all three-axis data are ready; cleared by reading the register.

   function Is_Overflow (Self : QMC5883P_Sensor) return Boolean;
   --  Return the OVFL flag from Status Register (0x09).
   --  Set when any axis output exceeds [-30000, 30000] LSB.

   procedure Read_Measurement
     (Self    : QMC5883P_Sensor;
      Value   : out Magnetic_Field_Vector;
      Success : out Boolean);
   --  Read and scale measurement values from registers 0x01..0x06 using the
   --  last configured field range. Check Is_Overflow before calling.

   procedure Read_Raw_Measurement
     (Self    : QMC5883P_Sensor;
      Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read raw measurement values from registers 0x01..0x06.

private

   type QMC5883P_Sensor
     (I2C_Port : not null HAL.I2C.Any_I2C_Port) is tagged limited
   record
      Full_Range : Sensor_Full_Scale_Range := 30;
   end record;

end QMC5883P.Sensors;
