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
  signal r_i                    : unsigned ( 7 downto 0 ); 
  signal r_j                    : unsigned ( 7 downto 0 ); 
  signal r_m                    : unsigned ( 1 downto 0 ); 
  signal r_n                    : unsigned ( 1 downto 0 ); 

  -- memory signals
  signal r_mem_i                : unsigned ( 1 downto 0 );

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

  signal r12                           : std_logic;
  
  -- combinational signals for arithmetic operations
  signal s1_src1                       : unsigned ( 15 downto 0 );
  signal s1_src2                       : unsigned ( 15 downto 0 );
  signal s1_src3                       : unsigned ( 15 downto 0 );
  signal s1_src4                       : unsigned ( 15 downto 0 );
  signal s1_add1                       : unsigned ( 15 downto 0 );
  signal s1_add2                       : unsigned ( 15 downto 0 );
  signal s1_add3                       : unsigned ( 15 downto 0 );
  signal s1_out                        : unsigned ( 15 downto 0 );

  signal s2_src1                       : unsigned ( 15 downto 0 );
  signal s2_src2                       : unsigned ( 15 downto 0 );
  signal s2_src3                       : unsigned ( 15 downto 0 );
  signal s2_src4                       : unsigned ( 15 downto 0 );
  signal s2_add1                       : unsigned ( 15 downto 0 );
  signal s2_add2                       : unsigned ( 15 downto 0 );
  signal s2_add3                       : unsigned ( 15 downto 0 );
  signal s2_out                        : unsigned ( 15 downto 0 );

  signal s3_src1                       : unsigned ( 15 downto 0 );
  signal s3_src2                       : unsigned ( 15 downto 0 );
  signal s3_max                        : unsigned ( 15 downto 0 );
  signal s3_add                        : unsigned ( 15 downto 0 );
  signal s3_out                        : unsigned ( 15 downto 0 );

  signal s4_src1                       : unsigned ( 15 downto 0 );
  signal s4_src2                       : unsigned ( 15 downto 0 );
  signal s4_src3                       : unsigned ( 15 downto 0 );
  signal s4_src4                       : unsigned ( 15 downto 0 );
  signal s4_add1                       : unsigned ( 15 downto 0 );
  signal s4_add2                       : unsigned ( 15 downto 0 );
  signal s4_max                        : unsigned ( 15 downto 0 );
  signal s4_out                        : unsigned ( 15 downto 0 );

  signal s5_src1                       : unsigned ( 15 downto 0 );
  signal s5_src2                       : unsigned ( 15 downto 0 );
  signal s5_src3                       : unsigned ( 15 downto 0 );
  signal s5_src4                       : unsigned ( 15 downto 0 );
  signal s5_add1                       : unsigned ( 15 downto 0 );
  signal s5_add2                       : unsigned ( 15 downto 0 );
  signal s5_max                        : unsigned ( 15 downto 0 );
  signal s5_out                        : unsigned ( 15 downto 0 );

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

  signal s10_sub1                      : unsigned ( 15 downto 0 );
  signal s10_sub2                      : unsigned ( 15 downto 0 );
  signal s10_max                       : unsigned ( 15 downto 0 );
  signal s10_out                       : unsigned ( 15 downto 0 );

  signal s11_sub                       : unsigned ( 15 downto 0 );
  signal s11_out                       : unsigned ( 15 downto 0 );

  signal s12_max                       : unsigned ( 15 downto 0 );
  signal s12_cmp                       : std_logic;
  signal s12_out                       : std_logic;

  -- signals for reading matrix
  signal r_mem_idx                     : unsigned ( 1 downto 0 );

  -- memory signals
  signal m0_addr                       : unsigned( 7 downto 0 );
  signal m0_i_pixel, m0_o_data          : std_logic_vector( 7 downto 0 );
  signal m0_wren                       : std_logic;

  signal m1_addr                       : unsigned( 7 downto 0 );
  signal m1_i_pixel, m1_o_data          : std_logic_vector( 7 downto 0 );
  signal m1_wren                       : std_logic;

  signal m2_addr                       : unsigned( 7 downto 0 );
  signal m2_i_pixel, m2_o_data          : std_logic_vector( 7 downto 0 );
  signal m2_wren                       : std_logic;

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

  -- comb: memory wren
  process (reset, v, r_mem_i) begin
    if reset = '1' then
        m0_wren <= '0'; 
        m1_wren <= '0'; 
        m2_wren <= '0'; 
    elsif v(0) = '1' then
      -- r_mem_i is the current row
      if r_mem_i = 0 then       -- case 1
        m0_wren <= '1'; 
        m1_wren <= '0'; 
        m2_wren <= '0'; 
      elsif r_mem_i = 1 then    -- case 2
        m0_wren <= '0'; 
        m1_wren <= '1'; 
        m2_wren <= '0'; 
      elsif r_mem_i = 2 then    -- case 3
        m0_wren <= '0'; 
        m1_wren <= '0'; 
        m2_wren <= '1'; 
      end if;
    elsif v(1) = '1' then
      m0_wren <= '0'; 
      m1_wren <= '0'; 
      m2_wren <= '0'; 
    end if;
  end process;

  -- reg: row memory indices logic, includes global row counter
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r_mem_i  <= (others => '0');
      r_j  <= (others => '0');
      r_i  <= (others => '0');

    elsif v(1) = '1' then 
      if r_j = 15 then
        -- drive output if matrix has been fully read
        if r_i =  15 then
          r_mem_i  <= (others => '0');
        else
          if r_mem_i = 2 then
            r_mem_i <= (others => '0');
          else 
            r_mem_i <= r_mem_i + 1;
          end if;
        end if;
        r_i  <= r_i + 1;
      end if;
      r_j <= r_j + 1;
    end if;
  end process;

  process (reset, v, r_j, i_pixel) begin 
    if reset = '1' then
      m0_addr   <= (others => '0');
      m0_i_pixel <= (others => '0');
      m1_addr   <= (others => '0');
      m1_i_pixel <= (others => '0');
      m2_addr   <= (others => '0');
      m2_i_pixel <= (others => '0');
    elsif v(0) = '1' then
      m0_addr   <= r_j;
      m0_i_pixel <= std_logic_vector(i_pixel);
      m1_addr   <= r_j;
      m1_i_pixel <= std_logic_vector(i_pixel);
      m2_addr   <= r_j;
      m2_i_pixel <= std_logic_vector(i_pixel);
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
  s1_add3 <= s1_add1 + s1_add2;
  s1_out  <= s1_add3;
  
  -- comb: s2 comb block
  s2_add1 <= s2_src1 + s2_src2;
  s2_add2 <= s2_src3 + s2_src4;
  s2_add3 <= s2_add1 + s2_add2;
  s2_out  <= s2_add3;

  -- comb: s3 comb block
  s3_max <= s3_src1 + s3_src2;
  s3_add <= s2_add2 + s3_max;
  s3_out <= s3_add;

  -- comb: s4 comb block
  s4_src1 <= s3_src2;
  s4_src2 <= s1_src1;
  s4_src3 <= s2_src4;
  s4_src4 <= s1_src2;

  s4_add1 <= s4_src1 + s4_src2; 
  s4_max  <= s4_src3 + s4_src4;
  s4_add2 <= s4_add1 + s4_max; 
  s4_out  <= s4_add2;

  -- comb: s5 comb block
  s5_src1 <= s4_src4;
  s5_src2 <= s1_src3;
  s5_src3 <= s4_src2;
  s5_src4 <= s1_src4;

  s5_add1 <= s5_src1 + s5_src2;
  s5_max  <= s5_src3 + s5_src4;
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

  o_edge <= r12;
  ---------------------------------------


  -- instantiate 3 memory rows
  m0: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m0_addr,
      i_data    => m0_i_pixel,
      o_data    => m0_o_data,
      wren      => m0_wren
    );

  m1: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m1_addr,
      i_data    => m1_i_pixel,
      o_data    => m1_o_data,
      wren      => m1_wren
    );

  m2: entity work.mem8x256_1rw
    port map (
      clk       => clk,
      addr      => m2_addr,
      i_data    => m2_i_pixel,
      o_data    => m2_o_data,
      wren      => m2_wren
    );

end architecture;
