library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

-- ***USER'S RESPONSIBILITY TO NOT READ WHEN EMPTY***
entity circular_buffer_controller is
    generic(Ndata : integer; -- data word bit width
            Naddress : integer); -- address word bit width
    port(
        clock : in std_logic;
        reset : in std_logic;
        wenable : in std_logic; -- write enable
        renable : in std_logic; -- output enable
        full : out std_logic;
        empty : out std_logic
        waddress : out std_logic_vector(Naddress - 1 downto 0);
        raddress : out std_logic_vector(Naddress - 1 downto 0));
end circular_buffer_controller;

architecture behavioral of circular_buffer_controller is
    signal waddress_next : std_logic_vector(Naddress - 1 downto 0);
    signal raddress_next : std_logic_vector(Naddress - 1 downto 0);
    signal full_next : std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset then
                full <= '0';
                waddress <= (others => '0');
                raddress <= (others => '0');
            else -- not reset
                waddress <= waddress_next;
                raddress <= raddress_next;
                full <= full_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    process(wenable,renable,waddress,raddress,full,empty)
      variable raddress_num : unsigned(Naddress - 1 downto 0);
      variable waddress_num : unsigned(Naddress - 1 downto 0);
    begin
      raddress_num := unsigned(raddress);
      waddress_num := unsigned(waddress);
      if wenable and renable then
        raddress_next <= std_logic_vector(raddress_num + 1);
        waddress_next <= std_logic_vector(waddress_num + 1);
        full_next <= full;
      elsif wenable then
        waddress_next <= std_logic_vector(waddress_num + 1);
        if raddress_num = waddress_num then
          raddress_next <= std_logic_vector(raddress_num + 1);
          full_next <= '1';
        elsif raddress_num = (waddress_num + 1) then
          raddress_next <= raddress;
          full_next <= '1';
        else 
          raddress_next <= raddress;
          full_next <= '0';
        end if;
      elsif renable then
        raddress_next <= std_logic_vector(raddress_num + 1);
        waddress_next <= waddress;
        full_next <= '0';
      else -- not wenable or renable
        waddress_next <= waddress;
        raddress_next <= raddress;
        full_next <= full;
      end if; -- wenable renable ifs
    end process;
    -- output
    empty <= '1' when ((waddress = raddress) and (not full)) else '0';
end behavioral;