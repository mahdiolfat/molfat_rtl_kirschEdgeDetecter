--
-- TODO:
-- * Go over all TODOs
-- * change MAX return type to unsigned?


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity kirsch_pipeline is
  port(
    clk        : in  std_logic;                      
    reset      : in  std_logic;                      
    i_valid    : in  std_logic;
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
    o_dir      : out direction_ty;
    o_col      : out unsigned ( 7 downto 0 )
  );
end entity;


architecture main of kirsch_pipeline is
  -- TODO: should the input types be unsigned?
  function MAX (a0 : unsigned;
                a1 : unsigned;
                d0 : direction_ty;
                d1 : direction_ty)
    return std_logic_vector
  is
  begin
    -- TODO: calculate derivatives of both 
    -- TODO: how can this be optimized?
    if (a0 > a1) then
      return std_logic_vector(d0) & std_logic_vector(a0);
    elsif (a0 < a1) then
      return std_logic_vector(d1) & std_logic_vector(a1);
    else
      -- a0 == a1
      if (d0 = dir_w or d1 = dir_w) then
        return std_logic_vector(dir_w)   & std_logic_vector(a0);
      elsif (d0 = dir_nw or d1 = dir_nw) then
        return std_logic_vector(dir_nw)  & std_logic_vector(a0);
      elsif (d0 = dir_n or d1 = dir_n) then
        return std_logic_vector(dir_n)   & std_logic_vector(a0);
      elsif (d0 = dir_ne or d1 = dir_ne) then
        return std_logic_vector(dir_ne)  & std_logic_vector(a0);
      elsif (d0 = dir_e or d1 = dir_e) then
        return std_logic_vector(dir_e)   & std_logic_vector(a0);
      elsif (d0 = dir_se or d1 = dir_se) then
        return std_logic_vector(dir_se)  & std_logic_vector(a0);
      elsif (d0 = dir_s or d1 = dir_s) then
        return std_logic_vector(dir_s)   & std_logic_vector(a0);
      else
        return std_logic_vector(dir_sw)  & std_logic_vector(a0);
      end if;

      -- case d0 is 
      --   -- from highest priority to lowest priority:
      --   -- W(001), NW(100), N(010), NE(110), E(000), SE(101), S(011), SW(111)
      --   when dir_w  => return std_logic_vector(dir_w)  & std_logic_vector(a0);
      --   when dir_nw => return std_logic_vector(dir_nw) & std_logic_vector(a0);
      --   when dir_n  => return std_logic_vector(dir_n)  & std_logic_vector(a0);
      --   when dir_ne => return std_logic_vector(dir_ne) & std_logic_vector(a0);
      --   when dir_e  => return std_logic_vector(dir_e)  & std_logic_vector(a0);
      --   when dir_se => return std_logic_vector(dir_se) & std_logic_vector(a0);
      --   when dir_s  => return std_logic_vector(dir_s)  & std_logic_vector(a0);
      --   when dir_sw => return std_logic_vector(dir_sw) & std_logic_vector(a0);
      --   -- TODO: how to handle this "others" case; should never get here
      --   when others => return std_logic_vector(d0) & std_logic_vector(a0);
      -- end case;

    end if;
  end function;

  signal v                      : std_logic_vector( 0 to 3 );

  -- pipeline signals

  -- STAGE1
  ---------------------------------------
  signal r1                            : unsigned ( 15 downto 0 );
  signal r2                            : unsigned ( 15 downto 0 );
  signal r3                            : unsigned ( 15 downto 0 );
  signal r4                            : unsigned ( 15 downto 0 );
  signal r5                            : unsigned ( 15 downto 0 );
  signal r6                            : unsigned ( 15 downto 0 );

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

  signal s6_src1                       : unsigned ( 7 downto 0 );
  signal s6_src2                       : unsigned ( 7 downto 0 );
  signal s6_src3                       : unsigned ( 7 downto 0 );
  signal s6_src4                       : unsigned ( 7 downto 0 );
  signal s6_add1                       : unsigned ( 15 downto 0 );
  signal s6_add2                       : unsigned ( 15 downto 0 );
  signal s6_max                        : unsigned ( 15 downto 0 );
  signal s6_out                        : unsigned ( 15 downto 0 );

  -- STAGE2
  ---------------------------------------
  signal r7                            : unsigned ( 15 downto 0 );
  signal r8                            : unsigned ( 15 downto 0 );
  signal r9                            : unsigned ( 15 downto 0 );
  signal r10                           : unsigned ( 15 downto 0 );
  signal r11                           : unsigned ( 15 downto 0 );

  -- combinational signals for arithmetic operations
  signal s7_add1                       : unsigned ( 15 downto 0 );
  signal s7_add2                       : unsigned ( 15 downto 0 );
  signal s7_shift                      : unsigned ( 15 downto 0 );
  signal s7_out                        : unsigned ( 15 downto 0 );

  signal s8_shift                      : unsigned ( 15 downto 0 );
  signal s8_out                        : unsigned ( 15 downto 0 );

  signal s9_shift                      : unsigned ( 15 downto 0 );
  signal s9_out                        : unsigned ( 15 downto 0 );

  signal s10_shift                     : unsigned ( 15 downto 0 );
  signal s10_out                       : unsigned ( 15 downto 0 );

  signal s11_shift                     : unsigned ( 15 downto 0 );
  signal s11_out                       : unsigned ( 15 downto 0 );

  -- STAGE3
  ---------------------------------------
  signal r12                           : unsigned ( 15 downto 0 );
  signal r13                           : unsigned ( 15 downto 0 );

  signal s12_sub1                      : unsigned ( 15 downto 0 );
  signal s12_sub2                      : unsigned ( 15 downto 0 );
  signal s12_max                       : unsigned ( 15 downto 0 );
  signal s12_out                       : unsigned ( 15 downto 0 );

  signal s13_sub1                      : unsigned ( 15 downto 0 );
  signal s13_sub2                      : unsigned ( 15 downto 0 );
  signal s13_max                       : unsigned ( 15 downto 0 );
  signal s13_out                       : unsigned ( 15 downto 0 );

  -- STAGE4
  ---------------------------------------
  signal r14                           : std_logic;
  
  signal s14_src1                      : unsigned ( 15 downto 0 );
  signal s14_src2                      : unsigned ( 15 downto 0 );
  signal s14_max                       : unsigned ( 15 downto 0 );
  signal s14_cmp                       : std_logic;
  signal s14_out                       : std_logic;

begin  

  v(0) <= i_valid;

  -- reg: state machine
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      v(1) <= '0';
    else
      v(1) <= v(0);
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

  s6_src1 <= i_conv_h;
  s6_src2 <= i_conv_a;
  s6_src3 <= i_conv_g;
  s6_src4 <= i_conv_b;

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
  s3_max <= unsigned(MAX(s3_src1, s3_src2, dir_n, dir_ne));
  s3_add <= s2_add2 + s3_max;
  s3_out <= s3_add;

  -- comb: s4 comb block
  s4_add1 <= b"00000000" & (s4_src1 + s4_src2); 
  s4_max  <= unsigned(MAX(s4_src3, s4_src4, dir_e, dir_se));
  s4_add2 <= s4_add1 + s4_max; 
  s4_out  <= s4_add2;

  -- comb: s5 comb block
  s5_add1 <= b"00000000" & (s5_src1 + s5_src2);
  s5_max  <= unsigned(MAX(s5_src3, s5_src4, dir_s, dir_sw));
  s5_add2 <= s5_add1 + s5_max;
  s5_out  <= s5_add2;

  -- comb: s6 comb block
  s6_add1 <= b"00000000" & (s6_src1 + s6_src2);
  s6_max  <= unsigned(MAX(s6_src3, s6_src4, dir_w, dir_nw));
  s6_add2 <= s6_add1 + s6_max;
  s6_out  <= s6_add2;

  -- reg: reg1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r1 <= (others => '0');
    elsif v(0) = '1' then
      r1 <= s1_out;
    end if;
  end process;

  -- reg: reg2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r2 <= (others => '0');
    elsif v(0) = '1' then
      r2 <= s2_out;
    end if;
  end process;

  -- reg: reg3
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r3 <= (others => '0');
    elsif v(0) = '1' then
      r3 <= s3_out;
    end if;
  end process;

  -- reg: reg4
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r4 <= (others => '0');
    elsif v(0) = '1' then
      r4 <= s4_out;
    end if;
  end process;

  -- reg: reg5
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r5 <= (others => '0');
    elsif v(0) = '1' then
      r5 <= s5_out;
    end if;
  end process;

  -- reg: reg6
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r6 <= (others => '0');
    elsif v(0) = '1' then
      r6 <= s6_out;
    end if;
  end process;

  -- STAGE2
  ---------------------------------------

  s7_add1  <= r1 + r2;
  s7_shift <= s7_add1 sll 1;
  s7_add2  <= s7_shift + s7_add1;
  s7_out   <= s7_add2;

  -- reg: reg7
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r7 <= (others => '0');
    elsif v(1) = '1' then
      r7 <= s7_out;
    end if;
  end process;

  s8_shift <= r3 sll 3;
  s8_out   <= s8_shift;
  -- reg: reg8
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r8 <= (others => '0');
    elsif v(1) = '1' then
      r8 <= s8_out;
    end if;
  end process;

  s9_shift <= r4 sll 3;
  s9_out   <= s9_shift;
  -- reg: reg9
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r9 <= (others => '0');
    elsif v(1) = '1' then
      r9 <= s9_out;
    end if;
  end process;

  s10_shift <= r5 sll 3;
  s10_out   <= s10_shift;
  -- reg: reg10
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r10 <= (others => '0');
    elsif v(1) = '1' then
      r10 <= s10_out;
    end if;
  end process;

  s11_shift <= r6 sll 3;
  s11_out   <= s11_shift;
  -- reg: reg11
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r11 <= (others => '0');
    elsif v(1) = '1' then
      r11 <= s11_out;
    end if;
  end process;

  -- STAGE3
  ---------------------------------------
  
  s12_sub1 <= r8 - r7;
  s12_sub2 <= r9 - r7;
  s12_max  <= unsigned(MAX(s12_sub1, s12_sub2, dir_n, dir_ne));
  s12_out  <= s12_max;
  -- reg: reg12
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r12 <= (others => '0');
    elsif v(2) = '1' then
      r12 <= s12_out;
    end if;
  end process;

  s13_sub1 <= r10 - r7;
  s13_sub2 <= r11 - r7;
  s13_max  <= unsigned(MAX(s13_sub1, s13_sub2, dir_s, dir_sw));
  s13_out  <= s13_max;
  -- reg: reg13
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r13 <= (others => '0');
    elsif v(2) = '1' then
      r13 <= s13_out;
    end if;
  end process;

  -- STAGE4
  ---------------------------------------

  s14_src1 <= r12;
  s14_src2 <= r13;
  s14_max  <= unsigned(MAX(s14_src1, s14_src2, dir_n, dir_ne));
  s14_cmp  <= '1'  when (s14_max > 383) else '0';
  -- reg: reg14
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r14 <= '0';
    elsif v(3) = '1' then
      r14 <= s14_cmp;
    end if;
  end process;

  -- drive output 
  o_edge <= r14;

end architecture;

