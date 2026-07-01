--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Real_Time;
with Ada.Text_IO;

with Ravenscar_Time;

with STM32.Board;
with STM32.Device;
with STM32.Setup;

with QMC5883P.Sensor;

procedure Main is
   use type Ada.Real_Time.Time;

   package QMC5883P_I2C is new QMC5883P.Sensor
     (I2C_Port => STM32.Device.I2C_1'Access);

   Ok     : Boolean := False;
   Vector : array (1 .. 16) of QMC5883P.Raw_Vector;
   Prev   : Ada.Real_Time.Time;
   Spin   : Natural := 0;
begin
   STM32.Board.Initialize_LEDs;
   STM32.Setup.Setup_I2C_Master
     (Port        => STM32.Device.I2C_1,
      SDA         => STM32.Device.PB9,
      SCL         => STM32.Device.PB8,
      SDA_AF      => STM32.Device.GPIO_AF_I2C1_4,
      SCL_AF      => STM32.Device.GPIO_AF_I2C1_4,
      Clock_Speed => 400_000);

   --  Look for QMC5883P chip
   if not QMC5883P_I2C.Check_Chip_Id then
      Ada.Text_IO.Put_Line ("QMC5883P not found.");
      raise Program_Error;
   end if;

   --  Reset QMC5883P
   QMC5883P_I2C.Reset (Ok);
   pragma Assert (Ok);

   for J in 0 .. 1E6 loop
      --  Let's configure twice to make it work stable
      for K in reverse 1 .. 2 loop
         declare
            FSR : constant array (0 .. 3) of QMC5883P.Sensor_Full_Scale_Range :=
              (2, 8, 12, 30);
            DSR : constant array (0 .. 3) of QMC5883P.Down_Sample_Rate :=
              (1, 2, 4, 8);
         begin
            QMC5883P_I2C.Configure
              (Setting =>
                 (Field_Range => FSR (J mod 4),
                  Set_Reset   => QMC5883P.Set_And_Reset_On,
                  Self_Test   => False),
               Samples =>
                 (Mode        => QMC5883P.Normal,
                  Down_Sample => DSR (J / 4 mod 4),
                  Over_Sample => 1,
                  Data_Rate   => 10),
               Success => Ok);
            pragma Assert (Ok);

            exit when K = 1;

            while not QMC5883P_I2C.Is_Data_Ready loop
               Spin := Spin + 1;
            end loop;

            Ada.Text_IO.Put_Line
              ("Range=" & FSR (J mod 4)'Image &
                 " Down=" & DSR (J / 4 mod 4)'Image);
         end;
      end loop;

      Prev := Ada.Real_Time.Clock;
      Spin := 0;
      STM32.Board.Toggle (STM32.Board.D1_LED);

      for J in Vector'Range loop
         while not QMC5883P_I2C.Is_Data_Ready loop
            Spin := Spin + 1;
         end loop;

         -- Check overflow
         if QMC5883P_I2C.Is_Overflow then
            Vector (J) := (others => 0);
         else
         --  Read scaled values from the sensor
            QMC5883P_I2C.Read_Raw_Measurement (Vector (J), Ok);
            pragma Assert (Ok);
         end if;
      end loop;

      --  Printing...
      declare
         Now  : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Diff : constant Duration := Ada.Real_Time.To_Duration (Now - Prev);
      begin
         Ada.Text_IO.New_Line;
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line
           ("Time=" & Diff'Image &
            "/16 spin=" & Spin'Image);

         for Value of Vector loop
            declare
               X : constant String := Value.X'Image;
               Y : constant String := Value.Y'Image;
               Z : constant String := Value.Z'Image;
            begin
               Ada.Text_IO.Put_Line ("X=" & X & " Y=" & Y & " Z=" & Z);
            end;
         end loop;

         Ada.Text_IO.Put_Line ("Sleeping 2s...");
         Ravenscar_Time.Delays.Delay_Seconds (2);
      end;
   end loop;
end Main;
