
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
    o_col      : out unsigned(7 downto 0)
  );  
end entity;


architecture main of kirsch is
  -- A function to rotate left (rol) a vector by n bits
  function "rol" ( a : std_logic_vector; n : natural )
    return std_logic_vector
  is
  begin
    return std_logic_vector( unsigned(a) rol n );
  end function;

  signal v              : std_logic_vector( 0 to 2);
  signal r_i            : unsigned ( 7 downto 0 ); 
  signal r_j            : unsigned ( 7 downto 0 ); 
  signal r_m            : unsigned ( 1 downto 0 ); 
  signal r_n            : unsigned ( 1 downto 0 ); 

  signal r_pixel        : unsigned ( 7 downto 0 );
  
  -- signals for reading matrix
  signal r_mem_idx      : unsigned ( 1 downto 0 );

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

begin  

  v(0) <= i_valid;

  -- reg: state machine
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      v(1 to 2) <= (others => '0');
    else
      v(1 to 2) <= v(0 to 1);
    end if;
  end process;

  -- comb: memory wren
  process (reset, v, r_mem_idx) begin
    if reset = '1' then
      m0_wren <= '0';
      m1_wren <= '0'; 
      m2_wren <= '0'; 
    end if;
  end process;

  -- reg: registering input data
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r_pixel <= (others => '0');
    elsif v(0) = '1' then
      r_pixel <= i_pixel;
    end if;
  end process;

end architecture;
