--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with QMC5883P.Internal;

package body QMC5883P.Sensors is

   procedure Read
     (Self    : QMC5883P_Sensor'Class;
      Data    : out Byte_Array;
      Success : out Boolean);

   procedure Write
     (Self    : QMC5883P_Sensor'Class;
      Data    : Byte_Array;
      Success : out Boolean);

   package Dev is new Internal (QMC5883P_Sensor'Class, Read, Write);

   -------------------
   -- Check_Chip_Id --
   -------------------

   function Check_Chip_Id (Self : QMC5883P_Sensor) return Boolean is
     (Dev.Check_Chip_Id (Self));

   -------------------
   -- Is_Data_Ready --
   -------------------

   function Is_Data_Ready (Self : QMC5883P_Sensor) return Boolean is
     (Dev.Is_Data_Ready (Self));

   -----------------
   -- Is_Overflow --
   -----------------

   function Is_Overflow (Self : QMC5883P_Sensor) return Boolean is
     (Dev.Is_Overflow (Self));

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Self    : in out QMC5883P_Sensor;
      Setting : Full_Range_Configuration;
      Samples : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Dev.Configure (Self, Setting, Samples, Success);

      if Success then
         Self.Full_Range := Setting.Field_Range;
      end if;
   end Configure;

   ----------
   -- Read --
   ----------

   procedure Read
     (Self    : QMC5883P_Sensor'Class;
      Data    : out Byte_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Bytes  : HAL.I2C.I2C_Data (1 .. Data'Length)
        with Import, Address => Data'Address;

      Status : HAL.I2C.I2C_Status;
   begin
      Self.I2C_Port.Mem_Read
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
     (Self    : QMC5883P_Sensor;
      Value   : out Magnetic_Field_Vector;
      Success : out Boolean) is
   begin
      Dev.Read_Measurement (Self, Self.Full_Range, Value, Success);
   end Read_Measurement;

   --------------------------
   -- Read_Raw_Measurement --
   --------------------------

   procedure Read_Raw_Measurement
     (Self    : QMC5883P_Sensor;
      Value   : out Raw_Vector;
      Success : out Boolean) is
   begin
      Dev.Read_Raw_Measurement (Self, Value, Success);
   end Read_Raw_Measurement;

   -----------
   -- Reset --
   -----------

   procedure Reset
     (Self    : in out QMC5883P_Sensor;
      Success : out Boolean) is
   begin
      Dev.Reset (Self, Success);
   end Reset;

   --------------------
   -- Set_Full_Range --
   --------------------

   procedure Set_Full_Range
     (Self    : in out QMC5883P_Sensor;
      Value   : Full_Range_Configuration;
      Success : out Boolean) is
   begin
      Dev.Set_Full_Range (Self, Value, Success);

      if Success then
         Self.Full_Range := Value.Field_Range;
      end if;
   end Set_Full_Range;

   -----------------------
   -- Set_Rates_And_Mode --
   -----------------------

   procedure Set_Rates_And_Mode
     (Self    : QMC5883P_Sensor;
      Value   : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Dev.Set_Rates_And_Mode (Self, Value, Success);
   end Set_Rates_And_Mode;

   -----------
   -- Write --
   -----------

   procedure Write
     (Self    : QMC5883P_Sensor'Class;
      Data    : Byte_Array;
      Success : out Boolean)
   is
      use type HAL.I2C.I2C_Status;
      use type HAL.UInt10;

      Bytes  : HAL.I2C.I2C_Data (1 .. Data'Length)
        with Import, Address => Data'Address;

      Status : HAL.I2C.I2C_Status;
   begin
      Self.I2C_Port.Mem_Write
        (Addr          => 2 * HAL.UInt10 (I2C_Address),
         Mem_Addr      => HAL.UInt16 (Data'First),
         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
         Data          => Bytes,
         Status        => Status);

      Success := Status = HAL.I2C.Ok;
   end Write;

end QMC5883P.Sensors;
