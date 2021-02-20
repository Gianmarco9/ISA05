LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE IEEE.std_logic_textio.all;
USE std.textio.all;
USE work.mypackage.all;

ENTITY monitor_abs IS
	PORT(	CLK		        : IN std_logic;						                -- from TB
            RST_n		    : IN std_logic;						                -- from TB

            -- FETCH            
            PC		        : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from INSTRUCTION MEMORY

            -- DECODE
            OPCODE		    : IN std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);		-- from DP
            FUNC3		    : IN std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);		-- from DP
            RD 		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
            RS1 		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
            RS2	    	    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
            IMM		        : IN std_logic_vector(nb-1 DOWNTO 0);			    -- form DP
            FUNC7_30	    : IN std_logic;					                    -- from DP


            -- EXECUTE
            NOP_inject	    : IN std_logic;						                -- from CU
            ALU_FORW_Src1	: IN std_logic_vector(1 DOWNTO 0);	                -- from CU
            ALU_FORW_Src2	: IN std_logic_vector(1 DOWNTO 0);	                -- from CU
	    NEW_ADDR 		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP 
            ALU_RES		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
			ABS_RES		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP


            -- MEMORY
            ADDR_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
            DATA_W_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
            DATA_R_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);               -- from DATA MEMORY


            -- WRITE BACK
            WR		        : IN std_logic;						                -- from CU
            RD_ADDR		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);    -- from DP
            WR_DATA		    : IN std_logic_vector(nb-1 DOWNTO 0)			    -- from DP
	);

END ENTITY;


ARCHITECTURE behav OF monitor_abs IS



begin

  PROCESS (CLK, RST_n)
    FILE res_fp       : text OPEN WRITE_MODE IS "./monitor_abs.txt";
    VARIABLE op       : string(1 TO 5);
    VARIABLE line_out : line;
  BEGIN 

    IF RST_n = '0' THEN                 
        NULL;

    ELSE

    -----------------------------------------------------------------------------------------------------

    --					OPCODE TRANSLATOR

    -----------------------------------------------------------------------------------------------------

        CASE OPCODE IS


        WHEN R_TYPE	=>
            CASE FUNC3 IS
                WHEN FUNC3_ADD	=>
                    CASE FUNC7_30 IS
                        WHEN FUNC7_30_ADD	=>
                            op := "ADD__";
                        WHEN OTHERS		=>	--disable pipe regs
                            op := "NOP__";
                    END CASE;


                WHEN FUNC3_XOR	=>
                    CASE FUNC7_30 IS
                        WHEN FUNC7_30_XOR	=>
                            op := "XOR__";
                        WHEN OTHERS		=>	--disable pipe regs
                            op := "NOP__";										
                    END CASE;


                WHEN FUNC3_SLT	=>
                    CASE FUNC7_30 IS
                        WHEN FUNC7_30_SLT	=>
                            op := "SLT__";
                        WHEN OTHERS		=>	--disable pipe regs
                            op := "NOP__";										
                    END CASE;
                WHEN OTHERS	=>	--disable pipe regs
                    op := "NOP__";										
            END CASE;

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN I_TYPE_ARITH	=>
            CASE FUNC3 IS
                WHEN FUNC3_ADDI	=>
                    op := "ADDI_";


                WHEN FUNC3_SRAI	=>
                    CASE FUNC7_30 IS
                        WHEN FUNC7_30_SRAI	=>
                            op := "SRAI_";
                        WHEN OTHERS		=>	--disable pipe regs
                            op := "NOP__";					
                    END CASE; 


                WHEN FUNC3_ANDI	=>
                    op := "ANDI_";
				
		WHEN FUNC3_ABS	=>
                    op := "ABS__";
					
                WHEN OTHERS	=>	--disable pipe regs
                    op := "NOP__";						
            END CASE;

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN I_TYPE_LOAD	=>
            CASE FUNC3 IS
                WHEN FUNC3_LW	=>
                    op := "LW___";
                WHEN OTHERS	=>	--disable pipe regs
                    op := "NOP__";					
            END CASE;

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN S_TYPE		=>
            CASE FUNC3 IS
                WHEN FUNC3_SW	=>
                    op := "SW___";
                WHEN OTHERS	=>	--disable pipe regs
                    op := "NOP__";						
            END CASE;

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN SB_TYPE		=>
            CASE FUNC3 IS
                WHEN FUNC3_BEQ	=>
                    op := "BEQ__";
                WHEN OTHERS	=>	--disable pipe regs
                    op := "NOP__";						
            END CASE;

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN U_TYPE_LUI		=>
            op := "LUI__";

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN U_TYPE_AUIPC	=>
            op := "AUIPC";

        --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WHEN UJ_TYPE_JAL	=>
            op := "JAL__";


        WHEN OTHERS		=>	--disable pipe regs
            op := "NOP__";						
        END CASE;

	-----------------------------------------------------------------------------------------------------


        IF CLK'EVENT AND CLK = '1' THEN  
            
            -- writing CLK
            write(line_out, string' ("CLOCK"));
            writeline(res_fp, line_out);
            
            -- writing PC
            hwrite(line_out, PC);
            writeline(res_fp, line_out);

            -- writing OP
            write(line_out, op);
            writeline(res_fp, line_out);

            -- writing RD
            write(line_out, conv_integer(unsigned(RD)));
            writeline(res_fp, line_out);

            -- writing RS1
            write(line_out, conv_integer(unsigned(RS1)));
            writeline(res_fp, line_out);

            -- writing RS2
            write(line_out, conv_integer(unsigned(RS2)));
            writeline(res_fp, line_out);

            -- writing IMM
            hwrite(line_out, IMM);
            writeline(res_fp, line_out);

            -- writing NOP_inject
            write(line_out, NOP_inject);
            writeline(res_fp, line_out);

            -- writing ALU_FORW1
            write(line_out, conv_integer(unsigned(ALU_FORW_Src1)));
            writeline(res_fp, line_out);

            -- writing ALU_FORW2
            write(line_out, conv_integer(unsigned(ALU_FORW_Src2)));
            writeline(res_fp, line_out);

            -- writing NEW_ADDR
            hwrite(line_out, NEW_ADDR);
            writeline(res_fp, line_out);

            -- writing ALU_RES
            hwrite(line_out, ALU_RES);
            writeline(res_fp, line_out);
			
	    -- writing ABS_RES
            hwrite(line_out, ABS_RES);
            writeline(res_fp, line_out);

            -- writing ADDR_MEM
            hwrite(line_out, ADDR_MEM);
            writeline(res_fp, line_out);

            -- writing DATA_W_MEM
            hwrite(line_out, DATA_W_MEM);
            writeline(res_fp, line_out);

            -- writing DATA_R_MEM
            hwrite(line_out, DATA_R_MEM);
            writeline(res_fp, line_out);

            -- writing WR
            write(line_out, WR);
            writeline(res_fp, line_out);

            -- writing RD_ADDR
            write(line_out, conv_integer(unsigned(RD_ADDR)));
            writeline(res_fp, line_out);

            -- writing WR_DATA
            hwrite(line_out, WR_DATA);
            writeline(res_fp, line_out);

        END IF;
    END IF;
END PROCESS;

END behav;
