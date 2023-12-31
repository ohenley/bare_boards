------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2015, AdaCore                           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
with STM32.SDRAM;

package body STM32.Board is

   ------------------
   -- All_LEDs_Off --
   ------------------

   procedure All_LEDs_Off is
   begin
      Clear (All_LEDs);
   end All_LEDs_Off;

   -----------------
   -- All_LEDs_On --
   -----------------

   procedure All_LEDs_On is
   begin
      Set (All_LEDs);
   end All_LEDs_On;

   ---------------------
   -- Initialize_LEDs --
   ---------------------

   procedure Initialize_LEDs is
   begin
      Enable_Clock (All_LEDs);

      Configure_IO (All_LEDs,
                    (Mode        => Mode_Out,
                     Output_Type => Push_Pull,
                     Speed       => Speed_100MHz,
                     Resistors   => Floating));
   end Initialize_LEDs;

   ---------------------------
   -- Initialize_SDRAM_GPIO --
   ---------------------------

   procedure Initialize_SDRAM_GPIO is
   begin
      Enable_Clock (SDRAM_PINS);

      Configure_IO (SDRAM_Pins,
                    (Mode           => Mode_AF,
                     AF             => GPIO_AF_FMC_12,
                     AF_Speed       => Speed_50MHz,
                     AF_Output_Type => Push_Pull,
                     Resistors      => Pull_Up));

      Lock (SDRAM_Pins);
   end;

   procedure Initialize_SDRAM is
   begin
      Initialize_SDRAM_GPIO;
      STM32.SDRAM.Initialize (STM32.Device.System_Clock_Frequencies.SYSCLK,
                              SDRAM_Base,
                              SDRAM_Bank,
                              SDRAM_CAS_Latency,
                              SDRAM_Refresh_Cnt,
                              SDRAM_Min_Delay_In_ns,
                              SDRAM_Row_Bits,
                              SDRAM_Mem_Width,
                              SDRAM_CLOCK_Period,
                              SDRAM_Read_Burst,
                              SDRAM_Read_Pipe);
   end;

   -------------------------
   -- Initialize_I2C_GPIO --
   -------------------------

   procedure Initialize_I2C_GPIO (Port : in out I2C_Port)
   is
      Id : constant I2C_Port_Id := As_Port_Id (Port);
      Points     : constant GPIO_Points (1 .. 2) :=
                     (if Id = I2C_Id_1 then (PB8, PB9)
                      elsif Id = I2C_Id_3 then (PH7, PH8)
                      else  (PA0, PA0));

   begin
      if Id = I2C_Id_2 or else Id = I2C_Id_4 then
         raise Unknown_Device with
           "This I2C_Port cannot be used on this board";
      end if;

      Enable_Clock (Points);

      Configure_IO (Points,
                    (Mode           => Mode_AF,
                     AF             => GPIO_AF_I2C2_4,
                     AF_Speed       => Speed_25MHz,
                     AF_Output_Type => Open_Drain,
                     Resistors      => Floating));
      Lock (Points);
   end Initialize_I2C_GPIO;

   --------------------------------
   -- Configure_User_Button_GPIO --
   --------------------------------

   procedure Configure_User_Button_GPIO is
   begin
      Enable_Clock (User_Button_Point);
      Configure_IO (User_Button_Point, (Mode_In, Resistors => Floating));
   end Configure_User_Button_GPIO;
begin
   null;
   --Initialize_SDRAM;
end STM32.Board;
