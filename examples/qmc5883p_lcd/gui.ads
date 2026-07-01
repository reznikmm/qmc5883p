--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with GUI_Buttons;
with HAL.Bitmap;
with HAL.Touch_Panel;

package GUI is

   type Button_Kind is
     (Fx, Fy, Fz,         --  Field components to display
      CO,                 --  Contigous mode
      R1, R2, R3, R4,     --  Output_Data_Rate (10, 50, 100, 200 Hz)
      G2, G8, GC, GY,     --  Full_Scale_Range (2G, 8G, 12G, 30G)
      O1, O2, O3, O4,     --  Over_Sample_Rate (OSR1: 1, 2, 4, 8)
      D1, D2, D3, D4);    --  Down_Sample_Rate (OSR2: 1, 2, 4, 8)

   function "+" (X : Button_Kind) return Natural is (Button_Kind'Pos (X))
     with Static;

   Buttons : constant GUI_Buttons.Button_Info_Array :=
     [(Label  => "Fx",
       Center => (23 * 1, 20),
       Color  => HAL.Bitmap.Red),
      (Label  => "Fy",
       Center => (23 * 2, 20),
       Color  => HAL.Bitmap.Green),
      (Label  => "Fz",
       Center => (23 * 3, 20),
       Color  => HAL.Bitmap.Blue),
      (Label  => "CO",
       Center => (23, 60 + 1 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R1",
       Center => (23, 60 + 2 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R2",
       Center => (23, 60 + 3 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R3",
       Center => (23, 60 + 4 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "R4",
       Center => (23, 60 + 5 * 15),
       Color  => HAL.Bitmap.Dark_Grey),
      (Label  => "2G",
       Center => (23 * 1 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "8G",
       Center => (23 * 2 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "12",
       Center => (23 * 3 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "30",
       Center => (23 * 4 + 160, 220),
       Color  => HAL.Bitmap.Dim_Grey),
      (Label  => "O1",
       Center => (23 * 1 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O2",
       Center => (23 * 2 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O4",
       Center => (23 * 3 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "O8",
       Center => (23 * 4 + 160, 20),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "D1",
       Center => (23 * 1 + 40, 220),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "D2",
       Center => (23 * 2 + 40, 220),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "D4",
       Center => (23 * 3 + 40, 220),
       Color  => HAL.Bitmap.Yellow_Green),
      (Label  => "D8",
       Center => (23 * 4 + 40, 220),
       Color  => HAL.Bitmap.Yellow_Green)];

   --  Initial state: show all fields, OSR1=1, OSR2=1, 30G range, 10Hz
   State : GUI_Buttons.Boolean_Array (Buttons'Range) :=
     [+Fx | +Fy | +Fz | +O1 | +GY | +R1 | +D1 => True, others => False];

   procedure Check_Touch
     (TP     : in out HAL.Touch_Panel.Touch_Panel_Device'Class;
      Update : out Boolean);
   --  Check buttons touched, update State, set Update = True if State changed

   procedure Draw
     (LCD   : in out HAL.Bitmap.Bitmap_Buffer'Class;
      Clear : Boolean := False);

   procedure Dump_Screen (LCD : in out HAL.Bitmap.Bitmap_Buffer'Class);

end GUI;
