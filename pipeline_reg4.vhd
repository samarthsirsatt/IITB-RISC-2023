library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_reg4 is
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
end entity pipeline_reg4;

architecture working of pipeline_reg4 is

begin
    p4_write_process : process (clock)
    begin
        if (falling_edge(clock)) then
            if (p4_en = '1') then
                p4_rc_out <= p4_rc_in;
                p4_alu_c_out <= p4_alu_c_in;
                p4_opcode_out <= p4_opcode_in;
                p4_complement_out <= p4_complement_in;
                p4_cz_out <= p4_cz_in;
                p4_carry_flag_out <= p4_carry_flag_in;
                p4_zero_flag_out <= p4_zero_flag_in;
                p4_se7_out <= p4_se7_in;
                p4_se10_out <= p4_se10_in;
                p4_rf_d2_out <= p4_rf_d2_in;
                p4_less_than_flag_out <= p4_less_than_flag_in;
                p4_equal_to_flag_out <= p4_equal_to_flag_in;
                p4_ra_out <= p4_ra_in;
                p4_rb_out <= p4_rb_in;
            end if;
        end if;
    end process p4_write_process;
end architecture working;