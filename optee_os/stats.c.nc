#include <compiler.h>
#include <stdio.h>
#include <trace.h>
#include <kernel/pseudo_ta.h>
#include <mm/tee_pager.h>
#include <mm/tee_mm.h>
#include <string.h>
#include <string_ext.h>
#include <malloc.h>
#define TA_NAME		"stats.ta"
#define STATS_UUID \
		{ 0xd96a5b40, 0xe2c7, 0xb1af, \
			{ 0x87, 0x94, 0x10, 0x02, 0xa5, 0xd5, 0xc6, 0x1b } }
#define STATS_CMD_PAGER_STATS		0
#define STATS_CMD_ALLOC_STATS		1
#define STATS_NB_POOLS			3
static TEE_Result get_alloc_stats(uint32_t type, TEE_Param p[TEE_NUM_PARAMS])
{
	struct malloc_stats *stats;
	uint32_t size_to_retrieve;
	uint32_t pool_id;
	uint32_t i;
	if (TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INPUT,
			    TEE_PARAM_TYPE_MEMREF_OUTPUT,
			    TEE_PARAM_TYPE_NONE,
			    TEE_PARAM_TYPE_NONE) != type) {
		return TEE_ERROR_BAD_PARAMETERS;
	}
	pool_id = p[0].value.a;
	if (pool_id > STATS_NB_POOLS)
		return TEE_ERROR_BAD_PARAMETERS;
	size_to_retrieve = sizeof(struct malloc_stats);
	if (!pool_id)
		size_to_retrieve *= STATS_NB_POOLS;
	if (p[1].memref.size < size_to_retrieve) {
		p[1].memref.size = size_to_retrieve;
		return TEE_ERROR_SHORT_BUFFER;
	}
	p[1].memref.size = size_to_retrieve;
	stats = p[1].memref.buffer;
	for (i = 1; i <= STATS_NB_POOLS; i++) {
		if ((pool_id) && (i != pool_id))
			continue;
		switch (i) {
		case 1:
			malloc_get_stats(stats);
			strlcpy(stats->desc, "Heap", sizeof(stats->desc));
			if (p[0].value.b)
				malloc_reset_stats();
			break;
		case 2:
			EMSG("public DDR not managed by secure side anymore");
			break;
		case 3:
			tee_mm_get_pool_stats(&tee_mm_sec_ddr, stats,
					      !!p[0].value.b);
			strlcpy(stats->desc, "Secure DDR", sizeof(stats->desc));
			break;
		default:
			EMSG("Wrong pool id");
			break;
		}
		stats++;
	}
	return TEE_SUCCESS;
}
static TEE_Result get_pager_stats(uint32_t type, TEE_Param p[TEE_NUM_PARAMS])
{
	struct tee_pager_stats stats;
	if (TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_OUTPUT,
			    TEE_PARAM_TYPE_VALUE_OUTPUT,
			    TEE_PARAM_TYPE_VALUE_OUTPUT,
			    TEE_PARAM_TYPE_NONE) != type) {
		EMSG("expect 3 output values as argument");
		return TEE_ERROR_BAD_PARAMETERS;
	}
	tee_pager_get_stats(&stats);
	p[0].value.a = stats.npages;
	p[0].value.b = stats.npages_all;
	p[1].value.a = stats.ro_hits;
	p[1].value.b = stats.rw_hits;
	p[2].value.a = stats.hidden_hits;
	p[2].value.b = stats.zi_released;
	return TEE_SUCCESS;
}
static TEE_Result invoke_command(void *psess __unused,
				 uint32_t cmd, uint32_t ptypes,
				 TEE_Param params[TEE_NUM_PARAMS])
{
	switch (cmd) {
	case STATS_CMD_PAGER_STATS:
		return get_pager_stats(ptypes, params);
	case STATS_CMD_ALLOC_STATS:
		return get_alloc_stats(ptypes, params);
	default:
		break;
	}
	return TEE_ERROR_BAD_PARAMETERS;
}
pseudo_ta_register(.uuid = STATS_UUID, .name = TA_NAME,
		   .flags = PTA_DEFAULT_FLAGS,
		   .invoke_command_entry_point = invoke_command);
