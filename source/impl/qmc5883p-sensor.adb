--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with QMC5883P.Internal;

package body QMC5883P.Sensor is

   type Chip_Settings is record
      Full_Range : Sensor_Full_Scale_Range := 30;
   end record;

   Chip : Chip_Settings;

   procedure Read
     (Ignore  : Chip_Settings;
      Data    : out Byte_Array;
      Success : out Boolean);

   procedure Write
     (Ignore  : Chip_Settings;
      Data    : Byte_Array;
      Success : out Boolean);

   package Dev is new Internal (Chip_Settings, Read, Write);

   -------------------
   -- Check_Chip_Id --
   -------------------

   function Check_Chip_Id return Boolean is (Dev.Check_Chip_Id (Chip));

   -------------------
   -- Is_Data_Ready --
   -------------------

   function Is_Data_Ready return Boolean is (Dev.Is_Data_Ready (Chip));

   -----------------
   -- Is_Overflow --
   -----------------

   function Is_Overflow return Boolean is (Dev.Is_Overflow (Chip));

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Setting : Full_Range_Configuration;
      Samples : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Dev.Configure (Chip, Setting, Samples, Success);

      if Success then
         Chip.Full_Range := Setting.Field_Range;
      end if;
   end Configure;

   ----------
   -- Read --
   ----------

   procedure Read
     (Ignore  : Chip_Settings;
      Data    : out Byte_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Bytes  : HAL.I2C.I2C_Data (1 .. Data'Length)
        with Import, Address => Data'Address;

      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Port.Mem_Read
        (Addr          => 2 * HAL.UInt10 (I2C_Address),
         Mem_Addr      => HAL.UInt16 (Data'First),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data          => Bytes,
         Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Read;

   ----------------------
   -- Read_Measurement --
   ----------------------

   procedure Read_Measurement
     (Value   : out Magnetic_Field_Vector;
      Success : out Boolean) is
   begin
      Dev.Read_Measurement (Chip, Chip.Full_Range, Value, Success);
   end Read_Measurement;

   --------------------------
   -- Read_Raw_Measurement --
   --------------------------

   procedure Read_Raw_Measurement
     (Value   : out Raw_Vector;
      Success : out Boolean) is
   begin
      Dev.Read_Raw_Measurement (Chip, Value, Success);
   end Read_Raw_Measurement;

   -----------
   -- Reset --
   -----------

   procedure Reset (Success : out Boolean) is
   begin
      Dev.Reset (Chip, Success);
   end Reset;

   --------------------
   -- Set_Full_Range --
   --------------------

   procedure Set_Full_Range
     (Value   : Full_Range_Configuration;
      Success : out Boolean) is
   begin
      Dev.Set_Full_Range (Chip, Value, Success);

      if Success then
         Chip.Full_Range := Value.Field_Range;
      end if;
   end Set_Full_Range;

   -----------------------
   -- Set_Rates_And_Mode --
   -----------------------

   procedure Set_Rates_And_Mode
     (Value   : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Dev.Set_Rates_And_Mode (Chip, Value, Success);
   end Set_Rates_And_Mode;

   -----------
   -- Write --
   -----------

   procedure Write
     (Ignore  : Chip_Settings;
      Data    : Byte_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Bytes  : HAL.I2C.I2C_Data (1 .. Data'Length)
        with Import, Address => Data'Address;

      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Port.Mem_Write
        (Addr          => 2 * HAL.UInt10 (I2C_Address),
         Mem_Addr      => HAL.UInt16 (Data'First),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data          => Bytes,
         Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Write;

end QMC5883P.Sensor;
