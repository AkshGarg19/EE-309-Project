library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.basic.all;

entity datapath is
	port(  -----mux signals-----------------
		m_a3_0,m_a3_1 : in std_logic;
		m_d3_0,m_d3_1 : in std_logic;
		m_z  ,m_mem_a         : in std_logic;
		m_op1_0,m_op1_1      : in std_logic;
		m_op2_0,m_op2_1      : in std_logic;
		m_a2          : in std_logic;
		m_comp_a,m_comp_b:in std_logic;
		wr_mem        : in std_logic;   --write on memory
		rd_mem        : in std_logic;   --read memory
		wr_rf         : in std_logic;   --write on register file
		
		-----enable---------------------
		en_ir,en_irf         : in std_logic;   --enable instruction register
		en_A     : in std_logic;   --enable of input registers to alu
		en_c,en_z     : in std_logic;
		-----------------------------------------------------------------------------
		op_sel        : in std_logic;   --operation select by alu

		equ      : out std_logic;  --eqcheck
		C,Z      : out std_logic;  --carry,zero
		-----------------------------------------------------------------------------
		op_code  : out std_logic_vector(3 downto 0);  --first 4 bits of IR which is op_code
		condition_code: out std_logic_vector(1 downto 0);    --last 2 bits of IR
		r0          : out std_logic_vector(15 downto 0);
		r1          : out std_logic_vector(15 downto 0);
		r2          : out std_logic_vector(15 downto 0);
		r3          : out std_logic_vector(15 downto 0);
		r4          : out std_logic_vector(15 downto 0);
		r5          : out std_logic_vector(15 downto 0);
		r6          : out std_logic_vector(15 downto 0);
		r7          : out std_logic_vector(15 downto 0);

		clk,reset: in std_logic
	    );
end entity;

architecture behave of datapath is
	signal mem_a,DIN,reg_out  : std_logic_vector(15 downto 0);
	signal op1,op2         : std_logic_vector(15 downto 0);
	signal D1,D2,D3        : std_logic_vector(15 downto 0);	
	signal A2,A3           : std_logic_vector(2 downto 0);
	signal ir              : std_logic_vector(15 downto 0);
	signal apna_signal1,irf_to_ire,comp_a,comp_b: std_logic_vector(15 downto 0);
	signal alu_out         : std_logic_vector(15 downto 0);
	signal se6_out,se9_out : std_logic_vector(15 downto 0);
	signal z_0       : std_logic; 
	signal cin,zin, eq        : std_logic;

begin
	
-------------------------------------------------------------------------------------------------------
	RAM: memory
		port map(mem_a => mem_a, mem_d => D1, mem_out => DIN, clk => clk, wr_mem => wr_mem, rd_mem => rd_mem);   
------------------------------------------
	Inst_reg_exe: instruction_register
		port map(din => irf_to_ire,  en_ir => en_ir, 
			 reset => reset, clk => clk, dout => ir);
	op_code <= ir(15 downto 12); 
   condition_code <= ir(1 downto 0);
   equ <= eq;	
--------------------------------------------
	Inst_reg_fetch: instruction_register_fetch
		port map(din => DIN,en_irf => en_irf,
			 reset => reset, clk => clk, dout => irf_to_ire); 
   --to control path for instruction fetch
--------------------------------------------
	se6: sign_extend
		generic map(input_width => 6, output_width => 16)
		port map (input => ir(5 downto 0), output => se6_out);   
--------------------------------------------
	se9: sign_extend
		generic map(input_width => 9, output_width => 16) 
		port map (input => ir(8 downto 0), output => se9_out);   
--------------------------------------------
	regA: dregister
		generic map(16)
		port map(reset => reset, din => alu_out, dout => reg_out, enable => en_A, clk => clk);   
--------------------------------------------
   mux_mem_a: mux_2to1_nbits
		generic map(16)
		port map(s0 => m_mem_a, input0 =>reg_out, input1 => D2, output => mem_a);
--------------------------------------------
   mux_op1: mux_4to1_nbits
		generic map(16)
		port map(s0 => m_op1_0, s1 => m_op1_1,
		         input0 => D2, input1 => se6_out, input2 => se9_out, input3 => apna_signal1, output => op1); 
--------------------------------------------
   mux_op2: mux_4to1_nbits
		generic map(16)
		port map(s0 => m_op2_0, s1 => m_op2_1,
		         input0 => "0000000000000001", input1 => D2, input2 => D1, input3 => se6_out, output => op2); 
--------------------------------------------
   mux_a3: mux_4to1_nbits
		generic map(3)
		port map(s0 => m_a3_0, s1 => m_a3_1,
		         input0 => ir(11 downto 9), input1 => ir(8 downto 6), input2 => ir(5 downto 3), input3 => "111", output => A3); 
--------------------------------------------
   mux_d3: mux_4to1_nbits
		generic map(16)
		port map(s0 => m_d3_0, s1 => m_d3_1,
		         input0 => reg_out, input1 => D2, input2 => se9_out, input3 => DIN, output => D3); 
-------------------------------------------
   mux_a2: mux_2to1_nbits
		generic map(3)
		port map(s0 => m_a2, input0 => ir(8 downto 6), input1 => "111", output => A2);  				
 -------------------------------------------	
   mux_compa: mux_2to1_nbits
		generic map(16)
		port map(s0 => m_comp_a, input0 => D1, input1 => DIN, output => comp_a);  
--------------------------------------------		
   mux_compb: mux_2to1_nbits
		generic map(16)
		port map(s0 => m_comp_b, input0 => D2, input1 => "0000000000000000", output =>comp_b); 

--------------------------------------------
	compare: eq_check
		generic map(16)
		port map(a => comp_a, b => comp_b, a_eq_b => eq);  
--------------------------------------------
	carryFF: dflipflop
		port map(reset => reset, din => cin, dout => C, enable => en_c, clk => clk); 
--------------------------------------------
	mux_z: mux_2to1
		port map(s0 => m_z, input0 => z_0, input1 => eq, output => zin); 
--------------------------------------------
	zeroFF: dflipflop
		port map(reset => reset, din => zin, dout => Z, enable => en_z, clk => clk); 
--------------------------------------------
	alu_unit: alu
		port map(inp1 => op1, inp2 => op2, op_sel => op_sel, output => alu_out, c => cin, z => z_0); 
--------------------------------------------
	RF: register_file
		port map(d1 => D1, d2 => D2, d3 => D3, write_en => wr_rf, read_en => '1', reset => reset,
			 a1 => ir(11 downto 9), a2 => A2, a3 => A3, clk => clk,
			 r0 => r0, r1 => r1, r2 => r2, r3 => r3, r4 => r4, r5 => r5, r6 => r6, r7 => r7);   

--------------------------------------------
   shifter1: left1_shifter
		generic map(input_width => 16, output_width => 16)
		port map (inp => D2, outp => apna_signal1);   
 
end behave;
		 
		 




