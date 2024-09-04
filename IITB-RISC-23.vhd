library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity IITB_RISC23 is
    port (
        input_vector : in std_logic_vector(1 downto 0);
        output_vector : out std_logic_vector(15 downto 0)
    );
end entity IITB_RISC23;

architecture working of IITB_RISC23 is

    -- components

    component ALU is
        port (
            A, B : in std_logic_vector(15 downto 0);
            X : out std_logic_vector(15 downto 0);
            IR : in std_logic;
            carry_out : out std_logic);
    end component ALU;

    component Adder is
        port (
            A, B : in std_logic_vector(15 downto 0);
            X : out std_logic_vector(15 downto 0));
    end component Adder;

    component Comparator is
        port (
            A, B : in std_logic_vector(15 downto 0);
            less_than, equal : out std_logic);
    end component Comparator;

    component Flipper is
        port (
            A : in std_logic_vector(15 downto 0);
            X : out std_logic_vector(15 downto 0));
    end component Flipper;

    component CZFlagRegister is
        port (
            A : in std_logic_vector(15 downto 0);
            Z_in : out std_logic;
            C_in, Z_wen, C_wen : in std_logic;
            Z_out, C_out : out std_logic;
            clk, rst : in std_logic);
    end component CZFlagRegister;

    component DataMemory is
        port (
            A1 : in std_logic_vector(15 downto 0);
            D1 : out std_logic_vector(15 downto 0);
            A3, D3 : in std_logic_vector(15 downto 0);
            wen, clk : in std_logic);
    end component DataMemory;

    component InstructionMemory is
        port (
            A : in std_logic_vector(15 downto 0);
            D : out std_logic_vector(15 downto 0));
    end component InstructionMemory;

    component InstructionDecoder is
        port (
            ir : in std_logic_vector(15 downto 0);
            opcode : out std_logic_vector(3 downto 0);
            RA, RB, RC : out std_logic_vector(2 downto 0);
            cmp : out std_logic;
            cz : out std_logic_vector(1 downto 0);
            imm6 : out std_logic_vector(5 downto 0);
            imm9 : out std_logic_vector(8 downto 0));
    end component InstructionDecoder;

    component register_file is
        port (
            -- 3 address-input line inputs
            reg_a1 : in std_logic_vector(2 downto 0);
            reg_a2 : in std_logic_vector(2 downto 0);
            reg_a3 : in std_logic_vector(2 downto 0);

            -- register write enable
            reg_en : in std_logic_vector(7 downto 0);

            -- 1 data-input line input
            reg_d3 : in std_logic_vector(15 downto 0);

            -- 2 data-output line output
            reg_d1 : out std_logic_vector(15 downto 0);
            reg_d2 : out std_logic_vector(15 downto 0);

            -- PC update
            pc_in : in std_logic_vector(15 downto 0);
            pc_out : out std_logic_vector(15 downto 0);

            -- clock 
            clock : in std_logic; -- clock

            -- register reset
            reset : in std_logic
        );
    end component register_file;

    component SignedExtender is
        generic (N : integer := 10);
        port (
            A : in std_logic_vector(15 - N downto 0);
            X : out std_logic_vector(15 downto 0));
    end component SignedExtender;

    -- Pieline Regisers
    component pipeline_reg1 is
        port (
            p1_ir_in : in std_logic_vector(15 downto 0);
            p1_pc_in : in std_logic_vector(15 downto 0);
            p1_ir_out : out std_logic_vector(15 downto 0);
            p1_pc_out : out std_logic_vector(15 downto 0);
            p1_en : in std_logic;
            clock : in std_logic
        );
    end component pipeline_reg1;

    component pipeline_reg2 is
        port (
            p2_ra_in : in std_logic_vector(2 downto 0);
            p2_rb_in : in std_logic_vector(2 downto 0);
            p2_rc_in : in std_logic_vector(2 downto 0);
            p2_opcode_in : in std_logic_vector(3 downto 0);
            p2_complement_in : in std_logic;
            p2_cz_in : in std_logic_vector(1 downto 0);
            p2_se7_in : in std_logic_vector(15 downto 0);
            p2_se10_in : in std_logic_vector(15 downto 0);
            p2_pc_in : in std_logic_vector(15 downto 0);
            p2_ra_out : out std_logic_vector(2 downto 0);
            p2_rb_out : out std_logic_vector(2 downto 0);
            p2_rc_out : out std_logic_vector(2 downto 0);
            p2_opcode_out : out std_logic_vector(3 downto 0);
            p2_complement_out : out std_logic;
            p2_cz_out : out std_logic_vector(1 downto 0);
            p2_se7_out : out std_logic_vector(15 downto 0);
            p2_se10_out : out std_logic_vector(15 downto 0);
            p2_pc_out : out std_logic_vector(15 downto 0);
            p2_en : in std_logic;
            clock : in std_logic
        );
    end component pipeline_reg2;

    component pipeline_reg3 is
        port (
            p3_rc_in : in std_logic_vector(2 downto 0);
            p3_rf_d1_in : in std_logic_vector(15 downto 0);
            p3_rf_d2_in : in std_logic_vector(15 downto 0);
            p3_opcode_in : in std_logic_vector(3 downto 0);
            p3_complement_in : in std_logic;
            p3_cz_in : in std_logic_vector(1 downto 0);
            p3_se7_in : in std_logic_vector(15 downto 0);
            p3_se10_in : in std_logic_vector(15 downto 0);
            p3_pc_in : in std_logic_vector(15 downto 0);
            p3_ra_in : in std_logic_vector(2 downto 0);
            p3_rb_in : in std_logic_vector(2 downto 0);
            p3_rc_out : out std_logic_vector(2 downto 0);
            p3_rf_d1_out : out std_logic_vector(15 downto 0);
            p3_rf_d2_out : out std_logic_vector(15 downto 0);
            p3_opcode_out : out std_logic_vector(3 downto 0);
            p3_complement_out : out std_logic;
            p3_cz_out : out std_logic_vector(1 downto 0);
            p3_se7_out : out std_logic_vector(15 downto 0);
            p3_se10_out : out std_logic_vector(15 downto 0);
            p3_pc_out : out std_logic_vector(15 downto 0);
            p3_ra_out : out std_logic_vector(2 downto 0);
            p3_rb_out : out std_logic_vector(2 downto 0);
            p3_en : in std_logic;
            clock : in std_logic
        );
    end component pipeline_reg3;

    component pipeline_reg4 is
        port (
            p4_rc_in : in std_logic_vector(2 downto 0);
            p4_alu_c_in : in std_logic_vector(15 downto 0);
            p4_opcode_in : in std_logic_vector(3 downto 0);
            p4_complement_in : in std_logic;
            p4_cz_in : in std_logic_vector(1 downto 0);
            p4_carry_flag_in : in std_logic;
            p4_zero_flag_in : in std_logic;
            p4_se7_in : in std_logic_vector(15 downto 0);
            p4_se10_in : in std_logic_vector(15 downto 0);
            p4_rf_d2_in : in std_logic_vector(15 downto 0);
            p4_less_than_flag_in : in std_logic;
            p4_equal_to_flag_in : in std_logic;
            p4_ra_in : in std_logic_vector(2 downto 0);
            p4_rb_in : in std_logic_vector(2 downto 0);
            p4_rc_out : out std_logic_vector(2 downto 0);
            p4_alu_c_out : out std_logic_vector(15 downto 0);
            p4_opcode_out : out std_logic_vector(3 downto 0);
            p4_complement_out : out std_logic;
            p4_cz_out : out std_logic_vector(1 downto 0);
            p4_carry_flag_out : out std_logic;
            p4_zero_flag_out : out std_logic;
            p4_se7_out : out std_logic_vector(15 downto 0);
            p4_se10_out : out std_logic_vector(15 downto 0);
            p4_rf_d2_out : out std_logic_vector(15 downto 0);
            p4_less_than_flag_out : out std_logic;
            p4_equal_to_flag_out : out std_logic;
            p4_ra_out : out std_logic_vector(2 downto 0);
            p4_rb_out : out std_logic_vector(2 downto 0);
            p4_en : in std_logic;
            clock : in std_logic
        );
    end component pipeline_reg4;

    component pipeline_reg5 is
        port (
            p5_rc_in : in std_logic_vector(2 downto 0);
            p5_alu_c_in : in std_logic_vector(15 downto 0);
            p5_opcode_in : in std_logic_vector(3 downto 0);
            p5_complement_in : in std_logic;
            p5_cz_in : in std_logic_vector(1 downto 0);
            p5_carry_flag_in : in std_logic;
            p5_zero_flag_in : in std_logic;
            p5_se7_in : in std_logic_vector(15 downto 0);
            p5_se10_in : in std_logic_vector(15 downto 0);
            p5_memory_data_in : in std_logic_vector(15 downto 0);
            p5_less_than_flag_in : in std_logic;
            p5_equal_to_flag_in : in std_logic;
            p5_rc_out : out std_logic_vector(2 downto 0);
            p5_alu_c_out : out std_logic_vector(15 downto 0);
            p5_opcode_out : out std_logic_vector(3 downto 0);
            p5_complement_out : out std_logic;
            p5_cz_out : out std_logic_vector(1 downto 0);
            p5_carry_flag_out : out std_logic;
            p5_zero_flag_out : out std_logic;
            p5_se7_out : out std_logic_vector(15 downto 0);
            p5_se10_out : out std_logic_vector(15 downto 0);
            p5_memory_data_out : out std_logic_vector(15 downto 0);
            p5_less_than_flag_out : out std_logic;
            p5_equal_to_flag_out : out std_logic;
            p5_en : in std_logic;
            clock : in std_logic
        );
    end component pipeline_reg5;

    signal pc_input, pc_output, ir_output, se_7_output, se_10_output, p1_ir_output : std_logic_vector(15 downto 0);
    signal ir_opcode_output : std_logic_vector(3 downto 0);
    signal ir_ra_output, ir_rb_output, ir_rc_output : std_logic_vector(2 downto 0);
    signal ir_complement_output : std_logic;
    signal ir_carry_zero_output : std_logic_vector(1 downto 0);
    signal ir_imm6_output : std_logic_vector(5 downto 0);
    signal ir_imm9_output : std_logic_vector(8 downto 0);
    signal p1_pc_output : std_logic_vector(15 downto 0);
    signal p2_ra_output, p2_rb_output, p2_rc_output : std_logic_vector(2 downto 0);
    signal p2_opcode_output : std_logic_vector(3 downto 0);
    signal p2_complement_output : std_logic;
    signal p2_cz_output : std_logic_vector(1 downto 0);
    signal p2_se7_output, p2_se10_output : std_logic_vector(15 downto 0);
    signal p2_pc_output : std_logic_vector(15 downto 0);

    signal p3_rc_output : std_logic_vector(2 downto 0);
    signal p3_opcode_output : std_logic_vector(3 downto 0);
    signal p3_complement_output : std_logic;
    signal p3_cz_output : std_logic_vector(1 downto 0);
    signal p3_rf_d1_output, p3_rf_d2_output : std_logic_vector(15 downto 0);
    signal p3_pc_output : std_logic_vector(15 downto 0);

    signal p4_rc_output : std_logic_vector(2 downto 0);
    signal p4_opcode_output : std_logic_vector(3 downto 0);
    signal p4_complement_output : std_logic;
    signal p4_cz_output : std_logic_vector(1 downto 0);
    signal p4_alu_c_output : std_logic_vector(15 downto 0);
    signal p4_se7_output, p4_se10_output : std_logic_vector(15 downto 0);
    signal p4_rf_d2_output : std_logic_vector(15 downto 0);
    signal p4_ra_output : std_logic_vector(2 downto 0);
    signal p4_rb_output : std_logic_vector(2 downto 0);

    signal p5_rc_output : std_logic_vector(2 downto 0);
    signal p5_opcode_output : std_logic_vector(3 downto 0);
    signal p5_complement_output : std_logic;
    signal p5_cz_output : std_logic_vector(1 downto 0);
    signal p5_alu_c_output : std_logic_vector(15 downto 0);
    signal p5_se7_output, p5_se10_output : std_logic_vector(15 downto 0);
    signal p5_less_than_flag_output : std_logic;
    signal p5_equal_to_flag_output : std_logic;

    signal reg_d1_output, reg_d2_output, reg_d3_input : std_logic_vector(15 downto 0);

    signal alu1_c_output : std_logic_vector(15 downto 0);
    signal alu_carry, alu_zero : std_logic;
    signal zero_flag, carry_flag : std_logic;

    signal alu_ir_in : std_logic;
    signal p4_carry_flag_output, p4_zero_flag_output : std_logic;
    signal p5_carry_flag_output, p5_zero_flag_output : std_logic;

    signal cz_enable : std_logic_vector(1 downto 0);
    signal reg_en : std_logic_vector(7 downto 0) := x"FF";
    signal complement_output, alu_b_input, alu_a_input, adder_b_input, adder_output : std_logic_vector(15 downto 0) := x"0000";
    signal p3_se7_output, p3_se10_output : std_logic_vector(15 downto 0);
    signal p5_aluc_in : std_logic_vector(15 downto 0);

    signal p5_memory_data_output : std_logic_vector(15 downto 0);
    signal memory_data_output : std_logic_vector(15 downto 0);
    signal mem_write_en : std_logic;
    signal less_than_flag, equal_to_flag : std_logic;
    signal p4_less_than_flag_output, p4_equal_to_flag_output : std_logic;

    signal pc_input_from_adder : std_logic_vector(15 downto 0);
    signal p3_ra_output, p3_rb_output : std_logic_vector(2 downto 0);

    signal comparator_input_1, comparator_input_2 : std_logic_vector(15 downto 0);

    signal reset_signal : std_logic := '1';
    signal boot_flag : std_logic := '1';
    signal p3_rf_1len_h : std_logic_vector(15 downto 0);
    signal p5_enable : std_logic := '1';
    signal l2hzd1 : std_logic_vector(15 downto 0);
    signal l2hzd2 : std_logic_vector(15 downto 0);
    signal l3hzd1 : std_logic_vector(15 downto 0);
    signal l3hzd2 : std_logic_vector(15 downto 0);

    -- create a constrained string
    function to_string(x : string) return string is
        variable ret_val : string(1 to x'length);
        alias lx : string (1 to x'length) is x;
    begin
        ret_val := lx;
        return(ret_val);
    end to_string;

    -- bit-vector to std-logic-vector and vice-versa
    function to_std_logic_vector(x : bit_vector) return std_logic_vector is
        alias lx : bit_vector(1 to x'length) is x;
        variable ret_val : std_logic_vector(1 to x'length);
    begin
        for I in 1 to x'length loop
            if (lx(I) = '1') then
                ret_val(I) := '1';
            else
                ret_val(I) := '0';
            end if;
        end loop;
        return ret_val;
    end to_std_logic_vector;

    function to_string_std_logic_vector(x : std_logic_vector) return string is
        alias lx : std_logic_vector(1 to x'length) is x;
        variable ret_val : string(1 to x'length);
    begin
        for I in 1 to x'length loop
            if (lx(I) = '1') then
                ret_val(I) := '1';
            else
                ret_val(I) := '0';
            end if;
        end loop;
        return ret_val;
    end to_string_std_logic_vector;

    function to_string_std_logic(x : std_logic) return string is
        alias lx : std_logic is x;
        variable ret_val : string(1 to 1);
    begin
        for I in 1 to 1 loop
            if (lx = '1') then
                ret_val(I) := '1';
            else
                ret_val(I) := '0';
            end if;
        end loop;
        return ret_val;
    end to_string_std_logic;

begin
    output_vector <= p5_alu_c_output;

    -- Basic Components --
    inst_adderpc : Adder
    port map("0000000000000001", pc_output, pc_input_from_adder);

    inst_alu : ALU
    port map(alu_a_input, alu_b_input, alu1_c_output, alu_ir_in, alu_carry);

    inst_adder : Adder
    port map(alu1_c_output, adder_b_input, adder_output);

    inst_comparator : Comparator
    port map(comparator_input_1, comparator_input_2, less_than_flag, equal_to_flag);

    inst_b_complement : Flipper
    port map(p3_rf_d2_output, complement_output);

    inst_carry_zero_flag : CZFlagRegister
    port map(adder_output, alu_zero, alu_carry, cz_enable(0), cz_enable(1), zero_flag, carry_flag, input_vector(0), reset_signal);

    inst_data_memory : DataMemory
    port map(p4_alu_c_output, memory_data_output, p4_alu_c_output, p4_rf_d2_output, mem_write_en, input_vector(0));

    inst_ir_memory : InstructionMemory
    port map(pc_output, ir_output);

    inst_ir_decoder : InstructionDecoder
    port map(p1_ir_output, ir_opcode_output, ir_ra_output, ir_rb_output, ir_rc_output, ir_complement_output, ir_carry_zero_output, ir_imm6_output, ir_imm9_output);

    inst_register_file : register_file
    port map(
        reg_a1 => p2_ra_output,
        reg_a2 => p2_rb_output,
        reg_a3 => p5_rc_output,
        reg_en => reg_en,
        reg_d3 => reg_d3_input,
        reg_d1 => l3hzd1,
        reg_d2 => l3hzd2,
        pc_in => pc_input,
        pc_out => pc_output,
        clock => input_vector(0),
        reset => reset_signal
    );

    inst_se7 : SignedExtender
    generic map(N => 7)
    port map(ir_imm9_output, se_7_output);

    inst_se10 : SignedExtender
    generic map(N => 10)
    port map(ir_imm6_output, se_10_output);

    -- Pipeline Regisers --
    inst_pipeline_reg1 : pipeline_reg1
    port map(
        p1_ir_in => ir_output,
        p1_pc_in => pc_output,
        p1_pc_out => p1_pc_output,
        p1_ir_out => p1_ir_output,
        p1_en => '1',
        clock => input_vector(0)
    );

    inst_pipeline_reg2 : pipeline_reg2
    port map(
        p2_ra_in => ir_ra_output,
        p2_rb_in => ir_rb_output,
        p2_rc_in => ir_rc_output,
        p2_opcode_in => ir_opcode_output,
        p2_complement_in => ir_complement_output,
        p2_cz_in => ir_carry_zero_output,
        p2_se7_in => se_7_output,
        p2_se10_in => se_10_output,
        p2_pc_in => p1_pc_output,
        p2_ra_out => p2_ra_output,
        p2_rb_out => p2_rb_output,
        p2_rc_out => p2_rc_output,
        p2_opcode_out => p2_opcode_output,
        p2_complement_out => p2_complement_output,
        p2_cz_out => p2_cz_output,
        p2_se7_out => p2_se7_output,
        p2_se10_out => p2_se10_output,
        p2_pc_out => p2_pc_output,
        p2_en => '1',
        clock => input_vector(0)
    );

    inst_pipeline_reg3 : pipeline_reg3
    port map(
        p3_ra_in => p2_ra_output,
        p3_rb_in => p2_rb_output,
        p3_rc_in => p2_rc_output,
        p3_rf_d1_in => reg_d1_output,
        p3_rf_d2_in => reg_d2_output,
        p3_opcode_in => p2_opcode_output,
        p3_complement_in => p2_complement_output,
        p3_cz_in => p2_cz_output,
        p3_se7_in => p2_se7_output,
        p3_se10_in => p2_se10_output,
        p3_pc_in => p2_pc_output,
        p3_rc_out => p3_rc_output,
        p3_rf_d1_out => l2hzd1,
        p3_rf_d2_out => l2hzd2,
        p3_opcode_out => p3_opcode_output,
        p3_complement_out => p3_complement_output,
        p3_cz_out => p3_cz_output,
        p3_se7_out => p3_se7_output,
        p3_se10_out => p3_se10_output,
        p3_pc_out => p3_pc_output,
        p3_ra_out => p3_ra_output,
        p3_rb_out => p3_rb_output,
        p3_en => '1',
        clock => input_vector(0)
    );

    inst_pipeline_reg4 : pipeline_reg4
    port map(
        p4_rc_in => p3_rc_output,
        p4_alu_c_in => adder_output,
        p4_opcode_in => p3_opcode_output,
        p4_complement_in => p3_complement_output,
        p4_cz_in => p3_cz_output,
        p4_carry_flag_in => carry_flag,
        p4_zero_flag_in => zero_flag,
        p4_se7_in => p3_se7_output,
        p4_se10_in => p3_se10_output,
        p4_rf_d2_in => p3_rf_1len_h,
        p4_less_than_flag_in => less_than_flag,
        p4_equal_to_flag_in => equal_to_flag,
        p4_ra_in => p3_ra_output,
        p4_rb_in => p3_rb_output,
        p4_rc_out => p4_rc_output,
        p4_alu_c_out => p4_alu_c_output,
        p4_opcode_out => p4_opcode_output,
        p4_complement_out => p4_complement_output,
        p4_cz_out => p4_cz_output,
        p4_carry_flag_out => p4_carry_flag_output,
        p4_zero_flag_out => p4_zero_flag_output,
        p4_se7_out => p4_se7_output,
        p4_se10_out => p4_se10_output,
        p4_rf_d2_out => p4_rf_d2_output,
        p4_less_than_flag_out => p4_less_than_flag_output,
        p4_equal_to_flag_out => p4_equal_to_flag_output,
        p4_ra_out => p4_ra_output,
        p4_rb_out => p4_rb_output,
        p4_en => '1',
        clock => input_vector(0)
    );

    inst_pipeline_reg5 : pipeline_reg5
    port map(
        p5_rc_in => p4_rc_output,
        p5_alu_c_in => p5_aluc_in,
        p5_opcode_in => p4_opcode_output,
        p5_complement_in => p4_complement_output,
        p5_cz_in => p4_cz_output,
        p5_carry_flag_in => p4_carry_flag_output,
        p5_zero_flag_in => p4_zero_flag_output,
        p5_se7_in => p4_se7_output,
        p5_se10_in => p4_se10_output,
        p5_memory_data_in => memory_data_output,
        p5_less_than_flag_in => p4_less_than_flag_output,
        p5_equal_to_flag_in => p4_equal_to_flag_output,
        p5_rc_out => p5_rc_output,
        p5_alu_c_out => p5_alu_c_output,
        p5_opcode_out => p5_opcode_output,
        p5_complement_out => p5_complement_output,
        p5_cz_out => p5_cz_output,
        p5_carry_flag_out => p5_carry_flag_output,
        p5_zero_flag_out => p5_zero_flag_output,
        p5_se7_out => p5_se7_output,
        p5_se10_out => p5_se10_output,
        p5_memory_data_out => p5_memory_data_output,
        p5_less_than_flag_out => p5_less_than_flag_output,
        p5_equal_to_flag_out => p5_equal_to_flag_output,
        p5_en => p5_enable,
        clock => input_vector(0)
    );
    alu_operation_select_process : process (p3_opcode_output)
    begin
        if p3_opcode_output = "0001" or p3_opcode_output = "0000" or p3_opcode_output = "0100" or p3_opcode_output = "0101" or p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010" or p3_opcode_output = "1100" or p3_opcode_output = "1101" or p3_opcode_output = "1111" or p3_opcode_output = "1110" then
            alu_ir_in <= '0';
        elsif p3_opcode_output = "0010" then
            alu_ir_in <= '1';
        end if;
    end process alu_operation_select_process;

    cz_enable_process : process (p3_opcode_output)
    begin
        if p3_opcode_output = "0001" then
            if (p3_cz_output = "10" and carry_flag = '0') then
                cz_enable <= "00";
            else
                cz_enable <= "11";
            end if;
            if (p3_cz_output = "01" and zero_flag = '0') then
                cz_enable <= "00";
            else
                cz_enable <= "11";
            end if;
        elsif p3_opcode_output = "0010" then
            if (p3_cz_output = "10" and carry_flag = '0') then
                cz_enable <= "00";
            else
                cz_enable <= "01";
            end if;
            if (p3_cz_output = "01" and zero_flag = '0') then
                cz_enable <= "00";
            else
                cz_enable <= "01";
            end if;
        elsif p3_opcode_output = "0011" or p3_opcode_output = "1100" or p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010" or p3_opcode_output = "0000"or p3_opcode_output = "0100" or p3_opcode_output = "0101" or p3_opcode_output = "0110" or p3_opcode_output = "0111" or p3_opcode_output = "1101" or p3_opcode_output = "1111" or p3_opcode_output = "1110"then
            cz_enable <= "00";
        else
            cz_enable <= "11";
        end if;
    end process cz_enable_process;

    register_enable_process : process (input_vector(0))
        variable temp : integer := 0;
    begin
        if (rising_edge(input_vector(0))) then
            if p5_opcode_output = "0001" or p5_opcode_output = "0010" then
                if (p5_cz_output = "01" and p5_zero_flag_output = '0') then
                    reg_en(0) <= '1';
                    reg_en(7 downto 1) <= "0000000";
                elsif (p5_cz_output = "10" and p5_carry_flag_output = '0') then
                    reg_en(0) <= '1';
                    reg_en(7 downto 1) <= "0000000";
                elsif ir_opcode_output = "1110" then
                    reg_en(0) <= '0';
                else
                    reg_en(0) <= '1';
                    reg_en(7 downto 1) <= "1111111";
                end if;
            elsif (p5_opcode_output = "1100" or p5_opcode_output = "1101" or p5_opcode_output = "1111" or ((p5_opcode_output = "1000" and p5_equal_to_flag_output = '1')
                or
                (p5_opcode_output = "1001" and p5_less_than_flag_output = '1')
                or
                (p5_opcode_output = "1000" and (p5_equal_to_flag_output = '1' or p5_less_than_flag_output = '1'))
                )) and p5_enable = '1' then
                p5_enable <= '0';
            elsif (p5_opcode_output = "1100" or p5_opcode_output = "1101" or p5_opcode_output = "1111"or ((p5_opcode_output = "1000" and p5_equal_to_flag_output = '1')
                or
                (p5_opcode_output = "1001" and p5_less_than_flag_output = '1')
                or
                (p5_opcode_output = "1000" and (p5_equal_to_flag_output = '1' or p5_less_than_flag_output = '1'))
                )) and p5_enable = '0' and temp < 2 then
                temp := temp + 1;
                reg_en(7 downto 1) <= "0000000";
            elsif (p5_opcode_output = "1100" or p5_opcode_output = "1101" or p5_opcode_output = "1111"or ((p5_opcode_output = "1000" and p5_equal_to_flag_output = '1')
                or
                (p5_opcode_output = "1001" and p5_less_than_flag_output = '1')
                or
                (p5_opcode_output = "1000" and (p5_equal_to_flag_output = '1' or p5_less_than_flag_output = '1'))
                )) and temp = 2 then
                p5_enable <= '1';
                reg_en(7 downto 1) <= "1111111";
                temp := 0;
            elsif p5_opcode_output = "0101" or p5_opcode_output = "1110" then

                reg_en <= x"00";
            elsif p5_opcode_output = "1111" then
                reg_en(0) <= '1';
                reg_en(7 downto 1) <= "0000000";
            elsif p5_opcode_output = "1000" or p5_opcode_output = "1001" or p5_opcode_output = "1010" then
                if p5_equal_to_flag_output = '1' or p5_less_than_flag_output = '1' then
                    reg_en(0) <= '1';
                    reg_en(7 downto 1) <= "0000000";
                else
                    reg_en(0) <= '0';
                    reg_en(7 downto 1) <= "0000000";
                end if;
            elsif p5_opcode_output = "0011" or p5_opcode_output = "0100" or p5_opcode_output = "0000" or p5_opcode_output = "1101" then
                reg_en(7 downto 1) <= "1111111";
            elsif ir_opcode_output = "1110" then
                reg_en(0) <= '0';
            else
                reg_en <= x"FF";
            end if;
        end if;
    end process register_enable_process;

    alu_b_select_process : process (p3_opcode_output, p3_cz_output, input_vector(0))
    begin
        if ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and (p3_opcode_output = "0010" or p3_opcode_output = "0001")) then
            if p4_rc_output = p3_rb_output then
                alu_b_input <= p5_aluc_in;
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif (p4_opcode_output = "0100" and (p3_opcode_output = "0001" or p3_opcode_output = "0010")) then
            if p4_rc_output = p3_rb_output then
                alu_b_input <= memory_data_output;
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif (p4_opcode_output = "0011" and (p3_opcode_output = "0001" or p3_opcode_output = "0010")) then
            if p4_rc_output = p3_rb_output then
                alu_b_input <= p5_aluc_in;
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif (((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "0001" or p3_opcode_output = "0010"))) then
            if p4_rc_output = p3_rb_output then
                alu_b_input <= p3_pc_output + x"0001";
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif (((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "0001" or p3_opcode_output = "0010"))) then
            if p4_rc_output = p3_pc_output then
                alu_b_input <= p3_rb_output + x"0001";
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "1101")) then
            if p4_rc_output = p3_rb_output then
                alu_b_input <= p3_pc_output + x"0001";
            else
                alu_b_input <= p3_rf_d2_output;
            end if;
        elsif ((p3_opcode_output = "0000" or p3_opcode_output = "0100" or p3_opcode_output = "0101" or p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            alu_b_input <= p3_se10_output;
        elsif p3_opcode_output = "1100" or p3_opcode_output = "1111" then
            alu_b_input <= p3_se7_output;
        else
            alu_b_input <= p3_rf_d2_output;
        end if;
    end process alu_b_select_process;

    adder_b_input_process : process (p3_opcode_output, p3_cz_output, input_vector(0))
    begin
        if p3_opcode_output = "0001" and p3_cz_output = "11" then
            if carry_flag = '1' then
                adder_b_input <= x"0001";
            else
                adder_b_input <= x"0000";
            end if;
        elsif p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010" then
            adder_b_input <= p3_se10_output;
        elsif p3_opcode_output = "1100" then
            adder_b_input <= p3_se7_output;
        else
            adder_b_input <= x"0000";
        end if;
    end process adder_b_input_process;

    -- p5_alu_c_in
    p5_alu_c_in_select_process : process (p4_se10_output, p4_alu_c_output, p4_opcode_output, memory_data_output)
    begin
        if p4_opcode_output = "0011" then
            p5_aluc_in <= p4_se7_output;
        elsif p4_opcode_output = "0100" or p4_opcode_output = "1111" then
            p5_aluc_in <= memory_data_output;
        else
            p5_aluc_in <= p4_alu_c_output;
        end if;
    end process p5_alu_c_in_select_process;

    mem_write_en_update_process : process (p4_opcode_output)
    begin
        if p4_opcode_output = "0101" then
            mem_write_en <= '1';
        else
            mem_write_en <= '0';
        end if;
    end process mem_write_en_update_process;

    alu_a_update_process : process (p3_opcode_output, input_vector(0))
    begin
        if ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and (p3_opcode_output = "0010" or p3_opcode_output = "0001")) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p5_aluc_in;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "0001" or p4_opcode_output = "0010") and p3_opcode_output = "0100") then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p4_alu_c_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0100" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0000")) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= memory_data_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and p3_opcode_output = "0101") then
            if (p4_rc_output = p3_ra_output) then
                alu_a_input <= p4_alu_c_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0100" and p3_opcode_output = "0101") then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= memory_data_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0101" and p3_opcode_output = "0100") then
            if (p4_rb_output = p3_ra_output) then
                alu_a_input <= memory_data_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0011" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0000")) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p5_aluc_in;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0011" and (p3_opcode_output = "0100" or p3_opcode_output = "0101")) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p4_se10_output;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "0001" or p4_opcode_output = "0010") and p3_opcode_output = "0000")
            or
            (p4_opcode_output = "0000" and p3_opcode_output = "0100")
            then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p5_aluc_in;
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif (((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "0001" or p3_opcode_output = "0010"))) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p3_pc_output + x"0001";
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and p3_opcode_output = "0000") then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p3_pc_output + x"0001";
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and p3_opcode_output = "0100") then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p3_pc_output + x"0001";
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and p3_opcode_output = "0101") then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p3_pc_output + x"0001";
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "1111")) then
            if p4_rc_output = p3_ra_output then
                alu_a_input <= p3_pc_output + x"0001";
            else
                alu_a_input <= p3_rf_d1_output;
            end if;
        elsif p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010" or p3_opcode_output = "1100" then
            alu_a_input <= p3_pc_output;
        elsif p3_opcode_output = "1101" then
            alu_a_input <= x"0000";
        else
            alu_a_input <= p3_rf_d1_output;
        end if;
    end process alu_a_update_process;

    pc_in_update : process (input_vector(0))
    begin
        if boot_flag = '1' then
            boot_flag <= '0';
            reset_signal <= '1';
            pc_input <= x"0001";
        else
            reset_signal <= input_vector(1);
            if p3_opcode_output = "1000" then
                if equal_to_flag = '1' then
                    pc_input <= adder_output;
                else
                    pc_input <= pc_input_from_adder;
                end if;
            elsif p3_opcode_output = "1001" then
                if less_than_flag = '1' then
                    pc_input <= adder_output;
                else
                    pc_input <= pc_input_from_adder;
                end if;
            elsif p3_opcode_output = "1010" then
                if less_than_flag = '1' or equal_to_flag = '1' then
                    pc_input <= adder_output;
                else
                    pc_input <= pc_input_from_adder;
                end if;
            elsif (p3_opcode_output = "1100" or p3_opcode_output = "1101" or p3_opcode_output = "1111") and p5_enable = '1' then
                pc_input <= adder_output;
            else
                pc_input <= pc_input_from_adder;
            end if;
        end if;
    end process pc_in_update;

    rf_d3_update_process : process (p5_opcode_output, input_vector(0), p3_pc_output, p5_alu_c_output)
    begin
        if p5_opcode_output = "1100" or p5_opcode_output = "1101" then
            reg_d3_input <= p3_pc_output;
        else
            reg_d3_input <= p5_alu_c_output;
        end if;
    end process rf_d3_update_process;

    mem_process : process (input_vector(0))
    begin
        if (p4_opcode_output = "0100" and p3_opcode_output = "0101") then
            if p4_rc_output = p3_rb_output then
                p3_rf_1len_h <= memory_data_output;
            else
                p3_rf_1len_h <= p3_rf_d2_output;
            end if;
        elsif ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and p3_opcode_output = "0101") then
            if (p4_rc_output = p3_rb_output) then
                p3_rf_1len_h <= p4_alu_c_output;
            else
                p3_rf_1len_h <= p3_rf_d2_output;
            end if;
        elsif (p4_opcode_output = "0011" and p3_opcode_output = "0101") then
            if p4_rc_output = p3_rb_output then
                p3_rf_1len_h <= p4_se7_output;
            else
                p3_rf_1len_h <= p3_rf_d2_output;
            end if;
        else
            p3_rf_1len_h <= p3_rf_d2_output;
        end if;
    end process mem_process;

    comperator_a_input_process : process (input_vector(0))
    begin
        if ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_1 <= p5_aluc_in;
            else
                comparator_input_1 <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0011" and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_1 <= p4_se7_output;
            else
                comparator_input_1 <= p3_rf_d1_output;
            end if;
        elsif (p4_opcode_output = "0100" and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_1 <= memory_data_output;
            else
                comparator_input_1 <= p3_rf_d1_output;
            end if;
        elsif ((p4_opcode_output = "1100" or p4_opcode_output = "1101") and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_1 <= p3_pc_output + x"0001";
            else
                comparator_input_1 <= p3_rf_d1_output;
            end if;
        else
            comparator_input_1 <= p3_rf_d1_output;
        end if;
    end process comperator_a_input_process;

    comperator_b_input_process : process (input_vector(0))
    begin
        if ((p4_opcode_output = "0001" or p4_opcode_output = "0010" or p4_opcode_output = "0000") and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_2 <= p5_aluc_in;
            else
                comparator_input_2 <= p3_rf_d2_output;
            end if;
        elsif (p4_opcode_output = "0100" and (p3_opcode_output = "1000" or p3_opcode_output = "1001" or p3_opcode_output = "1010")) then
            if p4_rc_output = p3_ra_output then
                comparator_input_2 <= memory_data_output;
            else
                comparator_input_2 <= p3_rf_d2_output;
            end if;
        else
            comparator_input_2 <= p3_rf_d2_output;
        end if;
    end process comperator_b_input_process;

    rf_d1_d2_update_process : process (input_vector(0), l2hzd1, l2hzd2, reg_d3_input, p5_rc_output, p3_ra_output, p3_rb_output)
    begin
        if (p5_rc_output = p3_ra_output and not (reg_en(7 downto 1) = "0000000")) then
            p3_rf_d1_output <= reg_d3_input;
        else
            p3_rf_d1_output <= l2hzd1;
        end if;
        if (p5_rc_output = p3_rb_output and not (reg_en(7 downto 1) = "0000000")) then
            p3_rf_d2_output <= reg_d3_input;
        else
            p3_rf_d2_output <= l2hzd2;
        end if;
    end process rf_d1_d2_update_process;

    rf_d1_d2_in_update_process : process (input_vector(0), l3hzd1, l3hzd2, reg_d3_input, p5_rc_output, p2_ra_output, p2_rb_output)
    begin
        if (p5_rc_output = p2_ra_output and not (reg_en(7 downto 1) = "0000000")) then
            reg_d1_output <= reg_d3_input;
        else
            reg_d1_output <= l3hzd1;
        end if;
        if (p5_rc_output = p2_rb_output and not (reg_en(7 downto 1) = "0000000")) then
            reg_d2_output <= reg_d3_input;
        else
            reg_d2_output <= l3hzd2;
        end if;
    end process rf_d1_d2_in_update_process;
    -- hazard_detector_process_2_len:process(input_vector(0))
    -- begin
    --     if p3_opcode_output = "0001" or p3_opcode_output = "0010" then
    --         if p5_rc_output = p3_ra_output  then
    --             wb_alu_a <= '1';
    --         else
    --             wb_alu_a <= '0';
    --         end if;
    --         if p5_rc_output = p3_rb_output then
    --             wb_alu_b <= '1';
    --         else
    --             wb_alu_b <= '0';
    --         end if;
    --     elsif p3_opcode_output = "0000" then
    --         if p5_rc_output = p3_ra_output  then
    --             wb_alu_a <= '1';
    --         else
    --             wb_alu_a <= '0';
    --         end if;
    --     end if;
    -- end process hazard_detector_process_2_len;

    -- hazard_detector_process_1_len:process(input_vector(0))
    -- begin
    --     if (
    --         -- (p4_opcode_output = "0001" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0100" or p3_opcode_output = "0101" ))
    --         -- or
    --         -- (p4_opcode_output = "0010" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0100" or p3_opcode_output = "0101"))
    --         -- or
    --         -- (p4_opcode_output = "0011" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0101" or p3_opcode_output = "0100"))
    --         -- or
    --         -- (p4_opcode_output = "0100" and (p3_opcode_output = "0001" or p3_opcode_output = "0010" or p3_opcode_output = "0101" or p3_opcode_output = "0100"))

    --     ) then
    --         if p4_rc_output = p3_ra_output then
    --             mem_alu_a <= '1';
    --         else
    --             mem_alu_a <= '0';
    --         end if;
    --         if p4_rc_output = p3_rb_output then
    --             mem_alu_b <= '1';
    --         else
    --             mem_alu_b <= '0';
    --         end if;
    --     end if;
    -- end process hazard_detector_process_1_len;
end architecture working;