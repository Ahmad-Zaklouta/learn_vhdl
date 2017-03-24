library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity tb_memory is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_memory is
    signal clock : std_logic := '0';
    signal wenable : std_logic := '0';
    signal renable : std_logic := '0';
    signal waddress : std_logic_vector(7 downto 0) := "00000000";
    signal raddress : std_logic_vector(7 downto 0) := "00000000";
    signal data_in : std_logic_vector(7 downto 0) := "00000000";
    signal data_out : std_logic_vector(7 downto 0) := "00000000";
begin
  mem : entity work.two_port_memory port map (clock => clock,
                                    wenable => wenable, renable => renable,
                                    waddress => waddress, raddress => raddress,
                                    data_in => data_in, data_out => data_out
                                 );

  main : process
    procedure fill_up_mem is
    begin
      wenable <= '0';
      renable <= '0';
      for i in 0 to 255 loop
        wait until rising_edge(clock);
        wenable <= '1';
        waddress <= std_logic_vector(to_unsigned(i,waddress'length));
        data_in <= (others => '0');
      end loop;
      wenable <= '0';
      renable <= '0';
    end procedure fill_up_mem;
    procedure read_out_mem is
    begin
      for i in 0 to 255 loop
        wait until rising_edge(clock);
        renable <= '1';
        raddress <= std_logic_vector(to_unsigned(i,waddress'length));
        log("Memory address " & to_string(i) & ":" & to_string(data_out));
      end loop;
    end procedure read_out_mem;
  begin
    logger_init(display_format => level);
    --logger_init(display_format => verbose);
    --enable_pass_msg;
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("fill_up_mem") then
        fill_up_mem;
        check(true,"Failing check");
      elsif run("fill_up_mem_read_out") then
        fill_up_mem;
        read_out_mem;
        check(true,"Failing check");
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock <= not clock after 25 ns;
  test_runner_watchdog(runner, 1 ms);
end architecture;