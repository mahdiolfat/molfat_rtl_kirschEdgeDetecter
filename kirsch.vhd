-- TODO:
-- * Implement o_col, o_row, and o_mode outputs

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

  signal v                             : std_logic_vector( 0 to 3);
  signal r_i                           : unsigned ( 7 downto 0 ); 
  signal r_j                           : unsigned ( 7 downto 0 ); 
  signal r_m                           : unsigned ( 1 downto 0 ); 
  signal r_n                           : unsigned ( 1 downto 0 ); 

  -- memory signals
  signal r_mem_i                       : unsigned ( 1 downto 0 );

  -- registered pixel input
  signal r_pixel                       : unsigned ( 7 downto 0 );

  -- convolution table signals
  signal conv_a0, conv_a1, conv_a2,
         conv_b0, conv_b1, conv_b2,
         conv_c0, conv_c1, conv_c2     : unsigned (7 downto 0 );

  signal i_valid_ppl                   : std_logic;
    
  -- memory signals
  signal m0_addr                       : unsigned( 7 downto 0 );
  signal m0_i_data, m0_o_data          : std_logic_vector( 7 downto 0 );
  signal m0_wren                       : std_logic;

  signal m1_addr                       : unsigned( 7 downto 0 );
  signal m1_i_data, m1_o_data          : std_logic_vector( 7 downto 0 );
  signal m1_wren                       : std_logic;

  signal m2_addr                       : unsigned( 7 downto 0 );
  signal m2_i_data, m2_o_data          : std_logic_vector( 7 downto 0 );
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
    -- TODO: is the next condition needed?
    elsif v(1) = '1' then
      m0_wren <= '0'; 
      m1_wren <= '0'; 
      m2_wren <= '0'; 
    end if;
  end process;

  -- TODO: drive o_mode, is everything covered?
  process begin 
    wait until rising_edge(clk);
    if reset = '1' then
      o_mode <= m_reset;
    elsif v(0) = '1' and r_i = 0 and r_i = 0 then
      o_mode <= m_busy;
    else
      o_mode <= m_idle;
    end if;
  end process;

  -- reg: row memory indices logic, includes global row counter
  -- for i = 1 to 254 { 
  --   for j = 1 to 254 {
  --     for m = 0 to 2   {
  --       for n = 0 to 2   {
  --         table[m,n] = image[i+m-1, j+n-1];
  --       }
  --     }
  --   }
  -- }
  i_valid_ppl <= '1' when (r_i >= 2 and r_j >= 2 and v(1) = '1') else '0';
  process begin
    wait until rising_edge(clk);
    if reset = '1' then
      r_mem_i  <= (others => '0');
      r_i      <= (others => '0');
      r_j      <= (others => '0');
      -- TODO: what to do with r_m and r_n? Are they needed?
      r_m      <= (others => '0');
      r_n      <= (others => '0');
    elsif v(1) = '1' then 
      if r_j = 255 then
        -- TODO: drive output if matrix has been fully read
        if r_i =  255 then
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

  -- TODO: does this need to be registered?
  -- can r_i be o_row?
  process (reset, v, r_i) begin 
    if reset = '1' then
      o_row <= '0';
    else
      o_row <= r_i;
    end if;
  end process;

  process (reset, v, r_j, i_pixel) begin 
    if reset = '1' then
      m0_addr   <= (others => '0');
      m0_i_data <= (others => '0');
      m1_addr   <= (others => '0');
      m1_i_data <= (others => '0');
      m2_addr   <= (others => '0');
      m2_i_data <= (others => '0');
    elsif v(0) = '1' then
      -- TODO: can this be optimized? 
      m0_addr   <= r_j;
      m0_i_data <= std_logic_vector(i_pixel);
      m1_addr   <= r_j;
      m1_i_data <= std_logic_vector(i_pixel);
      m2_addr   <= r_j;
      m2_i_data <= std_logic_vector(i_pixel);
    end if;
    -- TODO: need an else statement here
  end process;

  -- control logic for convolution pipeline
  -- TODO: optimize? use separate muxed signals?
  conv_c2 <= r_pixel;

  process (reset, v, r_mem_i, m0_o_data, m1_o_data, m2_o_data) begin
    if reset = '1' then
      conv_a2 <= (others => '0'); 
      conv_b2 <= (others => '0'); 
    elsif v(1) = '1' then
      if r_mem_i = 0 then
        conv_a2 <= unsigned(m1_o_data); 
        conv_b2 <= unsigned(m2_o_data);
      elsif r_mem_i = 1 then
        conv_a2 <= unsigned(m2_o_data); 
        conv_b2 <= unsigned(m0_o_data);
      elsif r_mem_i = 2 then
        conv_a2 <= unsigned(m0_o_data); 
        conv_b2 <= unsigned(m1_o_data);
      end if;
    end if;
  end process;

  process begin
    wait until rising_edge(clk);
    -- could i optimize by removing reset cond.?
    if reset = '1' then
      conv_a1 <= (others => '0');
      conv_b1 <= (others => '0');
      conv_c1 <= (others => '0');
      conv_a0 <= (others => '0');
      conv_b0 <= (others => '0');
      conv_c0 <= (others => '0');
    elsif v(0) = '1' then
      conv_a0 <= conv_a1;
      conv_b0 <= conv_b1;
      conv_c0 <= conv_c1;
      conv_a1 <= conv_a2;
      conv_b1 <= conv_b2;
      conv_c1 <= conv_c2;
    end if;
  -- TODO: is this covering all the cases?
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

  -- TODO: make ASCII table to show connections
  ppl: entity work.kirsch_pipeline
    port map (
      clk       => clk,
      reset     => reset,
      i_valid   => i_valid_ppl,
      i_conv_a  => conv_a0,
      i_conv_b  => conv_a1,
      i_conv_c  => conv_a2,
      i_conv_d  => conv_b2,
      i_conv_e  => conv_c2,
      i_conv_f  => conv_c1,
      i_conv_g  => conv_c0,
      i_conv_h  => conv_b0,
      i_conv_i  => conv_b1,
      o_valid   => o_valid,
      o_edge    => o_edge,
      o_dir     => o_dir,
      o_col     => o_col
    );

end architecture;

