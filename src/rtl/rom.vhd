----------------------------------------------------------------------------------------------------
-- Copyright (c) 2019 Marcus Geelnard
--
-- This software is provided 'as-is', without any express or implied warranty. In no event will the
-- authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose, including commercial
-- applications, and to alter it and redistribute it freely, subject to the following restrictions:
--
--  1. The origin of this software must not be misrepresented; you must not claim that you wrote
--     the original software. If you use this software in a product, an acknowledgment in the
--     product documentation would be appreciated but is not required.
--
--  2. Altered source versions must be plainly marked as such, and must not be misrepresented as
--     being the original software.
--
--  3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- This is a single-ported ROM (Wishbone B4 pipelined interface).
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port(
    -- Control signals.
    i_clk : in std_logic;

    -- Wishbone memory interface (b4 pipelined slave).
    -- See: https://cdn.opencores.org/downloads/wbspec_b4.pdf
    i_wb_cyc : in std_logic;
    i_wb_stb : in std_logic;
    i_wb_adr : in std_logic_vector(31 downto 2);
    o_wb_dat : out std_logic_vector(31 downto 0);
    o_wb_ack : out std_logic;
    o_wb_stall : out std_logic
  );
end rom;

architecture rtl of rom is
  constant C_ADDR_BITS : positive := 11;
  constant C_ROM_SIZE : positive := 2**C_ADDR_BITS;

  type T_ROM_ARRAY is array (0 to C_ROM_SIZE-1) of std_logic_vector(31 downto 0);
  constant C_ROM_ARRAY : T_ROM_ARRAY := (
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"e8200000",
    x"e8400000",
    x"e8600000",
    x"e8800000",
    x"e8a00000",
    x"e8c00000",
    x"e8e00000",
    x"e9000000",
    x"e9200000",
    x"e9400000",
    x"e9600000",
    x"e9800000",
    x"e9a00000",
    x"e9c00000",
    x"e9e00000",
    x"ea000000",
    x"ea200000",
    x"ea400000",
    x"ea600000",
    x"ea800000",
    x"eaa00000",
    x"eac00000",
    x"eae00000",
    x"eb000000",
    x"eb200000",
    x"eb400000",
    x"eb600000",
    x"eb800000",
    x"eba00000",
    x"ebc00000",
    x"03a00000",
    x"40208000",
    x"40408000",
    x"40608000",
    x"40808000",
    x"40a08000",
    x"40c08000",
    x"40e08000",
    x"41008000",
    x"41208000",
    x"41408000",
    x"41608000",
    x"41808000",
    x"41a08000",
    x"41c08000",
    x"41e08000",
    x"42008000",
    x"42208000",
    x"42408000",
    x"42608000",
    x"42808000",
    x"42a08000",
    x"42c08000",
    x"42e08000",
    x"43008000",
    x"43208000",
    x"43408000",
    x"43608000",
    x"43808000",
    x"43a08000",
    x"43c08000",
    x"43e08000",
    x"eba00000",
    x"40208000",
    x"40408000",
    x"40608000",
    x"40808000",
    x"40a08000",
    x"40c08000",
    x"40e08000",
    x"41008000",
    x"41208000",
    x"41408000",
    x"41608000",
    x"41808000",
    x"41a08000",
    x"41c08000",
    x"41e08000",
    x"42008000",
    x"42208000",
    x"42408000",
    x"42608000",
    x"42808000",
    x"42a08000",
    x"42c08000",
    x"42e08000",
    x"43008000",
    x"43208000",
    x"43408000",
    x"43608000",
    x"43808000",
    x"43a08000",
    x"43c08000",
    x"43e08000",
    x"03a00000",
    x"ef880080",
    x"579c0000",
    x"e8200001",
    x"ec400002",
    x"5442000c",
    x"ede00000",
    x"e5e000f1",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"e3e00000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"579c7ffc",
    x"2fdc0000",
    x"e7e00005",
    x"e7e0005e",
    x"0fdc0000",
    x"579c0004",
    x"e3c00000",
    x"579c7ffc",
    x"2fbc0000",
    x"ed680000",
    x"416b0000",
    x"ed90400a",
    x"418c0555",
    x"2d8b0000",
    x"ed90a000",
    x"418c0002",
    x"2d8b0004",
    x"ed90c000",
    x"418c0001",
    x"2d8b0008",
    x"ed8c0000",
    x"418c00ff",
    x"2d8b000c",
    x"556b0010",
    x"e8200064",
    x"e8400032",
    x"e8600000",
    x"e8800002",
    x"e8a00003",
    x"e8c00001",
    x"edffe000",
    x"2deb0000",
    x"e9c00001",
    x"88e30010",
    x"89020008",
    x"00e71010",
    x"00e70210",
    x"00e71e10",
    x"00eb1d0b",
    x"00210815",
    x"6ce100ff",
    x"0100021b",
    x"00e71012",
    x"c8e00003",
    x"00840016",
    x"00210815",
    x"00420a15",
    x"6ce200ff",
    x"0100041b",
    x"00e71012",
    x"c8e00003",
    x"00a50016",
    x"00420a15",
    x"00630c15",
    x"6ce300ff",
    x"0100061b",
    x"00e71012",
    x"c8e00003",
    x"00c60016",
    x"00630c15",
    x"55ce0001",
    x"60ee0100",
    x"c8ffffe3",
    x"556b0400",
    x"ec2a0000",
    x"ec500000",
    x"40420400",
    x"2c2b0000",
    x"2c4b0004",
    x"ed908000",
    x"418c0780",
    x"2d8b0008",
    x"556b000c",
    x"e3e00004",
    x"2c2b0000",
    x"2c4b0004",
    x"556b0008",
    x"54210003",
    x"544200a0",
    x"49a13fff",
    x"65ad0438",
    x"c9bffff9",
    x"ed8a000f",
    x"418c07ff",
    x"2d8b0000",
    x"ed280002",
    x"41290000",
    x"01400000",
    x"e960e100",
    x"03aa161d",
    x"017d1616",
    x"2c098004",
    x"01293b07",
    x"c57ffffc",
    x"0fbc0000",
    x"579c0004",
    x"e3c00000",
    x"579c7ff4",
    x"2fdc0000",
    x"2e9c0004",
    x"2ebc0008",
    x"ee980000",
    x"eaa00001",
    x"2eb40060",
    x"0c340020",
    x"e7e00295",
    x"00202a10",
    x"e7e0000a",
    x"e8200010",
    x"e7e00276",
    x"56b50001",
    x"c01ffff8",
    x"0fdc0000",
    x"0e9c0004",
    x"0ebc0008",
    x"579c000c",
    x"e3c00000",
    x"579c7ffc",
    x"2fdc0000",
    x"ec580000",
    x"0c420028",
    x"48420001",
    x"c0400003",
    x"e7e00043",
    x"c0000002",
    x"e7e00004",
    x"0fdc0000",
    x"579c0004",
    x"e3c00000",
    x"579c7ffc",
    x"2e9c0000",
    x"0dbf00e8",
    x"0e3f00d4",
    x"0e5f00d4",
    x"00210068",
    x"00210272",
    x"ec478478",
    x"00410472",
    x"ec67f000",
    x"00420670",
    x"02830473",
    x"01ad2872",
    x"edc80002",
    x"41ce0000",
    x"ea000168",
    x"84700001",
    x"00630068",
    x"006d0672",
    x"0c5f00a0",
    x"00420671",
    x"e9e00280",
    x"846f0001",
    x"00630068",
    x"006d0672",
    x"0c3f0084",
    x"00210671",
    x"00600010",
    x"00800010",
    x"e9200000",
    x"00a30672",
    x"00c40872",
    x"55290001",
    x"00830872",
    x"00650c71",
    x"00a50c70",
    x"00840870",
    x"00630270",
    x"01492219",
    x"00840470",
    x"00a52464",
    x"cca00003",
    x"c95ffff4",
    x"e9200000",
    x"89290001",
    x"252e0000",
    x"55ce0001",
    x"55ef7fff",
    x"00211a70",
    x"ddffffea",
    x"56107fff",
    x"00421a70",
    x"de1fffe1",
    x"0e9c0000",
    x"579c0004",
    x"e3c00000",
    x"0000007f",
    x"40800000",
    x"bf9403b1",
    x"be8ef344",
    x"3be56042",
    x"579c7ff8",
    x"2e9c0000",
    x"2ebc0004",
    x"00210215",
    x"01a00000",
    x"03a01a10",
    x"544d7fff",
    x"1c82ffff",
    x"56bf0074",
    x"ecc80002",
    x"40c60000",
    x"e9000168",
    x"55087fff",
    x"01280215",
    x"e8e00140",
    x"03ad0e1d",
    x"00fd0e16",
    x"00e48e15",
    x"02870287",
    x"0124a815",
    x"490983ff",
    x"0115d082",
    x"00e7d140",
    x"00279315",
    x"2c268002",
    x"00c61a87",
    x"dcfffff5",
    x"dd1ffff1",
    x"ed580000",
    x"0d8a0020",
    x"0d6a0020",
    x"016b1818",
    x"cd7ffffe",
    x"0e9c0000",
    x"0ebc0004",
    x"579c0008",
    x"e3c00000",
    x"00c90000",
    x"025b0192",
    x"03ed0324",
    x"057f04b6",
    x"07110648",
    x"08a207d9",
    x"0a33096a",
    x"0bc40afb",
    x"0d540c8c",
    x"0ee30e1c",
    x"10720fab",
    x"1201113a",
    x"138f12c8",
    x"151c1455",
    x"16a815e2",
    x"1833176e",
    x"19be18f9",
    x"1b471a82",
    x"1ccf1c0b",
    x"1e571d93",
    x"1fdd1f1a",
    x"2161209f",
    x"22e52223",
    x"246723a6",
    x"25e82528",
    x"276726a8",
    x"28e52826",
    x"2a6129a3",
    x"2bdc2b1f",
    x"2d552c99",
    x"2ecc2e11",
    x"30412f87",
    x"31b530fb",
    x"3326326e",
    x"349633df",
    x"3604354d",
    x"376f36ba",
    x"38d93824",
    x"3a40398c",
    x"3ba53af2",
    x"3d073c56",
    x"3e683db8",
    x"3fc53f17",
    x"41214073",
    x"427a41ce",
    x"43d04325",
    x"4524447a",
    x"467545cd",
    x"47c3471c",
    x"490f4869",
    x"4a5849b4",
    x"4b9d4afb",
    x"4ce04c3f",
    x"4e204d81",
    x"4f5d4ebf",
    x"50974ffb",
    x"51ce5133",
    x"53025268",
    x"5432539b",
    x"556054c9",
    x"568a55f5",
    x"57b0571d",
    x"58d35842",
    x"59f35964",
    x"5b0f5a82",
    x"5c285b9c",
    x"5d3e5cb3",
    x"5e4f5dc7",
    x"5f5d5ed7",
    x"60685fe3",
    x"616e60eb",
    x"627161f0",
    x"637062f1",
    x"646c63ee",
    x"656364e8",
    x"665665dd",
    x"674666cf",
    x"683267bc",
    x"691968a6",
    x"69fd698b",
    x"6adc6a6d",
    x"6bb76b4a",
    x"6c8e6c23",
    x"6d616cf8",
    x"6e306dc9",
    x"6efb6e96",
    x"6fc16f5e",
    x"70837022",
    x"714070e2",
    x"71f9719d",
    x"72ae7254",
    x"735e7307",
    x"740a73b5",
    x"74b2745f",
    x"75557504",
    x"75f375a5",
    x"768d7641",
    x"772276d8",
    x"77b3776b",
    x"783f77fa",
    x"78c77884",
    x"794a7909",
    x"79c87989",
    x"7a417a05",
    x"7ab67a7c",
    x"7b267aee",
    x"7b917b5c",
    x"7bf87bc5",
    x"7c597c29",
    x"7cb67c88",
    x"7d0e7ce3",
    x"7d627d39",
    x"7db07d89",
    x"7dfa7dd5",
    x"7e3e7e1d",
    x"7e7e7e5f",
    x"7eb97e9c",
    x"7eef7ed5",
    x"7f217f09",
    x"7f4d7f37",
    x"7f747f61",
    x"7f977f86",
    x"7fb47fa6",
    x"7fcd7fc1",
    x"7fe17fd8",
    x"7ff07fe9",
    x"7ff97ff5",
    x"7ffe7ffd",
    x"7ffe7fff",
    x"7ff97ffd",
    x"7ff07ff5",
    x"7fe17fe9",
    x"7fcd7fd8",
    x"7fb47fc1",
    x"7f977fa6",
    x"7f747f86",
    x"7f4d7f61",
    x"7f217f37",
    x"7eef7f09",
    x"7eb97ed5",
    x"7e7e7e9c",
    x"7e3e7e5f",
    x"7dfa7e1d",
    x"7db07dd5",
    x"7d627d89",
    x"7d0e7d39",
    x"7cb67ce3",
    x"7c597c88",
    x"7bf87c29",
    x"7b917bc5",
    x"7b267b5c",
    x"7ab67aee",
    x"7a417a7c",
    x"79c87a05",
    x"794a7989",
    x"78c77909",
    x"783f7884",
    x"77b377fa",
    x"7722776b",
    x"768d76d8",
    x"75f37641",
    x"755575a5",
    x"74b27504",
    x"740a745f",
    x"735e73b5",
    x"72ae7307",
    x"71f97254",
    x"7140719d",
    x"708370e2",
    x"6fc17022",
    x"6efb6f5e",
    x"6e306e96",
    x"6d616dc9",
    x"6c8e6cf8",
    x"6bb76c23",
    x"6adc6b4a",
    x"69fd6a6d",
    x"6919698b",
    x"683268a6",
    x"674667bc",
    x"665666cf",
    x"656365dd",
    x"646c64e8",
    x"637063ee",
    x"627162f1",
    x"616e61f0",
    x"606860eb",
    x"5f5d5fe3",
    x"5e4f5ed7",
    x"5d3e5dc7",
    x"5c285cb3",
    x"5b0f5b9c",
    x"59f35a82",
    x"58d35964",
    x"57b05842",
    x"568a571d",
    x"556055f5",
    x"543254c9",
    x"5302539b",
    x"51ce5268",
    x"50975133",
    x"4f5d4ffb",
    x"4e204ebf",
    x"4ce04d81",
    x"4b9d4c3f",
    x"4a584afb",
    x"490f49b4",
    x"47c34869",
    x"4675471c",
    x"452445cd",
    x"43d0447a",
    x"427a4325",
    x"412141ce",
    x"3fc54073",
    x"3e683f17",
    x"3d073db8",
    x"3ba53c56",
    x"3a403af2",
    x"38d9398c",
    x"376f3824",
    x"360436ba",
    x"3496354d",
    x"332633df",
    x"31b5326e",
    x"304130fb",
    x"2ecc2f87",
    x"2d552e11",
    x"2bdc2c99",
    x"2a612b1f",
    x"28e529a3",
    x"27672826",
    x"25e826a8",
    x"24672528",
    x"22e523a6",
    x"21612223",
    x"1fdd209f",
    x"1e571f1a",
    x"1ccf1d93",
    x"1b471c0b",
    x"19be1a82",
    x"183318f9",
    x"16a8176e",
    x"151c15e2",
    x"138f1455",
    x"120112c8",
    x"1072113a",
    x"0ee30fab",
    x"0d540e1c",
    x"0bc40c8c",
    x"0a330afb",
    x"08a2096a",
    x"071107d9",
    x"057f0648",
    x"03ed04b6",
    x"025b0324",
    x"00c90192",
    x"ff370000",
    x"fda5fe6e",
    x"fc13fcdc",
    x"fa81fb4a",
    x"f8eff9b8",
    x"f75ef827",
    x"f5cdf696",
    x"f43cf505",
    x"f2acf374",
    x"f11df1e4",
    x"ef8ef055",
    x"edffeec6",
    x"ec71ed38",
    x"eae4ebab",
    x"e958ea1e",
    x"e7cde892",
    x"e642e707",
    x"e4b9e57e",
    x"e331e3f5",
    x"e1a9e26d",
    x"e023e0e6",
    x"de9fdf61",
    x"dd1bdddd",
    x"db99dc5a",
    x"da18dad8",
    x"d899d958",
    x"d71bd7da",
    x"d59fd65d",
    x"d424d4e1",
    x"d2abd367",
    x"d134d1ef",
    x"cfbfd079",
    x"ce4bcf05",
    x"ccdacd92",
    x"cb6acc21",
    x"c9fccab3",
    x"c891c946",
    x"c727c7dc",
    x"c5c0c674",
    x"c45bc50e",
    x"c2f9c3aa",
    x"c198c248",
    x"c03bc0e9",
    x"bedfbf8d",
    x"bd86be32",
    x"bc30bcdb",
    x"badcbb86",
    x"b98bba33",
    x"b83db8e4",
    x"b6f1b797",
    x"b5a8b64c",
    x"b463b505",
    x"b320b3c1",
    x"b1e0b27f",
    x"b0a3b141",
    x"af69b005",
    x"ae32aecd",
    x"acfead98",
    x"abceac65",
    x"aaa0ab37",
    x"a976aa0b",
    x"a850a8e3",
    x"a72da7be",
    x"a60da69c",
    x"a4f1a57e",
    x"a3d8a464",
    x"a2c2a34d",
    x"a1b1a239",
    x"a0a3a129",
    x"9f98a01d",
    x"9e929f15",
    x"9d8f9e10",
    x"9c909d0f",
    x"9b949c12",
    x"9a9d9b18",
    x"99aa9a23",
    x"98ba9931",
    x"97ce9844",
    x"96e7975a",
    x"96039675",
    x"95249593",
    x"944994b6",
    x"937293dd",
    x"929f9308",
    x"91d09237",
    x"9105916a",
    x"903f90a2",
    x"8f7d8fde",
    x"8ec08f1e",
    x"8e078e63",
    x"8d528dac",
    x"8ca28cf9",
    x"8bf68c4b",
    x"8b4e8ba1",
    x"8aab8afc",
    x"8a0d8a5b",
    x"897389bf",
    x"88de8928",
    x"884d8895",
    x"87c18806",
    x"8739877c",
    x"86b686f7",
    x"86388677",
    x"85bf85fb",
    x"854a8584",
    x"84da8512",
    x"846f84a4",
    x"8408843b",
    x"83a783d7",
    x"834a8378",
    x"82f2831d",
    x"829e82c7",
    x"82508277",
    x"8206822b",
    x"81c281e3",
    x"818281a1",
    x"81478164",
    x"8111812b",
    x"80df80f7",
    x"80b380c9",
    x"808c809f",
    x"8069807a",
    x"804c805a",
    x"8033803f",
    x"801f8028",
    x"80108017",
    x"8007800b",
    x"80028003",
    x"80028001",
    x"80078003",
    x"8010800b",
    x"801f8017",
    x"80338028",
    x"804c803f",
    x"8069805a",
    x"808c807a",
    x"80b3809f",
    x"80df80c9",
    x"811180f7",
    x"8147812b",
    x"81828164",
    x"81c281a1",
    x"820681e3",
    x"8250822b",
    x"829e8277",
    x"82f282c7",
    x"834a831d",
    x"83a78378",
    x"840883d7",
    x"846f843b",
    x"84da84a4",
    x"854a8512",
    x"85bf8584",
    x"863885fb",
    x"86b68677",
    x"873986f7",
    x"87c1877c",
    x"884d8806",
    x"88de8895",
    x"89738928",
    x"8a0d89bf",
    x"8aab8a5b",
    x"8b4e8afc",
    x"8bf68ba1",
    x"8ca28c4b",
    x"8d528cf9",
    x"8e078dac",
    x"8ec08e63",
    x"8f7d8f1e",
    x"903f8fde",
    x"910590a2",
    x"91d0916a",
    x"929f9237",
    x"93729308",
    x"944993dd",
    x"952494b6",
    x"96039593",
    x"96e79675",
    x"97ce975a",
    x"98ba9844",
    x"99aa9931",
    x"9a9d9a23",
    x"9b949b18",
    x"9c909c12",
    x"9d8f9d0f",
    x"9e929e10",
    x"9f989f15",
    x"a0a3a01d",
    x"a1b1a129",
    x"a2c2a239",
    x"a3d8a34d",
    x"a4f1a464",
    x"a60da57e",
    x"a72da69c",
    x"a850a7be",
    x"a976a8e3",
    x"aaa0aa0b",
    x"abceab37",
    x"acfeac65",
    x"ae32ad98",
    x"af69aecd",
    x"b0a3b005",
    x"b1e0b141",
    x"b320b27f",
    x"b463b3c1",
    x"b5a8b505",
    x"b6f1b64c",
    x"b83db797",
    x"b98bb8e4",
    x"badcba33",
    x"bc30bb86",
    x"bd86bcdb",
    x"bedfbe32",
    x"c03bbf8d",
    x"c198c0e9",
    x"c2f9c248",
    x"c45bc3aa",
    x"c5c0c50e",
    x"c727c674",
    x"c891c7dc",
    x"c9fcc946",
    x"cb6acab3",
    x"ccdacc21",
    x"ce4bcd92",
    x"cfbfcf05",
    x"d134d079",
    x"d2abd1ef",
    x"d424d367",
    x"d59fd4e1",
    x"d71bd65d",
    x"d899d7da",
    x"da18d958",
    x"db99dad8",
    x"dd1bdc5a",
    x"de9fdddd",
    x"e023df61",
    x"e1a9e0e6",
    x"e331e26d",
    x"e4b9e3f5",
    x"e642e57e",
    x"e7cde707",
    x"e958e892",
    x"eae4ea1e",
    x"ec71ebab",
    x"edffed38",
    x"ef8eeec6",
    x"f11df055",
    x"f2acf1e4",
    x"f43cf374",
    x"f5cdf505",
    x"f75ef696",
    x"f8eff827",
    x"fa81f9b8",
    x"fc13fb4a",
    x"fda5fcdc",
    x"ff37fe6e",
    x"d820000b",
    x"ec780000",
    x"0c630008",
    x"546301f4",
    x"e88003e8",
    x"00630845",
    x"8c430001",
    x"54427fff",
    x"c45fffff",
    x"54217fff",
    x"c43ffffc",
    x"e3c00000",
    x"1c5f007c",
    x"ec780000",
    x"1c630040",
    x"e8a00008",
    x"4881000f",
    x"8c210004",
    x"00820805",
    x"2c830000",
    x"54630004",
    x"54a57fff",
    x"c0a00004",
    x"c43ffff9",
    x"e8800000",
    x"c03ffffa",
    x"e3c00000",
    x"1c5f0040",
    x"ec780000",
    x"1c630040",
    x"e8c0000a",
    x"e8a00008",
    x"00810c47",
    x"00210c45",
    x"00820805",
    x"2c830000",
    x"54630004",
    x"54a57fff",
    x"c0a00004",
    x"c43ffff9",
    x"e8800000",
    x"c03ffffa",
    x"e3c00000",
    x"4f5b063f",
    x"077d6d66",
    x"7c776f7f",
    x"71795e39",
    x"00001010",
    x"676f7270",
    x"006d6172",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000"
  );

  signal s_is_valid_wb_request : std_logic;
begin
  -- Wishbone control logic.
  s_is_valid_wb_request <= i_wb_cyc and i_wb_stb;

  -- We always ack and never stall - we're that fast ;-)
  process(i_clk)
  begin
    if rising_edge(i_clk) then
      o_wb_dat <= C_ROM_ARRAY(to_integer(unsigned(i_wb_adr(C_ADDR_BITS+1 downto 2))));
      o_wb_ack <= s_is_valid_wb_request;
    end if;
  end process;
  o_wb_stall <= '0';
end rtl;
