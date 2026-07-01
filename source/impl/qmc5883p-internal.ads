--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

generic
   type Device_Context (<>) is limited private;

   with procedure Read
     (Device  : Device_Context;
      Data    : out Byte_Array;
      Success : out Boolean);
   --  Read the values from the QMC5883P chip registers into Data.
   --  Each element in Data corresponds to a specific register address
   --  in the chip; Data'Range determines the range of registers to read.
   --  The value read from register X will be stored in Data(X).

   with procedure Write
     (Device  : Device_Context;
      Data    : Byte_Array;
      Success : out Boolean);
   --  Write the Data values to the QMC5883P chip registers.
   --  Each element in Data corresponds to a specific register address
   --  in the chip; Data'Range determines the range of registers to write.
   --  The value written to register X is taken from Data(X).

package QMC5883P.Internal is

   function Check_Chip_Id (Device : Device_Context) return Boolean;
   --  Read chip ID register (0x00) and verify it equals Chip_Id.

   procedure Configure
     (Device  : Device_Context;
      Setting : Full_Range_Configuration;
      Samples : Rates_And_Mode_Configuration;
      Success : out Boolean);
   --  Write Control Register 2 (0x0B): full-scale range, set/reset, self-test,
   --  then write Control Register 1 (0x0A): mode, ODR, OSR1, OSR2.

   procedure Set_Rates_And_Mode
     (Device  : Device_Context;
      Value   : Rates_And_Mode_Configuration;
      Success : out Boolean);
   --  Write Control Register 1 (0x0A): mode, ODR, OSR1, OSR2.

   procedure Set_Full_Range
     (Device  : Device_Context;
      Value   : Full_Range_Configuration;
      Success : out Boolean);
   --  Write Control Register 2 (0x0B): full-scale range, set/reset, self-test.

   procedure Reset
     (Device  : Device_Context;
      Success : out Boolean);
   --  Perform a soft reset (sets SOFT_RST bit in register 0x0B).

   function Is_Data_Ready (Device : Device_Context) return Boolean;
   --  Read Status Register (0x09) and return the DRDY flag (bit 0).
   --  Cleared by reading the status register.

   function Is_Overflow (Device : Device_Context) return Boolean;
   --  Read Status Register (0x09) and return the OVFL flag (bit 1).
   --  Cleared after this bit is read.

   procedure Read_Measurement
     (Device      : Device_Context;
      Range_Gauss : Sensor_Full_Scale_Range;
      Value       : out Magnetic_Field_Vector;
      Success     : out Boolean);
   --  Read and scale measurement values from registers 0x01..0x06.
   --  Check Is_Overflow before calling to avoid Constraint_Error.

   procedure Read_Raw_Measurement
     (Device  : Device_Context;
      Value   : out Raw_Vector;
      Success : out Boolean);
   --  Read raw measurement values from registers 0x01..0x06.

end QMC5883P.Internal;
