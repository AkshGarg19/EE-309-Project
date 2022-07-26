library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package basic is
---------------------------------------------------------------------------------------------------------
	component mux_2to1 is                                             -----checked
	port(
		s0, input0, input1 : in std_logic;
		output : out std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
   component instruction_register_fetch is                           -------- checked
	port(
	   din: in std_logic_vector(15 downto 0);
		dout: out std_logic_vector(15 downto 0);
		clk, reset, en_irf: in std_logic
	);
	end component;
---------------------------------------------------------------------------------------------------------
	component mux_2to1_nbits is                                      -----checked
		generic ( nbits : integer);
		port(
			s0 : in std_logic;
			input0, input1 : in std_logic_vector(nbits-1 downto 0);
			output : out std_logic_vector(nbits-1 downto 0));
	end component;
---------------------------------------------------------------------------------------------------------
	component mux_4to1 is                                           -----checked
	port(
		s0, s1, input0, input1, input2, input3 : in std_logic;
		output : out std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component mux_4to1_nbits is                                     -----checked
	generic ( nbits : integer);
	port(
		s0, s1 : in std_logic;
		input0, input1, input2, input3 : in std_logic_vector(nbits-1 downto 0);
		output : out std_logic_vector(nbits-1 downto 0));
	end component;

---------------------------------------------------------------------------------------------------------
	component sign_extend is                                           -----checked
		generic(input_width: integer := 6;
			output_width: integer := 16);
		port(
			input: in std_logic_vector(input_width-1 downto 0);
			output: out std_logic_vector(output_width-1 downto 0));
	end component;
---------------------------------------------------------------------------------------------------------
	component eq_check is                                              -----checked
	  	generic (nbits : integer);
	  	port (
	    		a      : in  std_logic_vector(nbits-1 downto 0);
	    		b      : in  std_logic_vector(nbits-1 downto 0);
	    		a_eq_b : out std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component left1_shifter is                                         ---- checked
		generic(input_width: integer := 16;
			output_width: integer := 16);
		port(
			inp: in std_logic_vector(input_width-1 downto 0);
			outp: out std_logic_vector(output_width-1 downto 0));
	end component;
---------------------------------------------------------------------------------------------------------
	component alu is                                                    ---- checked
	 	Port (
		 inp1 : in std_logic_vector(15 downto 0);
		 inp2 : in std_logic_vector(15 downto 0);
		 op_sel : in std_logic;
		 output : out std_logic_vector(15 downto 0);
		 c : out std_logic;
		 z : out std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component dregister is                                              ---- checked
	  	generic (nbits : integer:=16);
	  	port (
	    		reset: in std_logic;
	   		 din  : in  std_logic_vector(nbits-1 downto 0);
	    		dout : out std_logic_vector(nbits-1 downto 0);
	    		enable: in std_logic;
	    		clk     : in  std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component dflipflop is                                              ---- checked
	  port (
	    reset: in std_logic;
	    din  : in  std_logic;
	    dout : out std_logic;
	    enable: in std_logic;
	    clk     : in  std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component register_file is                                         ---- checked
	    port
	    ( d1,d2       : out std_logic_vector(15 downto 0);
		   r0          : out std_logic_vector(15 downto 0);
		   r1          : out std_logic_vector(15 downto 0);
		   r2          : out std_logic_vector(15 downto 0);
		   r3          : out std_logic_vector(15 downto 0);
   		r4          : out std_logic_vector(15 downto 0);
	   	r5          : out std_logic_vector(15 downto 0);
		   r6          : out std_logic_vector(15 downto 0);
		   r7          : out std_logic_vector(15 downto 0);
	      d3          : in  std_logic_vector(15 downto 0);
	      write_en : in  std_logic;
	      read_en  : in  std_logic;
	      reset    : in  std_logic;
	      a1,a2,a3    : in  std_logic_vector(2 downto 0);
	      clk         : in  std_logic );
	end component;
---------------------------------------------------------------------------------------------------------
	component memory is                                                ---- checked
	   port ( mem_a,mem_d: in std_logic_vector(15 downto 0);
		  mem_out: out std_logic_vector(15 downto 0);
	 	 clk,wr_mem,rd_mem: in std_logic);
	end component;
---------------------------------------------------------------------------------------------------------
	component instruction_register is                                  ----  checked
	     port(
		    din     : in std_logic_vector(15 downto 0);
		    en_ir   : in std_logic;
		    clk,reset : in std_logic;
		    dout: out std_logic_vector(15 downto 0)
		 );
	end component;
---------------------------------------------------------------------------------------------------------
	component controlpath is                                           ---- checked
	port(  -----mux signals-----------------
		m_mem_a           : out std_logic;
		m_a3_0,m_a3_1     : out std_logic;
		m_d3_0,m_d3_1     : out std_logic;
		m_z               : out std_logic;
		m_op1_0, m_op1_1	: out std_logic;
		m_op2_0, m_op2_1  : out std_logic;
		m_a2              : out std_logic;
		m_comp_a, m_comp_b: out std_logic;
		wr_mem            : out std_logic;   --write on memory
		rd_mem            : out std_logic;   --read memory
		wr_rf             : out std_logic;   --write on register file
		-----enable---------------------
		en_ir, en_irf     : out std_logic;   --enable instruction register
		en_A              : out std_logic;   --enable of input registers to alu
		en_c,en_z         : out std_logic;
		-----------------------------------------------------------------------------en_counter,rst_counter: in std_logic;
		op_sel            : out std_logic;   --operation select by alu

		equ               : in std_logic;  --comparator
		C,Z               : in std_logic;  --carry,zero
		-----------------------------------------------------------------------------load     : out std_logic;
		op_code           : in std_logic_vector(3 downto 0);  --first 4 bits of IR which is op_code
		condition_code    : in std_logic_vector(1 downto 0);    --last 2 bits of IR

		clk,reset         : in std_logic
	    );
	end component;
---------------------------------------------------------------------------------------------------------
	component datapath is                                                  ---- checked
	port(  -----mux signals-----------------
		m_mem_a           : in std_logic;
		m_a3_0, m_a3_1    : in std_logic;
		m_d3_0,m_d3_1     : in std_logic;
		m_z               : in std_logic;
		m_op1_0, m_op1_1	: in std_logic;
		m_op2_0, m_op2_1  : in std_logic;
		m_a2              : in std_logic;
		m_comp_a, m_comp_b: in std_logic;
		wr_mem            : in std_logic;   --write on memory
		rd_mem            : in std_logic;   --read memory
		wr_rf             : in std_logic;   --write on register file
		-----enable---------------------
		en_ir, en_irf     : in std_logic;   --enable instruction register
		en_A              : in std_logic;   --enable of input registers to alu
		en_c,en_z         : in std_logic;
		-----------------------------------------------------------------------------en_counter,rst_counter: in std_logic;
		op_sel            : in std_logic;   --operation select by alu

		equ               : out std_logic;  --comparator
		C,Z               : out std_logic;  --carry,zero
		-----------------------------------------------------------------------------load     : out std_logic;
		op_code           : out std_logic_vector(3 downto 0);  --first 4 bits of IR which is op_code
		condition_code    : out std_logic_vector(1 downto 0);    --last 2 bits of IR
		r0          : out std_logic_vector(15 downto 0);
		r1          : out std_logic_vector(15 downto 0);
		r2          : out std_logic_vector(15 downto 0);
		r3          : out std_logic_vector(15 downto 0);
		r4          : out std_logic_vector(15 downto 0);
		r5          : out std_logic_vector(15 downto 0);
		r6          : out std_logic_vector(15 downto 0);
		r7          : out std_logic_vector(15 downto 0);

		clk,reset         : in std_logic
	    );
	end component;
---------------------------------------------------------------------------------------------------------
end package;