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
    o_dir      : out direction_ty
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
    end if;
  end function;

  function MAX (a0 : signed;
                a1 : signed;
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

  signal rd1_s1                        : direction_ty;
  signal rd2_s1                        : direction_ty;
  signal rd3_s1                        : direction_ty;
  signal rd4_s1                        : direction_ty;

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
  signal s3_max                        : unsigned ( 18 downto 0 );
  signal s3_dir                        : direction_ty;
  signal s3_add                        : unsigned ( 15 downto 0 );
  signal s3_out                        : unsigned ( 15 downto 0 );

  signal s4_src1                       : unsigned ( 7 downto 0 );
  signal s4_src2                       : unsigned ( 7 downto 0 );
  signal s4_src3                       : unsigned ( 7 downto 0 );
  signal s4_src4                       : unsigned ( 7 downto 0 );
  signal s4_add1                       : unsigned ( 15 downto 0 );
  signal s4_add2                       : unsigned ( 15 downto 0 );
  signal s4_max                        : unsigned ( 18 downto 0 );
  signal s4_dir                        : direction_ty;
  signal s4_out                        : unsigned ( 15 downto 0 );

  signal s5_src1                       : unsigned ( 7 downto 0 );
  signal s5_src2                       : unsigned ( 7 downto 0 );
  signal s5_src3                       : unsigned ( 7 downto 0 );
  signal s5_src4                       : unsigned ( 7 downto 0 );
  signal s5_add1                       : unsigned ( 15 downto 0 );
  signal s5_add2                       : unsigned ( 15 downto 0 );
  signal s5_max                        : unsigned ( 18 downto 0 );
  signal s5_dir                        : direction_ty;
  signal s5_out                        : unsigned ( 15 downto 0 );

  signal s6_src1                       : unsigned ( 7 downto 0 );
  signal s6_src2                       : unsigned ( 7 downto 0 );
  signal s6_src3                       : unsigned ( 7 downto 0 );
  signal s6_src4                       : unsigned ( 7 downto 0 );
  signal s6_add1                       : unsigned ( 15 downto 0 );
  signal s6_add2                       : unsigned ( 15 downto 0 );
  signal s6_max                        : unsigned ( 18 downto 0 );
  signal s6_dir                        : direction_ty;
  signal s6_out                        : unsigned ( 15 downto 0 );

  -- STAGE2
  ---------------------------------------
  signal r7                            : unsigned ( 15 downto 0 );
  signal r8                            : unsigned ( 15 downto 0 );
  signal r9                            : unsigned ( 15 downto 0 );
  signal r10                           : unsigned ( 15 downto 0 );
  signal r11                           : unsigned ( 15 downto 0 );

  signal rd1_s2                        : direction_ty;
  signal rd2_s2                        : direction_ty;
  signal rd3_s2                        : direction_ty;
  signal rd4_s2                        : direction_ty;

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
  signal r12                           : signed ( 18 downto 0 );
  signal r13                           : signed ( 18 downto 0 );

  signal s12_sub1                      : signed ( 15 downto 0 );
  signal s12_sub2                      : signed ( 15 downto 0 );
  signal s12_max                       : signed ( 18 downto 0 );
  signal s12_maxVal                    : signed ( 15 downto 0 ); 
  signal s12_maxDir                    : direction_ty; 
  --signal s12_out                       : unsigned ( 15 downto 0 );

  signal s13_sub1                      : signed ( 15 downto 0 );
  signal s13_sub2                      : signed ( 15 downto 0 );
  signal s13_max                       : signed ( 18 downto 0 );
  signal s13_maxVal                    : signed ( 15 downto 0 ); 
  signal s13_maxDir                    : direction_ty; 
  --signal s13_out                       : unsigned ( 15 downto 0 );

  -- STAGE4
  ---------------------------------------
  signal r14                           : std_logic;
  
  signal s14_src1                      : signed ( 15 downto 0 );
  signal s14_src2                      : signed ( 15 downto 0 );
  signal s14_src3                      : direction_ty; 
  signal s14_src4                      : direction_ty; 
  signal s14_max                       : signed ( 18 downto 0 );
  signal s14_maxVal                    : signed ( 15 downto 0 ); 
  signal s14_maxDir                    : direction_ty; 
  signal s14_cmp                       : std_logic;

begin  

  v(0) <= i_valid;

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

  s6_src1 <= i_conv_h;
  s6_src2 <= i_conv_a;
  s6_src3 <= i_conv_g;
  s6_src4 <= i_conv_b;

  -- comb: s1 comb block
  s1_add1 <= (b"00000000" & s1_src1) + (b"00000000" & s1_src2);
  s1_add2 <= (b"00000000" & s1_src3) + (b"00000000" & s1_src4);
  s1_add3 <= s1_add1 + s1_add2;
  s1_out  <= s1_add3;
  
  -- comb: s2 comb block
  -- TODO:
  s2_add1 <= (b"00000000" & s2_src1) + (b"00000000" & s2_src2);
  s2_add2 <= (b"00000000" & s2_src3) + (b"00000000" & s2_src4);
  s2_add3 <= s2_add1 + s2_add2;
  s2_out  <= s2_add3;

  -- comb: s3 comb block
  s3_max <= b"00000000" & unsigned(MAX(s3_src1, s3_src2, dir_n, dir_ne));
  s3_add <= s2_add2 + (b"00000000" & s3_max(7 downto 0));
  s3_out <= s3_add;

  -- comb: s4 comb block
  s4_add1 <= (b"00000000" & s4_src1) + (b"00000000" & s4_src2); 
  s4_max  <= b"00000000" & unsigned(MAX(s4_src3, s4_src4, dir_e, dir_se));
  s4_add2 <= s4_add1 + (b"00000000" & s4_max(7 downto 0)); 
  s4_out  <= s4_add2;

  -- comb: s5 comb block
  s5_add1 <= (b"00000000" & s5_src1) + (b"00000000" & s5_src2);
  s5_max  <= b"00000000" & unsigned(MAX(s5_src3, s5_src4, dir_s, dir_sw));
  s5_add2 <= s5_add1 + (b"00000000" & s5_max(7 downto 0));
  s5_out  <= s5_add2;

  -- comb: s6 comb block
  s6_add1 <= (b"00000000" & s6_src1) + (b"00000000" & s6_src2);
  s6_max  <= b"00000000" & unsigned(MAX(s6_src3, s6_src4, dir_w, dir_nw));
  s6_add2 <= s6_add1 + (b"00000000" & s6_max(7 downto 0));
  s6_out  <= s6_add2;

  -- reg: reg dir1 stage 1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd1_s1 <= (others => '0');
    elsif v(0) = '1' then
      rd1_s1 <= direction_ty(s3_max(10 downto 8));
    end if;
  end process;

  -- reg: reg dir2 stage 1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd2_s1 <= (others => '0');
    elsif v(0) = '1' then
      rd2_s1 <= direction_ty(s4_max(10 downto 8));
    end if;
  end process;

  -- reg: reg dir3 stage 1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd3_s1 <= (others => '0');
    elsif v(0) = '1' then
      rd3_s1 <= direction_ty(s5_max(10 downto 8));
    end if;
  end process;

  -- reg: reg dir4 stage 1
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd4_s1 <= (others => '0');
    elsif v(0) = '1' then
      rd4_s1 <= direction_ty(s6_max(10 downto 8));
    end if;
  end process;

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

  -- reg: reg dir1 stage 2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd1_s2 <= (others => '0');
    elsif v(1) = '1' then
      rd1_s2 <= rd1_s1;
    end if;
  end process;

  -- reg: reg dir2 stage 2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd2_s2 <= (others => '0');
    elsif v(1) = '1' then
      rd2_s2 <= rd2_s1;
    end if;
  end process;

  -- reg: reg dir3 stage 2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd3_s2 <= (others => '0');
    elsif v(1) = '1' then
      rd3_s2 <= rd3_s1;
    end if;
  end process;

  -- reg: reg dir4 stage 2
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      rd4_s2 <= (others => '0');
    elsif v(1) = '1' then
      rd4_s2 <= rd4_s1;
    end if;
  end process;

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
  
  s12_sub1 <= signed(r8 - r7);
  s12_sub2 <= signed(r9 - r7);
  s12_max  <= signed(MAX(s12_sub1, s12_sub2, rd1_s2, rd2_s2));
  s12_maxVal <= s12_max(15 downto 0);
  s12_maxDir <= direction_ty(s12_max(18 downto 16));
  -- s12_out  <= s12_max(15 downto 0);
  -- reg: reg12
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r12 <= (others => '0');
    elsif v(2) = '1' then
      r12 <= s12_max;
    end if;
  end process;

  s13_sub1 <= signed(r10 - r7);
  s13_sub2 <= signed(r11 - r7);
  s13_max  <= signed(MAX(s13_sub1, s13_sub2, rd3_s2, rd4_s2));
  s13_maxVal <= s13_max(15 downto 0);
  s13_maxDir <= direction_ty(s13_max(18 downto 16));
  --s13_out  <= s13_max(15 downto 0);
  -- reg: reg13
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r13 <= (others => '0');
    elsif v(2) = '1' then
      r13 <= s13_max;
    end if;
  end process;

  -- STAGE4
  ---------------------------------------

  s14_src1 <= r12(15 downto 0);
  s14_src2 <= r13(15 downto 0);
  s14_src3 <= direction_ty(r12(18 downto 16));
  s14_src4 <= direction_ty(r13(18 downto 16));

  s14_max  <= signed(MAX(s14_src1, s14_src2, s14_src3, s14_src4));
  s14_maxVal <= s14_max(15 downto 0);
  s14_maxDir <= direction_ty(s14_max(18 downto 16));

  s14_cmp  <= '1' when (s14_maxVal > 383) else '0';

  -- reg: reg14
  process begin
    wait until rising_edge(clk);
    if v(3) = '1' then
      r14 <= s14_cmp;
      o_valid <= '1';
      if (s14_cmp = '1') then
        o_dir <= s14_maxDir;
      else 
        o_dir <= (others => '0');
      end if;
    else 
      r14 <= '0';
      o_valid <= '0';
      o_dir <= (others => '0');
    end if;
  end process;

  -- drive output 
  o_edge <= r14;

end architecture;

