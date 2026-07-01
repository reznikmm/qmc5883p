--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with QMC5883P.Raw;

package body QMC5883P.Internal is

   -------------------
   -- Check_Chip_Id --
   -------------------

   function Check_Chip_Id (Device : Device_Context) return Boolean is
      use type Byte;

      Ok   : Boolean;
      Data : Byte_Array (Raw.Chip_Id_Data'Range);
   begin
      Read (Device, Data, Ok);

      return Ok and Raw.Get_Chip_Id (Data) = Chip_Id;
   end Check_Chip_Id;

   ---------------
   -- Configure --
   ---------------

   procedure Configure
     (Device  : Device_Context;
      Setting : Full_Range_Configuration;
      Samples : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Set_Full_Range (Device, Setting, Success);

      if Success then
         Set_Rates_And_Mode (Device, Samples, Success);
      end if;
   end Configure;

   -------------------
   -- Is_Data_Ready --
   -------------------

   function Is_Data_Ready (Device : Device_Context) return Boolean is
      Ok   : Boolean;
      Data : Byte_Array (Raw.Status_Data'Range);
   begin
      Read (Device, Data, Ok);

      return Ok and Raw.Is_Data_Ready (Data);
   end Is_Data_Ready;

   -----------------
   -- Is_Overflow --
   -----------------

   function Is_Overflow (Device : Device_Context) return Boolean is
      Ok   : Boolean;
      Data : Byte_Array (Raw.Status_Data'Range);
   begin
      Read (Device, Data, Ok);

      return Ok and Raw.Is_Overflow (Data);
   end Is_Overflow;

   ----------------------
   -- Read_Measurement --
   ----------------------

   procedure Read_Measurement
     (Device      : Device_Context;
      Range_Gauss : Sensor_Full_Scale_Range;
      Value       : out Magnetic_Field_Vector;
      Success     : out Boolean)
   is
      Data : Byte_Array (Raw.Measurement_Data'Range);
   begin
      Read (Device, Data, Success);

      if Success then
         Value := Raw.Get_Measurement (Data, Range_Gauss);
      else
         Value := (X | Y | Z => 0.0);
      end if;
   end Read_Measurement;

   --------------------------
   -- Read_Raw_Measurement --
   --------------------------

   procedure Read_Raw_Measurement
     (Device  : Device_Context;
      Value   : out Raw_Vector;
      Success : out Boolean)
   is
      Data : Byte_Array (Raw.Measurement_Data'Range);
   begin
      Read (Device, Data, Success);

      if Success then
         Value := Raw.Get_Raw_Measurement (Data);
      else
         Value := (X | Y | Z => 0);
      end if;
   end Read_Raw_Measurement;

   -----------
   -- Reset --
   -----------

   procedure Reset
     (Device  : Device_Context;
      Success : out Boolean) is
   begin
      Write (Device, Raw.Reset, Success);
   end Reset;

   --------------------
   -- Set_Full_Range --
   --------------------

   procedure Set_Full_Range
     (Device  : Device_Context;
      Value   : Full_Range_Configuration;
      Success : out Boolean) is
   begin
      Write (Device, Raw.Set_Full_Range (Value), Success);
   end Set_Full_Range;

   -----------------------
   -- Set_Rates_And_Mode --
   -----------------------

   procedure Set_Rates_And_Mode
     (Device  : Device_Context;
      Value   : Rates_And_Mode_Configuration;
      Success : out Boolean) is
   begin
      Write (Device, Raw.Set_Rates_And_Mode (Value), Success);
   end Set_Rates_And_Mode;

end QMC5883P.Internal;
