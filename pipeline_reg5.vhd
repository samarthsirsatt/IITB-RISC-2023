library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_reg5 is
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
end entity pipeline_reg5;

architecture working of pipeline_reg5 is

begin
    p1_write_process : process (clock)
    begin
        if (falling_edge(clock)) then
            if (p5_en = '1') then
                p5_rc_out <= p5_rc_in;
                p5_alu_c_out <= p5_alu_c_in;
                p5_opcode_out <= p5_opcode_in;
                p5_complement_out <= p5_complement_in;
                p5_cz_out <= p5_cz_in;
                p5_carry_flag_out <= p5_carry_flag_in;
                p5_zero_flag_out <= p5_zero_flag_in;
                p5_se7_out <= p5_se7_in;
                p5_se10_out <= p5_se10_in;
                p5_memory_data_out <= p5_memory_data_in;
                p5_less_than_flag_out <= p5_less_than_flag_in;
                p5_equal_to_flag_out <= p5_equal_to_flag_in;
            end if;
        end if;
    end process p1_write_process;
end architecture working;