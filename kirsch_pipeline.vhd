library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity kirsch_pipeline is
  port(
    clk        : in  std_logic;                      
    reset      : in  std_logic;                      
    ppl_en     : in  std_logic;                 
    i_conv_a   : in  unsigned ( 7 downto 0 );
    i_conv_b   : in  unsigned ( 7 downto 0 );
    i_conv_c   : in  unsigned ( 7 downto 0 );
    i_conv_d   : in  unsigned ( 7 downto 0 );
    i_conv_e   : in  unsigned ( 7 downto 0 );
    i_conv_f   : in  unsigned ( 7 downto 0 );
    i_conv_g   : in  unsigned ( 7 downto 0 );
    i_conv_h   : in  unsigned ( 7 downto 0 );
    i_conv_i   : in  unsigned ( 7 downto 0 );
    o_valid    : out std_logic;	                     
    o_edge     : out std_logic;	                     
    o_dir      : out direction_ty
  );  
end entity;


architecture main of kirsch_pipeline is
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

  signal v                      : std_logic_vector( 0 to 3);

  -- pipeline signals

  -- STAGE1
  ---------------------------------------
  signal r1                            : unsigned ( 15 downto 0 );
  signal r2                            : unsigned ( 15 downto 0 );
  signal r3                            : unsigned ( 15 downto 0 );
  signal r4                            : unsigned ( 15 downto 0 );
  signal r5                            : unsigned ( 15 downto 0 );

  signal s1_src1                       : unsigned ( 7 downto 0 );
  signal s1_src2                       : unsigned ( 7 downto 0 );
  signal s1_src3                       : unsigned ( 7 downto 0 );
  signal s1_src4                       : unsigned ( 7 downto 0 );
  signal s1_add1                       : unsigned ( 15 downto 0 );
  signal s1_add2                       : unsigned ( 15 downto 0 );
  signal s1_add3                       : unsigned ( 15 downto 0 );
  signal s1_out                        : unsigned ( 15 downto 0 );

  signal s2_src1                       : unsigned ( 7 downto 0 );
  signal s2_src2                       : unsigned ( 7 downto 0 );
  signal s2_src3                       : unsigned ( 7 downto 0 );
  signal s2_src4                       : unsigned ( 7 downto 0 );
  signal s2_add1                       : unsigned ( 15 downto 0 );
  signal s2_add2                       : unsigned ( 15 downto 0 );
  signal s2_add3                       : unsigned ( 15 downto 0 );
  signal s2_out                        : unsigned ( 15 downto 0 );

  signal s3_src1                       : unsigned ( 7 downto 0 );
  signal s3_src2                       : unsigned ( 7 downto 0 );
  signal s3_max                        : unsigned ( 15 downto 0 );
  signal s3_add                        : unsigned ( 15 downto 0 );
  signal s3_out                        : unsigned ( 15 downto 0 );

  signal s4_src1                       : unsigned ( 7 downto 0 );
  signal s4_src2                       : unsigned ( 7 downto 0 );
  signal s4_src3                       : unsigned ( 7 downto 0 );
  signal s4_src4                       : unsigned ( 7 downto 0 );
  signal s4_add1                       : unsigned ( 15 downto 0 );
  signal s4_add2                       : unsigned ( 15 downto 0 );
  signal s4_max                        : unsigned ( 15 downto 0 );
  signal s4_out                        : unsigned ( 15 downto 0 );

  signal s5_src1                       : unsigned ( 7 downto 0 );
  signal s5_src2                       : unsigned ( 7 downto 0 );
  signal s5_src3                       : unsigned ( 7 downto 0 );
  signal s5_src4                       : unsigned ( 7 downto 0 );
  signal s5_add1                       : unsigned ( 15 downto 0 );
  signal s5_add2                       : unsigned ( 15 downto 0 );
  signal s5_max                        : unsigned ( 15 downto 0 );
  signal s5_out                        : unsigned ( 15 downto 0 );

  -- STAGE2
  ---------------------------------------
  signal r6                            : unsigned ( 15 downto 0 );
  signal r7                            : unsigned ( 15 downto 0 );
  signal r8                            : unsigned ( 15 downto 0 );
  signal r9                            : unsigned ( 15 downto 0 );

  -- combinational signals for arithmetic operations
  signal s6_add1                       : unsigned ( 15 downto 0 );
  signal s6_add2                       : unsigned ( 15 downto 0 );
  signal s6_shift                      : unsigned ( 15 downto 0 );
  signal s6_out                        : unsigned ( 15 downto 0 );

  signal s7_shift                      : unsigned ( 15 downto 0 );
  signal s7_out                        : unsigned ( 15 downto 0 );

  signal s8_shift                      : unsigned ( 15 downto 0 );
  signal s8_out                        : unsigned ( 15 downto 0 );

  signal s9_shift                      : unsigned ( 15 downto 0 );
  signal s9_out                        : unsigned ( 15 downto 0 );

  -- STAGE3
  ---------------------------------------
  signal r10                           : unsigned ( 15 downto 0 );
  signal r11                           : unsigned ( 15 downto 0 );

  signal s10_sub1                      : unsigned ( 15 downto 0 );
  signal s10_sub2                      : unsigned ( 15 downto 0 );
  signal s10_max                       : unsigned ( 15 downto 0 );
  signal s10_out                       : unsigned ( 15 downto 0 );

  signal s11_sub                       : unsigned ( 15 downto 0 );
  signal s11_out                       : unsigned ( 15 downto 0 );

  -- STAGE4
  ---------------------------------------
  signal r12                           : std_logic;
  
  signal s12_max                       : unsigned ( 15 downto 0 );
  signal s12_cmp                       : std_logic;
  signal s12_out                       : std_logic;

begin  

  -- TODO
  -- v(0) <= i_valid;

  -- reg: state machine
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      v(1 to 3) <= (others => '0');
    else
      v(1 to 3) <= v(0 to 2);
    end if;
  end process;

  -- STAGE1
  ---------------------------------------
  s1_src1 <= i_conv_e;
  s1_src2 <= i_conv_f;
  s1_src3 <= i_conv_g;
  s1_src4 <= i_conv_h;

  s2_src1 <= i_conv_a;
  s2_src2 <= i_conv_d;
  s2_src3 <= i_conv_b;
  s2_src4 <= i_conv_c;

  s3_src1 <= i_conv_a;
  s3_src2 <= i_conv_d;

  s4_src1 <= i_conv_d;
  s4_src2 <= i_conv_e;
  s4_src3 <= i_conv_c;
  s4_src4 <= i_conv_f;

  s5_src1 <= i_conv_f;
  s5_src2 <= i_conv_g;
  s5_src3 <= i_conv_e;
  s5_src4 <= i_conv_h;

  -- comb: s1 comb block
  s1_add1 <= b"00000000" & (s1_src1 + s1_src2);
  s1_add2 <= b"00000000" & (s1_src3 + s1_src4);
  s1_add3 <= s1_add1 + s1_add2;
  s1_out  <= s1_add3;
  
  -- comb: s2 comb block
  s2_add1 <= b"00000000" & (s2_src1 + s2_src2);
  s2_add2 <= b"00000000" & (s2_src3 + s2_src4);
  s2_add3 <= s2_add1 + s2_add2;
  s2_out  <= s2_add3;

  -- comb: s3 comb block
  s3_max <= b"00000000" & (s3_src1 + s3_src2);
  s3_add <= s2_add2 + s3_max;
  s3_out <= s3_add;

  -- comb: s4 comb block
  s4_add1 <= b"00000000" & (s4_src1 + s4_src2); 
  s4_max  <= b"00000000" & (s4_src3 + s4_src4);
  s4_add2 <= s4_add1 + s4_max; 
  s4_out  <= s4_add2;

  -- comb: s5 comb block
  s5_add1 <= b"00000000" & (s5_src1 + s5_src2);
  s5_max  <= b"00000000" & (s5_src3 + s5_src4);
  s5_add2 <= s5_add1 + s5_max;
  s5_out  <= s5_add2;

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

  s6_add1  <= r1 + r2;
  s6_shift <= s6_add1 sll 1;
  s6_add2  <= s6_shift + s6_add1;
  s6_out   <= s6_add2;

  -- reg: reg6
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r6 <= (others => '0');
    else
      r6 <= s6_out;
    end if;
  end process;

  s7_shift <= r3 sll 3;
  s7_out   <= s7_shift;
  -- reg: reg7
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r7 <= (others => '0');
    else
      r7 <= s7_out;
    end if;
  end process;

  s8_shift <= r4 sll 3;
  s8_out   <= s8_shift;
  -- reg: reg8
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r8 <= (others => '0');
    else
      r8 <= s8_out;
    end if;
  end process;

  s9_shift <= r5 sll 3;
  s9_out   <= s9_shift;
  -- reg: reg9
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r9 <= (others => '0');
    else
      r9 <= s9_out;
    end if;
  end process;

  -- STAGE3
  ---------------------------------------
  
  s10_sub1 <= r7 - r6;
  s10_sub2 <= r8 - r6;
  s10_max  <= s10_sub1 + s10_sub2;
  s10_out  <= s10_max;
  -- reg: reg10
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r10 <= (others => '0');
    else
      r10 <= s10_out;
    end if;
  end process;

  s11_sub  <= r9 - r6;
  s11_out  <= s11_sub;
  -- reg: reg11
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r11 <= (others => '0');
    else
      r11 <= s11_out;
    end if;
  end process;

  -- STAGE4
  ---------------------------------------

  s12_max  <= r10 + r11;
  s12_cmp  <= '1'  when (s12_max > 383) else '0';
  -- reg: reg12
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r12 <= '0';
    else
      r12 <= s12_cmp;
    end if;
  end process;

  -- drive output 
  o_edge <= r12;

end architecture;

