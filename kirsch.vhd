
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

  signal v                      : std_logic_vector( 0 to 2);
  signal r_i                    : unsigned ( 7 downto 0 ); 
  signal r_j                    : unsigned ( 7 downto 0 ); 
  signal r_m                    : unsigned ( 1 downto 0 ); 
  signal r_n                    : unsigned ( 1 downto 0 ); 

  -- registers

  -- registered pixel input
  signal r_pixel                : unsigned ( 7 downto 0 );

  -- convovlution table 
  signal r1                            : unsigned ( 8 downto 0 );
  signal r2                            : unsigned ( 8 downto 0 );
  signal r3                            : unsigned ( 8 downto 0 );
  signal r4                            : unsigned ( 7 downto 0 );
  signal r5                            : unsigned ( 7 downto 0 );
  signal r6                            : unsigned ( 7 downto 0 );
  signal r7                            : unsigned ( 7 downto 0 );
  signal r8                            : unsigned ( 7 downto 0 );
  signal r9                            : unsigned ( 7 downto 0 );

  signal r10                           : unsigned ( 9 downto 0 );
  signal r11                           : unsigned ( 10 downto 0 );
  signal r12                           : unsigned ( 11 downto 0 );
  signal r13                           : unsigned ( 9 downto 0 );
  signal r14                           : unsigned ( 7 downto 0 );
  signal r15                           : unsigned ( 7 downto 0 );
  signal r16                           : unsigned ( 7 downto 0 );
  signal r17                           : unsigned ( 7 downto 0 );
  signal r18                           : unsigned ( 11 downto 0 );
  signal r19                           : unsigned ( 11 downto 0 );
  signal r20                           : unsigned ( 12 downto 0 );
  signal r21                           : unsigned ( 9 downto 0 );
  signal r22                           : unsigned ( 12 downto 0 );
  signal r23                           : unsigned ( 12 downto 0 ); 
  signal r24                           : unsigned ( 12 downto 0 );
  
  -- signals for reading matrix
  signal r_mem_idx              : unsigned ( 1 downto 0 );

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

  -- instantiate 3 memory rows
  m0: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m0_addr,
      i_data    => m0_i_data,
      o_data    => m0_o_data,
      wren      => m0_wren
    );

  m1: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m1_addr,
      i_data    => m1_i_data,
      o_data    => m1_o_data,
      wren      => m1_wren
    );

  m2: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m2_addr,
      i_data    => m2_i_data,
      o_data    => m2_o_data,
      wren      => m2_wren
    );

end architecture;
