-- VHDL Entity HAVOC.FPmul.symbol
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE work.mypackage.all;

ENTITY FPmbe IS
   PORT( 
      FP_A : IN     std_logic_vector (nb-1 DOWNTO 0);
      FP_B : IN     std_logic_vector (nb-1 DOWNTO 0);
      RST_n: IN	    std_logic;
      clk  : IN     std_logic;
      FP_Z : OUT    std_logic_vector (nb-1 DOWNTO 0)
   );

-- Declarations

END FPmbe ;

ARCHITECTURE pipeline OF FPmbe IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL FP_A_s	  : std_logic_vector(nb-1 DOWNTO 0);
   SIGNAL FP_B_s	  : std_logic_vector(nb-1 DOWNTO 0);
   SIGNAL A_EXP           : std_logic_vector(nb_exp-1 DOWNTO 0);
   SIGNAL A_SIG           : std_logic_vector(nb-1 DOWNTO 0);
   SIGNAL B_EXP           : std_logic_vector(nb_exp-1 DOWNTO 0);
   SIGNAL B_SIG           : std_logic_vector(nb-1 DOWNTO 0);
   SIGNAL EXP_in          : std_logic_vector(nb_exp-1 DOWNTO 0);
   SIGNAL EXP_neg         : std_logic;
   SIGNAL EXP_neg_stage2  : std_logic;
   SIGNAL EXP_out_round   : std_logic_vector(nb_exp-1 DOWNTO 0);
   SIGNAL EXP_pos         : std_logic;
   SIGNAL EXP_pos_stage2  : std_logic;
   SIGNAL SIGN_out        : std_logic;
   SIGNAL SIGN_out_stage1 : std_logic;
   SIGNAL SIGN_out_stage2 : std_logic;
   SIGNAL SIG_in          : std_logic_vector(nb_SIG-1 DOWNTO 0);
   SIGNAL SIG_out_round   : std_logic_vector(nb_SIG-1 DOWNTO 0);
   SIGNAL isINF_stage1    : std_logic;
   SIGNAL isINF_stage2    : std_logic;
   SIGNAL isINF_tab       : std_logic;
   SIGNAL isNaN           : std_logic;
   SIGNAL isNaN_stage1    : std_logic;
   SIGNAL isNaN_stage2    : std_logic;
   SIGNAL isZ_tab         : std_logic;
   SIGNAL isZ_tab_stage1  : std_logic;
   SIGNAL isZ_tab_stage2  : std_logic;

 
   SIGNAL EXP_in_s          : std_logic_vector (nb_exp-1 DOWNTO 0);
   SIGNAL EXP_neg_stage2_s  : std_logic ;
   SIGNAL EXP_pos_stage2_s  : std_logic ;
   SIGNAL SIGN_out_stage2_s : std_logic ;
   SIGNAL SIG_in_s          : std_logic_vector (nb_SIG-1 DOWNTO 0);
   SIGNAL isINF_stage2_s    : std_logic ;
   SIGNAL isNaN_stage2_s    : std_logic ;
   SIGNAL isZ_tab_stage2_s  : std_logic ;

   -- Component Declarations
   COMPONENT reg
   GENERIC (N: POSITIVE := 8);
   PORT (
      CLK:	IN STD_LOGIC;
      RST_n:	IN STD_LOGIC;
      EN:	IN STD_LOGIC;
      D_IN:	IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
      D_OUT:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
   END COMPONENT;

   COMPONENT FPmul_stage1
   PORT (
      FP_A            : IN     std_logic_vector (31 DOWNTO 0);
      FP_B            : IN     std_logic_vector (31 DOWNTO 0);
      clk             : IN     std_logic ;
      A_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      B_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      B_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : OUT    std_logic ;
      isINF_stage1    : OUT    std_logic ;
      isNaN_stage1    : OUT    std_logic ;
      isZ_tab_stage1  : OUT    std_logic 
   );
   END COMPONENT;

   COMPONENT FPmul_stage2_mbe
   PORT (
      A_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      A_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      B_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      B_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : IN     std_logic ;
      clk             : IN     std_logic ;
      isINF_stage1    : IN     std_logic ;
      isNaN_stage1    : IN     std_logic ;
      isZ_tab_stage1  : IN     std_logic ;
      EXP_in          : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : OUT    std_logic ;
      EXP_pos_stage2  : OUT    std_logic ;
      SIGN_out_stage2 : OUT    std_logic ;
      SIG_in          : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_stage2    : OUT    std_logic ;
      isNaN_stage2    : OUT    std_logic ;
      isZ_tab_stage2  : OUT    std_logic 
   );
   END COMPONENT;

   COMPONENT FPmul_stage3
   PORT (
      EXP_in          : IN     std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : IN     std_logic ;
      EXP_pos_stage2  : IN     std_logic ;
      SIGN_out_stage2 : IN     std_logic ;
      SIG_in          : IN     std_logic_vector (27 DOWNTO 0);
      clk             : IN     std_logic ;
      isINF_stage2    : IN     std_logic ;
      isNaN_stage2    : IN     std_logic ;
      isZ_tab_stage2  : IN     std_logic ;
      EXP_neg         : OUT    std_logic ;
      EXP_out_round   : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_pos         : OUT    std_logic ;
      SIGN_out        : OUT    std_logic ;
      SIG_out_round   : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_tab       : OUT    std_logic ;
      isNaN           : OUT    std_logic ;
      isZ_tab         : OUT    std_logic 
   );
   END COMPONENT;

   COMPONENT FPmul_stage4
   PORT (
      EXP_neg       : IN     std_logic ;
      EXP_out_round : IN     std_logic_vector (7 DOWNTO 0);
      EXP_pos       : IN     std_logic ;
      SIGN_out      : IN     std_logic ;
      SIG_out_round : IN     std_logic_vector (27 DOWNTO 0);
      clk           : IN     std_logic ;
      isINF_tab     : IN     std_logic ;
      isNaN         : IN     std_logic ;
      isZ_tab       : IN     std_logic ;
      FP_Z          : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPmul_stage1     USE ENTITY work.FPmul_stage1;
   FOR ALL : FPmul_stage2_mbe USE ENTITY work.FPmul_stage2_mbe;
   FOR ALL : FPmul_stage3     USE ENTITY work.FPmul_stage3;
   FOR ALL : FPmul_stage4 USE ENTITY work.FPmul_stage4;
   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.

   -- Input registers
   RA : reg
      GENERIC MAP (N => nb)
      PORT MAP (
         CLK		 => clk,
	 RST_n		 => RST_n,
	 EN		 => '1',
	 D_IN		 => FP_A,
	 D_OUT		 => FP_A_s
      );

   RB : reg
      GENERIC MAP (N => nb)
      PORT MAP (
         CLK		 => clk,
	 RST_n		 => RST_n,
	 EN		 => '1',
	 D_IN		 => FP_B,
	 D_OUT		 => FP_B_s
      );

   I1 : FPmul_stage1
      PORT MAP (
         FP_A            => FP_A_s,
         FP_B            => FP_B_s,
         clk             => clk,
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1
      );

   -- Stage 2 with MBE multiplier
   I2 : FPmul_stage2_mbe
      PORT MAP (
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         clk             => clk,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1,
         EXP_in          => EXP_in,
         EXP_neg_stage2  => EXP_neg_stage2,
         EXP_pos_stage2  => EXP_pos_stage2,
         SIGN_out_stage2 => SIGN_out_stage2,
         SIG_in          => SIG_in,
         isINF_stage2    => isINF_stage2,
         isNaN_stage2    => isNaN_stage2,
         isZ_tab_stage2  => isZ_tab_stage2
      );

   -- Pipeline registers between stage2 and stage3
   R_EXP_in : reg
      GENERIC MAP (N => nb_exp)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN            => EXP_in,
         D_OUT           => EXP_in_s
      );

   R_EXP_neg_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => EXP_neg_stage2,
         D_OUT(0)        => EXP_neg_stage2_s
      );

   R_EXP_pos_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => EXP_pos_stage2,
         D_OUT(0)        => EXP_pos_stage2_s
      );

   R_SIGN_out_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => SIGN_out_stage2,
         D_OUT(0)        => SIGN_out_stage2_s
      );

   R_SIG_in : reg
      GENERIC MAP (N => nb_SIG)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN            => SIG_in,
         D_OUT           => SIG_in_s
      );

   R_isINF_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => isINF_stage2,
         D_OUT(0)        => isINF_stage2_s
      );

   R_isNaN_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => isNaN_stage2,
         D_OUT(0)        => isNaN_stage2_s
      );

   R_isZ_tab_stage2 : reg
      GENERIC MAP (N => 1)
      PORT MAP (
         CLK             => clk,
         RST_n           => RST_n,
         EN              => '1',
         D_IN(0)         => isZ_tab_stage2,
         D_OUT(0)        => isZ_tab_stage2_s
      );

   I3 : FPmul_stage3
      PORT MAP (
         EXP_in          => EXP_in_s,
         EXP_neg_stage2  => EXP_neg_stage2_s,
         EXP_pos_stage2  => EXP_pos_stage2_s,
         SIGN_out_stage2 => SIGN_out_stage2_s,
         SIG_in          => SIG_in_s,
         clk             => clk,
         isINF_stage2    => isINF_stage2_s,
         isNaN_stage2    => isNaN_stage2_s,
         isZ_tab_stage2  => isZ_tab_stage2_s,
         EXP_neg         => EXP_neg,
         EXP_out_round   => EXP_out_round,
         EXP_pos         => EXP_pos,
         SIGN_out        => SIGN_out,
         SIG_out_round   => SIG_out_round,
         isINF_tab       => isINF_tab,
         isNaN           => isNaN,
         isZ_tab         => isZ_tab
      );

   I4 : FPmul_stage4
      PORT MAP (
         EXP_neg       => EXP_neg,
         EXP_out_round => EXP_out_round,
         EXP_pos       => EXP_pos,
         SIGN_out      => SIGN_out,
         SIG_out_round => SIG_out_round,
         clk           => clk,
         isINF_tab     => isINF_tab,
         isNaN         => isNaN,
         isZ_tab       => isZ_tab,
         FP_Z          => FP_Z
      );

END pipeline;
