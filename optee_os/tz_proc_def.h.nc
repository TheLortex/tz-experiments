#define CP15_CONFIG_CPU_ID_MASK   0x00000003
#define CPU_ID0    0x00000000
#define CPU_ID1    0x00000001
#define CP15_CONFIG_NS_MASK   0x00000001
#define CP15_CONFIG_IRQ_MASK  0x00000002
#define CP15_CONFIG_FIQ_MASK  0x00000004
#define CP15_CONFIG_EA_MASK   0x00000008
#define CP15_CONFIG_FW_MASK   0x00000010
#define CP15_CONFIG_AW_MASK   0x00000020
#define CP15_CONFIG_nET_MASK  0x00000040
#define CP15_CONTROL_M_MASK          0x00000001
#define CP15_CONTROL_C_MASK          0x00000004
#define CP15_CONTROL_Z_MASK          0x00000800
#define CP15_CONTROL_I_MASK          0x00001000
#define CP15_CONTROL_V_MASK          0x00002000
#define CP15_CONTROL_HA_MASK         0x00020000
#define CP15_CONTROL_EE_MASK         0x02000000
#define CP15_CONTROL_NMFI_MASK       0x08000000
#define CP15_CONTROL_TRE_MASK        0x10000000
#define CP15_CONTROL_AFE_MASK        0x20000000
#define CP15_CONTROL_TE_MASK         0x40000000
#define CP15_CONTROL_SMP_MASK        0x00000040
#define CP15_CONTROL_EXCL_MASK       0x00000080
#define CP15_NSAC_TL_MASK        0x10000
#define CP15_NSAC_CL_MASK        0x20000
#define CP15_NSAC_CPN_MASK       0x3FFF
#define CP15_CACHE_ADDR_R_BIT    12
#define CP15_CACHE_ADDR_L_BIT    (32-CP15_CACHE_ADDR_R_BIT)
#define CP15_CACHE_RESULT_MASK   0x00000001
#define CP15_TCM_ENABLE_MASK     0x00000001
#define CP15_TCM_INSTR_TCM       0x2010000C
#define CP15_TCM_DATA_TCM        0x2010100C
#define CP15_CACHE_LOCK_ALLWAYS_MASK     0x0000000F
#define LINE_FIELD_OFFSET        5
#define LINE_FIELD_OVERFLOW      13
#define WAY_FIELD_OFFSET         30
