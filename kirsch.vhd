
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity kirsch is
  port(
    clk        : in  std_logic;                      
    reset      : in  std_logic;                      
    i_valid    : in  std_logic;                 
    i_pixel    : in  unsigned(7 downto 0);
    o_valid    : out std_logic;                 
    o_edge     : out std_logic;	                     
    o_dir      : out direction_ty;
    o_mode     : out mode_ty;
    o_row      : out unsigned(7 downto 0);
    o_col      : out unsigned(7 downto 0);
  );  
end entity;


architecture main of kirsch is
begin  

  signal v              : std_logic_vector( 0 to 2);
  signal r_i            : unsigned ( 7 downto 0 ); 
  signal r_j            : unsigned ( 7 downto 0 ); 
  signal r_m            : unsigned ( 1 downto 0 ); 
  signal r_n            : unsigned ( 1 downto 0 ); 
  
  -- memory signals
  signal  m0_addr               : unsigned( 7 downto 0 );
  signal  m0_i_data, m0_o_data  : std_logic_vector( 7 downto 0 );
  signal  m0_wren               : std_logic;

  signal  m1_addr               : unsigned( 7 downto 0 );
  signal  m1_i_data, m1_o_data  : std_logic_vector( 7 downto 0 );
  signal  m1_wren               : std_logic;

  signal  m2_addr               : unsigned( 7 downto 0 );
  signal  m2_i_data, m2_o_data  : std_logic_vector( 7 downto 0 );
  signal  m2_wren               : std_logic;

end architecture;
