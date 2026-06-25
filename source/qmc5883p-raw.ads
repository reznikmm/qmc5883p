--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

--  This package provides a low-level interface for interacting with the
--  sensor. Communication with the sensor is done by reading/writing one
--  or more bytes to predefined registers. The interface allows the user to
--  implement the read/write operations in the way they prefer but handles
--  encoding/decoding register values into user-friendly formats.
--
--  For each request to the sensor, the interface defines a subtype-array
--  where the index of the array element represents the register number to
--  read/write, and the value of the element represents the corresponding
--  register value.
--
--  Functions starting with `Set_` prepare values to be written to the
--  registers. Conversely, functions starting with `Get_` decode register
--  values. Functions starting with `Is_` are a special case for boolean
--  values.
--
--  The user is responsible for reading and writing register values!

package QMC5883P.Raw is

   use type Byte;

   subtype Chip_Id_Data is Byte_Array (0 .. 0);
   --  The chip ID register (0x00).

   function Get_Chip_Id (Raw : Byte_Array) return Byte is
     (Raw (Chip_Id_Data'First))
       with Pre => Chip_Id_Data'First in Raw'Range;
   --  Read the chip ID byte. Raw should contain Chip_Id_Data'Range items.
   --  Compare the result to the QMC5883P.Chip_Id constant (0x80).

   subtype Measurement_Data is Byte_Array (1 .. 6);
   --  Magnetic field output registers 0x01..0x06 (X, Y, Z, each 16-bit LE).

   function Get_Raw_Measurement (Raw : Byte_Array) return Raw_Vector
     with Pre => Measurement_Data'First in Raw'Range and then
       Measurement_Data'Last in Raw'Range;
   --  Decode raw measurement. Raw should contain Measurement_Data'Range items.
   --  Each channel saturates at -32768 and 32767.

   function Get_Measurement
     (Raw         : Byte_Array;
      Range_Gauss : Sensor_Full_Scale_Range) return Magnetic_Field_Vector
     with Pre => Measurement_Data'First in Raw'Range and then
       Measurement_Data'Last in Raw'Range;
   --  Decode and scale measurement to Gauss.
   --  Raw should contain Measurement_Data'Range items.
   --  Check Is_Overflow before calling to avoid Constraint_Error.

   subtype Status_Data is Byte_Array (9 .. 9);
   --  Status register (0x09).

   function Is_Data_Ready (Raw : Byte_Array) return Boolean is
     ((Raw (Status_Data'First) and 1) = 1)
       with Pre => Status_Data'First in Raw'Range;
   --  Data Ready (DRDY) flag. Set when all three-axis data are ready and
   --  loaded to the output registers. Cleared by reading the status register.

   function Is_Overflow (Raw : Byte_Array) return Boolean is
     ((Raw (Status_Data'First) and 2) /= 0)
       with Pre => Status_Data'First in Raw'Range;
   --  Overflow (OVFL) flag. Set when any axis code output exceeds the range
   --  [-30000, 30000] LSB. Cleared after this bit is read.

   subtype Rates_And_Mode_Data is Byte_Array (16#0A# .. 16#0A#);
   --  Control Register 1 (0x0A): operating mode, ODR, OSR1, OSR2.

   function Set_Rates_And_Mode
     (Value : Rates_And_Mode_Configuration) return Rates_And_Mode_Data;
   --  Encode Rates_And_Mode_Configuration into Control Register 1 (0x0A).

   subtype Full_Range_Data is Byte_Array (16#0B# .. 16#0B#);
   --  Control Register 2 (0x0B): full-scale range, set/reset, self-test.

   function Set_Full_Range
     (Value : Full_Range_Configuration) return Full_Range_Data;
   --  Encode Full_Range_Configuration into Control Register 2 (0x0B).

   function Reset return Full_Range_Data is
     (16#0B# => 16#80#);
   --  Soft reset: restores default values of all registers (sets SOFT_RST
   --  bit in Control Register 2). Write the result to register 0x0B.

   ------------------------------
   -- I2C Write/Read functions --
   ------------------------------

   function I2C_Write (X : Byte_Array) return Byte_Array is
     ((X'First - 1 => Byte (X'First)) & X);
   --  Prefix the byte array with the register address for an I2C write.

   function I2C_Read (X : Byte_Array) return Byte_Array is
     ((X'First => Byte (X'First)) & X (X'First + 1 .. X'Last));
   --  Replace the first byte with the register address for an I2C read.

end QMC5883P.Raw;
