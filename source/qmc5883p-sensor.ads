--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  This package offers a straightforward method for setting up the QMC5883P
--  when connected via I2C, especially useful when only one sensor is
--  required. If you need multiple sensors, use the QMC5883P.Sensors package,
--  which provides an appropriate tagged type.

with HAL.I2C;

generic
   I2C_Port : not null HAL.I2C.Any_I2C_Port;
package QMC5883P.Sensor is

   function Check_Chip_Id return Boolean;
   --  Read the chip ID register and check that it matches Chip_Id.

   procedure Reset (Success : out Boolean);
   --  Soft reset: restore default values of all registers.

   procedure Set_Rates_And_Mode
     (Value   : Rates_And_Mode_Configuration;
      Success : out Boolean);
   --  Write Control Register 1 (0x0A): operating mode, ODR, OSR1, OSR2.

   procedure Set_Full_Range
     (Value   : Full_Range_Configuration;
      Success : out Boolean);
   --  Write Control Register 2 (0x0B): full-scale range, set/reset, self-test.
   --  The configured Field_Range is remembered for subsequent Read_Measurement
   --  calls.

   function Is_Data_Ready return Boolean;
   --  Return the DRDY flag from Status Register (0x09).
   --  Set when all three-axis data are ready; cleared by reading the register.

   function Is_Overflow return Boolean;
   --  Return the OVFL flag from Status Register (0x09).
   --  Set when any axis output exceeds [-30000, 30000] LSB.

   procedure Read_Measurement
     (Value   : out Magnetic_Field_Vector;
      Success : out Boolean);
   --  Read and scale measurement values from registers 0x01..0x06 using the
   --  last configured field range. Check Is_Overflow before calling.

   procedure Read_Raw_Measurement
     (Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read raw measurement values from registers 0x01..0x06.

end QMC5883P.Sensor;
