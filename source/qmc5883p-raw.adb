--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Unchecked_Conversion;

package body QMC5883P.Raw is

   ---------------------
   -- Get_Measurement --
   ---------------------

   function Get_Measurement
     (Raw         : Byte_Array;
      Range_Gauss : Sensor_Full_Scale_Range) return Magnetic_Field_Vector
   is
      Scale  : constant Full_Scale_Range := To_Scale (Range_Gauss);
      Vector : constant Raw_Vector := Get_Raw_Measurement (Raw);

   begin
      return
        (X => Scale * Int (Vector.X),
         Y => Scale * Int (Vector.Y),
         Z => Scale * Int (Vector.Z));
   end Get_Measurement;

   -------------------------
   -- Get_Raw_Measurement --
   -------------------------

   function Get_Raw_Measurement (Raw : Byte_Array) return Raw_Vector is
      use Interfaces;

      function Cast is new Ada.Unchecked_Conversion
        (Unsigned_16, Integer_16);

      --  Measurement data is little-endian: LSB at lower address, MSB next
      function Decode (Data : Byte_Array) return Integer_16 is
         (Cast (Shift_Left (Unsigned_16 (Data (Data'Last)), 8)
            + Unsigned_16 (Data (Data'First))));

   begin
      return
        (X => Decode (Raw (1 .. 2)),
         Y => Decode (Raw (3 .. 4)),
         Z => Decode (Raw (5 .. 6)));
   end Get_Raw_Measurement;

   --------------------
   -- Set_Full_Range --
   --------------------

   function Set_Full_Range
     (Value : Full_Range_Configuration) return Full_Range_Data
   is
      --  Register 0x0B layout:
      --   Bit [7]:   SOFT_RST
      --   Bit [6]:   SELF_TEST
      --   Bit [5:4]: reserved
      --   Bit [3:2]: RNG  (00=30G, 01=12G, 10=8G, 11=2G)
      --   Bit [1:0]: SET/RESET MODE

      type CR2_Register is record
         Set_Reset : Natural range 0 .. 3;
         RNG       : Natural range 0 .. 3;
         Reserved  : Natural range 0 .. 3 := 0;
         Self_Test : Natural range 0 .. 1;
         Soft_Rst  : Natural range 0 .. 1 := 0;
      end record;

      for CR2_Register use record
         Set_Reset at 0 range 0 .. 1;
         RNG       at 0 range 2 .. 3;
         Reserved  at 0 range 4 .. 5;
         Self_Test at 0 range 6 .. 6;
         Soft_Rst  at 0 range 7 .. 7;
      end record;

      function Cast_CR2 is new Ada.Unchecked_Conversion
        (CR2_Register, Byte);

      SR : constant Natural := Set_Reset_Mode'Pos (Value.Set_Reset);

      RNG : constant Natural :=
        (case Value.Field_Range is
            when 30 => 0,
            when 12 => 1,
            when  8 => 2,
            when  2 => 3);

      ST : constant Natural := Boolean'Pos (Value.Self_Test);

   begin
      return
        (16#0B# =>
           Cast_CR2 ((Set_Reset => SR, RNG => RNG, Reserved => 0,
                      Self_Test => ST, Soft_Rst  => 0)));
   end Set_Full_Range;

   -----------------------
   -- Set_Rates_And_Mode --
   -----------------------

   function Set_Rates_And_Mode
     (Value : Rates_And_Mode_Configuration) return Rates_And_Mode_Data
   is
      --  Register 0x0A layout:
      --   Bit [7:6]: OSR2 (00=DSR/1, 01=DSR/2, 10=DSR/4, 11=DSR/8)
      --   Bit [5:4]: OSR1 (00=OSR8, 01=OSR4, 10=OSR2, 11=OSR1)
      --   Bit [3:2]: ODR  (00=10Hz, 01=50Hz, 10=100Hz, 11=200Hz)
      --   Bit [1:0]: MODE (00=Suspend, 01=Normal, 10=Single, 11=Continuous)

      type CR1_Register is record
         Mode : Natural range 0 .. 3;
         ODR  : Natural range 0 .. 3;
         OSR1 : Natural range 0 .. 3;
         OSR2 : Natural range 0 .. 3;
      end record;

      for CR1_Register use record
         Mode at 0 range 0 .. 1;
         ODR  at 0 range 2 .. 3;
         OSR1 at 0 range 4 .. 5;
         OSR2 at 0 range 6 .. 7;
      end record;

      function Cast_CR1 is new Ada.Unchecked_Conversion
        (CR1_Register, Byte);

      Mode : constant Natural := Operating_Mode'Pos (Value.Mode);

      ODR : constant Natural :=
        (if Value.Mode = Normal then
           (case Value.Data_Rate is
               when  10 => 0,
               when  50 => 1,
               when 100 => 2,
               when 200 => 3)
         else 0);

      OSR1 : constant Natural :=
        (case Value.Over_Sample is
            when 1 => 3,
            when 2 => 2,
            when 4 => 1,
            when 8 => 0);

      OSR2 : constant Natural :=
        (case Value.Down_Sample is
            when 1 => 0,
            when 2 => 1,
            when 4 => 2,
            when 8 => 3);

   begin
      return
        (16#0A# =>
           Cast_CR1 ((Mode => Mode, ODR => ODR, OSR1 => OSR1, OSR2 => OSR2)));
   end Set_Rates_And_Mode;

end QMC5883P.Raw;
