-- Importing the std_logic library
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;
use std.textio.all;

entity register_file is
    port (
        reg_a1 : in std_logic_vector(2 downto 0);
        reg_a2 : in std_logic_vector(2 downto 0);
        reg_a3 : in std_logic_vector(2 downto 0);
        reg_en : in std_logic_vector(7 downto 0);
        reg_d3 : in std_logic_vector(15 downto 0);
        reg_d1 : out std_logic_vector(15 downto 0);
        reg_d2 : out std_logic_vector(15 downto 0);
        pc_in : in std_logic_vector(15 downto 0);
        pc_out : out std_logic_vector(15 downto 0);
        clock : in std_logic;
        reset : in std_logic
    );
end register_file;

architecture working of register_file is

    -- 8 16bit-registers
    type register_array is array (0 to 7) of std_logic_vector (15 downto 0);
    signal registers : register_array := (
        x"0000", x"0004", x"0001", x"0006",
        x"FFFF", x"0005", x"F006", x"F007"
    );
    signal PC : std_logic_vector (15 downto 0) := x"0000";

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

begin

    pc_read_process : process (PC)
    begin
        pc_out <= PC;
    end process pc_read_process;

    pc_write_process : process (clock)
    begin
        if (reset = '1') then
            PC <= x"0000";
        else
            if (falling_edge(clock)) then
                if (reg_en(0) = '1') then
                    PC <= pc_in;
                end if;
            end if;
        end if;
    end process pc_write_process;

    register_a1_a2_read_process : process (reg_a1, reg_a2)
    begin
        if (reg_a1 = "000") then
            reg_d1 <= PC;
        else
            reg_d1 <= registers(to_integer(unsigned(reg_a1)));
        end if;

        if (reg_a2 = "000") then
            reg_d2 <= PC;
        else
            reg_d2 <= registers(to_integer(unsigned(reg_a2)));
        end if;
    end process register_a1_a2_read_process;

    register_a1_a2_write_process : process (clock)
    begin
        if (reset = '1') then
            registers <= (others => x"0000");
        else
            if (falling_edge(clock)) then
                if (reg_en(to_integer(unsigned(reg_a3))) = '1') then
                    registers(to_integer(unsigned(reg_a3))) <= reg_d3;
                end if;
            end if;
        end if;
    end process register_a1_a2_write_process;

    write_reg_output : process (clock)
        variable out_line : line;
        variable cycle_count : integer := 0;
        file output_file : text open write_mode is "../register_values.txt";
    begin
        if (falling_edge(clock)) then
            cycle_count := cycle_count + 1;
            write(output_file, "Cycle : " & integer'image(cycle_count) & LF);
            write(output_file, "PC: " & to_string_std_logic_vector(PC) & "  =  " & integer'image(to_integer(unsigned(PC))) & "  |  " & to_string_std_logic_vector(reg_en) & LF);
            write(output_file, "1 : " & to_string_std_logic_vector(registers(1)) & "  =  " & integer'image(to_integer(unsigned(registers(1)))) & LF);
            write(output_file, "2 : " & to_string_std_logic_vector(registers(2)) & "  =  " & integer'image(to_integer(unsigned(registers(2)))) & LF);
            write(output_file, "3 : " & to_string_std_logic_vector(registers(3)) & "  =  " & integer'image(to_integer(unsigned(registers(3)))) & LF);
            write(output_file, "4 : " & to_string_std_logic_vector(registers(4)) & "  =  " & integer'image(to_integer(unsigned(registers(4)))) & LF);
            write(output_file, "5 : " & to_string_std_logic_vector(registers(5)) & "  =  " & integer'image(to_integer(unsigned(registers(5)))) & LF);
            write(output_file, "6 : " & to_string_std_logic_vector(registers(6)) & "  =  " & integer'image(to_integer(unsigned(registers(6)))) & LF);
            write(output_file, "7 : " & to_string_std_logic_vector(registers(7)) & "  =  " & integer'image(to_integer(unsigned(registers(7)))) & LF);
            write(output_file, "" & LF);
        end if;
    end process write_reg_output;
end architecture working;