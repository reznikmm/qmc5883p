--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Interfaces;

package QMC5883P is
   pragma Pure;
   pragma Discard_Names;

   type Over_Sample_Rate is range 1 .. 8
     with Static_Predicate => Over_Sample_Rate in 1 | 2 | 4 | 8;
   --  Over Sample Rate (OSR1) controls the bandwidth of the internal digital
   --  filter. Larger OSR value leads to smaller filter bandwidth, less
   --  in-band noise, and higher power consumption.

   type Down_Sample_Rate is range 1 .. 8
     with Static_Predicate => Down_Sample_Rate in 1 | 2 | 4 | 8;
   --  Down Sample Rate (OSR2) provides an additional noise filter.
   --  Values 1, 2, 4, 8 downsample by that factor.

   type Output_Data_Rate is range 10 .. 200
     with Static_Predicate => Output_Data_Rate in 10 | 50 | 100 | 200;
   --  Typical data output rate in Hz.

   type Operating_Mode is (Suspend, Normal, Single, Continuous);
   --  The operating mode.
   --
   --  * @value Suspend - Suspend Mode (default after POR/soft reset).
   --    Only minimal blocks are active; no measurement occurs.
   --
   --  * @value Normal - Normal Mode.
   --    The sensor continuously makes measurements at the configured ODR.
   --
   --  * @value Single - Single Mode.
   --    One measurement is performed, then the sensor enters Suspend Mode.
   --
   --  * @value Continuous - Continuous Mode.
   --    The sensor runs without sleep time, enabling the maximum ODR.
   --    Self-test can only be enabled in this mode.

   type Set_Reset_Mode is (Set_And_Reset_On, Set_Only_On, Set_And_Reset_Off);
   --  Controls the internal set/reset driver used for offset renewal.
   --
   --  * @value Set_And_Reset_On - Both set and reset pulses are active
   --    (recommended; offsets are renewed during measurement).
   --  * @value Set_Only_On - Only the set pulse is active.
   --  * @value Set_And_Reset_Off - Neither pulse is active; offsets are not
   --    renewed during measurement.

   type Sensor_Full_Scale_Range is range 2 .. 30
     with Static_Predicate => Sensor_Full_Scale_Range in 2 | 8 | 12 | 30;
   --  Full-scale field range in Gauss (+/-).
   --  The lowest range has the highest sensitivity and resolution.

   type Rates_And_Mode_Configuration is record
      Over_Sample : Over_Sample_Rate := 8;
      Down_Sample : Down_Sample_Rate := 1;
      Data_Rate   : Output_Data_Rate := 10;
      Mode        : Operating_Mode   := Suspend;
   end record;
   --  Configuration for Control Register 1 (0x0A).
   --  Controls the operating mode, output data rate, and sampling filters.

   type Full_Range_Configuration is record
      Field_Range : Sensor_Full_Scale_Range := 30;
      Set_Reset   : Set_Reset_Mode          := Set_And_Reset_On;
      Self_Test   : Boolean                 := False;
   end record;
   --  Configuration for Control Register 2 (0x0B).
   --  Controls the full-scale range, set/reset driver, and self-test.

   type Magnetic_Field is delta 1.0 / 2.0 ** 10 range -30.0 .. 30.0;
   --  Magnetic flux density in Gauss.

   type Magnetic_Field_Vector is record
      X, Y, Z : Magnetic_Field;
   end record;
   --  Magnetic field vector.

   type Raw_Vector is record
      X, Y, Z : Interfaces.Integer_16;
   end record;
   --  A value read from the sensor in raw format. The output data of each
   --  channel saturates at -32768 and 32767.

   subtype Byte is Interfaces.Unsigned_8;  --  Register value

   subtype Register_Address is Natural range 16#00# .. 16#FF#;
   --  Sensor register address.

   type Byte_Array is array (Register_Address'Base range <>) of Byte;
   --  Bytes exchanged with registers. The index is the register address and
   --  the element is the corresponding register value.

   Chip_Id : constant Byte := 16#80#;
   --  Expected chip ID stored in register 0x00.

   type Full_Scale_Range is delta 1.0 / 2.0 ** 23 range 0.0 .. 0.002;
   --  Gauss per LSB. Use this to convert raw counts to Gauss.

   pragma Warnings
     (Off, "static fixed-point value is not a multiple of Small");

   function To_Scale
     (Range_Gauss : Sensor_Full_Scale_Range) return Full_Scale_Range is
       (case Range_Gauss is
        when  2 => 1.0 / 15000.0,
        when  8 => 1.0 /  3750.0,
        when 12 => 1.0 /  2500.0,
        when 30 => 1.0 /  1000.0);
   --  Convert a full-scale range to a Gauss-per-LSB scale factor.
   --
   --  Sensitivity values from datasheet:
   --    +/- 2 Gauss:  15000 LSB/G
   --    +/- 8 Gauss:   3750 LSB/G
   --    +/- 12 Gauss:  2500 LSB/G
   --    +/- 30 Gauss:  1000 LSB/G

   pragma Warnings
     (On, "static fixed-point value is not a multiple of Small");

   I2C_Address : constant := 16#2C#;
   --  Default I2C device address.

private

   type Int is delta 1.0 range -32768.0 .. 32767.0;
   --  Internal type for raw-value fixed-point arithmetic.

end QMC5883P;
