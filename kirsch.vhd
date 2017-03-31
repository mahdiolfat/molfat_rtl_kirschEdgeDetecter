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
  signal r1                            : unsigned ( 15 downto 0 );
  signal r2                            : unsigned ( 15 downto 0 );
  signal r3                            : unsigned ( 15 downto 0 );
  signal r4                            : unsigned ( 15 downto 0 );
  signal r5                            : unsigned ( 15 downto 0 );

  signal r6                            : unsigned ( 15 downto 0 );
  signal r7                            : unsigned ( 15 downto 0 );
  signal r8                            : unsigned ( 15 downto 0 );
  signal r9                            : unsigned ( 15 downto 0 );
  signal r10                           : unsigned ( 15 downto 0 );

  signal r11                           : unsigned ( 15 downto 0 );
  signal r12                           : unsigned ( 15 downto 0 );
  signal r13                           : unsigned ( 15 downto 0 );

  signal r14                           : std_logic;
  
  -- combinational signals for arithmetic operations
  signal s1_src1                       : unsigned ( 15 downto 0 );
  signal s1_src2                       : unsigned ( 15 downto 0 );
  signal s1_src3                       : unsigned ( 15 downto 0 );
  signal s1_src4                       : unsigned ( 15 downto 0 );
  signal s1_add1                       : unsigned ( 15 downto 0 );
  signal s1_add2                       : unsigned ( 15 downto 0 );
  signal s1_out                        : unsigned ( 15 downto 0 );

  signal s2_src1                       : unsigned ( 15 downto 0 );
  signal s2_src2                       : unsigned ( 15 downto 0 );
  signal s2_src3                       : unsigned ( 15 downto 0 );
  signal s2_src4                       : unsigned ( 15 downto 0 );
  signal s2_add1                       : unsigned ( 15 downto 0 );
  signal s2_add2                       : unsigned ( 15 downto 0 );
  signal s2_out                        : unsigned ( 15 downto 0 );

  signal s3_src1                       : unsigned ( 15 downto 0 );
  signal s3_src2                       : unsigned ( 15 downto 0 );
  signal s3_max                        : unsigned ( 15 downto 0 );
  signal s3_out                        : unsigned ( 15 downto 0 );

  signal s4_src1                       : unsigned ( 15 downto 0 );
  signal s4_src2                       : unsigned ( 15 downto 0 );
  signal s4_src3                       : unsigned ( 15 downto 0 );
  signal s4_src4                       : unsigned ( 15 downto 0 );
  signal s4_add                        : unsigned ( 15 downto 0 );
  signal s4_max                        : unsigned ( 15 downto 0 );
  signal s4_out                        : unsigned ( 15 downto 0 );

  signal s5_src1                       : unsigned ( 15 downto 0 );
  signal s5_src2                       : unsigned ( 15 downto 0 );
  signal s5_src3                       : unsigned ( 15 downto 0 );
  signal s5_src4                       : unsigned ( 15 downto 0 );
  signal s5_add                        : unsigned ( 15 downto 0 );
  signal s5_max                        : unsigned ( 15 downto 0 );
  signal s5_out                        : unsigned ( 15 downto 0 );

  signal s6_add                        : unsigned ( 15 downto 0 );

  signal s7_add                        : unsigned ( 15 downto 0 );

  signal s8_max1                        : unsigned ( 15 downto 0 );
  signal s8_max2                        : unsigned ( 15 downto 0 );
  -- signals for reading matrix
  signal r_mem_idx                     : unsigned ( 1 downto 0 );

  -- memory signals
  signal m0_addr                      : unsigned( 7 downto 0 );
  signal m0_i_data, m0_o_data         : std_logic_vector( 7 downto 0 );
  signal m0_wren                      : std_logic;

  signal m1_addr                      : unsigned( 7 downto 0 );
  signal m1_i_data, m1_o_data         : std_logic_vector( 7 downto 0 );
  signal m1_wren                      : std_logic;

  signal m2_addr                      : unsigned( 7 downto 0 );
  signal m2_i_data, m2_o_data         : std_logic_vector( 7 downto 0 );
  signal m2_wren                      : std_logic;

  -- TODO: should the input types be unsigned?
  function MAX ( a : unsigned; b : unsigned )
    return std_logic_vector
  is
  begin
    if (a > b) then
      return std_logic_vector(a);
    else
      return std_logic_vector(b);
    end if;
  end function;

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

  -- STAGE1
  ---------------------------------------

  -- comb: s1 comb block
  s1_add1 <= s1_src1 + s1_src2;
  s1_add2 <= s1_src3 + s1_src4;
  process (reset, s1_add1, s1_add2) begin
    if reset = '1' then
      s1_out <= (others => '0');
    else
      s1_out <= s1_add1 + s1_add2;
    end if;
  end process;
  
  -- comb: s2 comb block
  s2_add1 <= s2_src1 + s2_src2;
  s2_add2 <= s2_src3 + s2_src4;
  process (reset, s2_add1, s2_add2) begin
    if reset = '1' then
      s2_out <= (others => '0');
    else
      s2_out <= s2_add1 + s2_add2;
    end if;
  end process;

  -- comb: s3 comb block
  s3_max <= s3_src1 + s3_src2;
  process (reset, s3_max, s2_add2) begin
    if reset = '1' then
      s3_out <= (others => '0');
    else
      s3_out <= s3_max + s2_add2;
    end if;
  end process;

  -- comb: s4 comb block
  s4_src1 <= s3_src2;
  s4_src2 <= s1_src1;
  s4_src3 <= s2_src4;
  s4_src4 <= s1_src2;

  s4_add <= s4_src1 + s4_src2; 
  s4_max <= s4_src3 + s4_src4;

  process (reset, s4_max, s4_add) begin
    if reset = '1' then
      s4_out <= (others => '0');
    else
      s4_out <= s4_max + s4_add;
    end if;
  end process;

  -- comb: s5 comb block
  s5_src1 <= s4_src2;
  s5_src2 <= s1_src3;
  s5_src3 <= s4_src2;
  s5_src4 <= s1_src4;

  s5_add <= s5_src1 + s5_src2;
  s5_max <= s5_src3 + s5_src4;

  process (reset, s5_max, s5_add) begin
    if reset = '1' then
      s5_out <= (others => '0');
    else
      s5_out <= s5_max + s5_add;
    end if;
  end process;

  -- reg: reg1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r1 <= (others => '0');
    else
      r1 <= s1_out;
    end if;
  end process;

  -- reg: reg2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r2 <= (others => '0');
    else
      r2 <= s2_out;
    end if;
  end process;

  -- reg: reg3
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r3 <= (others => '0');
    else
      r3 <= s3_out;
    end if;
  end process;

  -- reg: reg4
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r4 <= (others => '0');
    else
      r4 <= s4_out;
    end if;
  end process;

  -- reg: reg5
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r5 <= (others => '0');
    else
      r5 <= s5_out;
    end if;
  end process;

  -- STAGE2
  ---------------------------------------

  s6_add <= r1 + r2;
  -- reg: reg6
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r6 <= (others => '0');
    else
      r6 <= s6_add;
    end if;
  end process;

  -- reg: reg7
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r7 <= (others => '0');
    else
      r7 <= s6_add sll 1;
    end if;
  end process;

  -- reg: reg8
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r8 <= (others => '0');
    else
      r8 <= r3 sll 3;
    end if;
  end process;

  -- reg: reg9
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r9 <= (others => '0');
    else
      r9 <= r4 sll 3;
    end if;
  end process;
  
  -- reg: reg10
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r10 <= (others => '0');
    else
      r10 <= r5 sll 3;
    end if;
  end process;

  -- STAGE3
  ---------------------------------------

  s7_add <= r6 + r7;
  
  -- reg: reg11
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r11 <= (others => '0');
    else
      r11 <= r8 - s7_add;
    end if;
  end process;

  -- reg: reg12
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r12 <= (others => '0');
    else
      r12 <= r9 - s7_add;
    end if;
  end process;

  -- reg: reg13
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r13 <= (others => '0');
    else
      r13 <= r10 - s7_add;
    end if;
  end process;

  -- STAGE4
  ---------------------------------------
  s8_max1 <= r11 + r12;
  s8_max2 <= s8_max1 + r13;

  -- reg: reg14
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r14 <= (others => '0');
    else
      if s8_max2 > 383 then
        r14 <= '1';
      else 
        r14 <= '0';
      end if;
    end if;
  end process;

  -- TODO: assign this
  -- o_edge <= r14;
  ---------------------------------------


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
