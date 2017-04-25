library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem8x256_1rw is
  port (
    clk     : in  std_logic;
    addr    : in  std_logic_vector( 7 downto 0 );
    i_data  : in  std_logic_vector( 7 downto 0 );
    o_data  : out std_logic_vector( 7 downto 0 );
    wren    : in  std_logic
  ); 
end;     


architecture main of mem8x256_1rw is

  -- need component declaration until have vhdl library of mem components
  component SRAM8x256_1rw is
    port (
      a          : in  std_logic_vector( 7 downto 0 );
      ce         : in  std_logic;
      web        : in  std_logic;
      oeb        : in  std_logic;
      csb        : in  std_logic;
      i          : in  std_logic_vector( 7 downto 0 );
      o          : out std_logic_vector( 7 downto 0 )
    );
  end component;

  signal n_sel
       , n_wren
       : std_logic;

  constant c0 : std_logic := '0';

begin
  
  n_sel  <= '0';
  n_wren <= not wren;

  prim_ram : SRAM8x256_1rw port map
    (a   => addr,
     ce  => clk,
     web => n_wren,
     oeb => c0,
     csb => n_sel,
     i   => i_data,
     o   => o_data
   );
          
end;

