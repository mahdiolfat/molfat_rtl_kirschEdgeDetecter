------------------------------------------------------------------------
--  test bench
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem8x256_1rw_tb is
end entity;

------------------------------------------------------------------------

architecture main of mem8x256_1rw_tb is

  constant addr_width : natural := 8;
  constant data_width : natural := 8;
  constant clk_period : time    := 10 ns;
  
  signal clk                      : std_logic;
  signal addr       : unsigned ( addr_width - 1 downto 0);
  signal i_data, o_data : std_logic_vector ( data_width - 1 downto 0);
  signal wren       : std_logic;
     
  type    nat_vector is array( natural range <> ) of natural;    
   
  constant d1 : nat_vector := (1, 3, 5, 7, 9 );
 
  function to_data( n : natural ) return std_logic_vector is
  begin
    return std_logic_vector( to_unsigned( n , data_width ) );
  end function;
  
  function to_addr( n : natural ) return unsigned is
  begin
    return to_unsigned( n , addr_width );
  end function;
  
begin

  ------------------------------------------------------------
  
  process begin
    clk <='0';
    wait for clk_period/2;
    loop
      clk <='0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end loop;
  end process;
 
  ------------------------------------------------------------
  --  write data to memoroy
 
 process begin
   wait for 5 * clk_period;
   
   wren <= '1';
   
   --------------------------------------------------
   -- write data; read immediately
   
   for i in d1'range loop
     wait until rising_edge (clk);
     wait for 0.1 * clk_period;
     wren <= '1';
     i_data <= to_data( d1(i) );
     addr   <= to_addr( d1(i) + 10 );
     wait for clk_period;
     wren <= '0';
     wait for clk_period;
   end loop;

   --------------------------------------------------
   -- read data that was previously written
   
   wren   <= '0';
   addr   <= ( others => 'X' );
   i_data <= ( others => 'X' );
     
   for i in d1'range loop
     wait until rising_edge(clk);  
     wait for 0.1 * clk_period;
     addr   <= to_addr( d1(i) + 10 );
   end loop;
   
   --------------------------------------------------
     
   wren   <= '0';
   addr   <= ( others => 'X' );
   i_data <= ( others => 'X' );
     
   wait for clk_period;
   
   for i in d1'range loop
     wait until rising_edge (clk);
     wait for 0.1 * clk_period;
     wren   <= '1';
     i_data <= to_data( d1(i) );
     addr   <= to_addr( 2 ** addr_width - 1 - d1(i) );
   end loop;

   addr <= ( others => 'X' );
   i_data <= ( others => 'X' );
   wren <= '0';
   wait for clk_period;
   
   for i in d1'range loop
     wait until rising_edge(clk);  
     wait for 0.1 * clk_period;
     addr   <= to_addr( 2 ** addr_width - 1 - d1(i) );
   end loop;
   
   wait;
   
 end process;
  
 -----------------------------------------
   
  uut: entity work.mem8x256_1rw
    port map (
      clk      => clk,
      addr     => addr,
      i_data   => i_data,
      o_data   => o_data,
      wren     => wren
    );
 
end architecture;
------------------------------------------------------------------------

