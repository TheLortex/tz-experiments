#include <assert.h>
#include <drivers/tzc380.h>
#include <io.h>
#include <kernel/panic.h>
#include <mm/core_memprot.h>
#include <mm/core_mmu.h>
#include <stddef.h>
#include <trace.h>
#include <util.h>
struct tzc_instance {
	vaddr_t base;
	uint8_t addr_width;
	uint8_t num_regions;
};
static struct tzc_instance tzc;
static uint32_t tzc_read_build_config(vaddr_t base)
{
	return read32(base + BUILD_CONFIG_OFF);
}
static void tzc_write_action(vaddr_t base, enum tzc_action action)
{
	write32(action, base + ACTION_OFF);
}
static void tzc_write_region_base_low(vaddr_t base, uint32_t region,
				      uint32_t val)
{
	write32(val, base + REGION_SETUP_LOW_OFF(region));
}
static void tzc_write_region_base_high(vaddr_t base, uint32_t region,
				       uint32_t val)
{
	write32(val, base + REGION_SETUP_HIGH_OFF(region));
}
static uint32_t tzc_read_region_attributes(vaddr_t base, uint32_t region)
{
	return read32(base + REGION_ATTRIBUTES_OFF(region));
}
static void tzc_write_region_attributes(vaddr_t base, uint32_t region,
					uint32_t val)
{
	write32(val, base + REGION_ATTRIBUTES_OFF(region));
}
void tzc_init(vaddr_t base)
{
	uint32_t tzc_build;
	assert(base);
	tzc.base = base;
	tzc_build = tzc_read_build_config(tzc.base);
	tzc.addr_width  = ((tzc_build >> BUILD_CONFIG_AW_SHIFT) &
			   BUILD_CONFIG_AW_MASK) + 1;
	tzc.num_regions = ((tzc_build >> BUILD_CONFIG_NR_SHIFT) &
			   BUILD_CONFIG_NR_MASK) + 1;
}
void tzc_security_inversion_en(vaddr_t base)
{
	write32(1, base + SECURITY_INV_EN_OFF);
}
void tzc_region_enable(uint8_t region)
{
	uint32_t val;
	val = tzc_read_region_attributes(tzc.base, region);
	val |= TZC_ATTR_REGION_EN_MASK;
	tzc_write_region_attributes(tzc.base, region, val);
}
void tzc_fail_dump(void)
{
	vaddr_t base __maybe_unused = core_mmu_get_va(tzc.base,
						      MEM_AREA_IO_SEC);
	EMSG("Fail address Low 0x%" PRIx32,
	     read32(base + FAIL_ADDRESS_LOW_OFF));
	EMSG("Fail address High 0x%" PRIx32,
	     read32(base + FAIL_ADDRESS_HIGH_OFF));
	EMSG("Fail Control 0x%" PRIx32, read32(base + FAIL_CONTROL_OFF));
	EMSG("Fail Id 0x%" PRIx32, read32(base + FAIL_ID));
}
void tzc_int_clear(void)
{
	vaddr_t base = core_mmu_get_va(tzc.base, MEM_AREA_IO_SEC);
	write32(0, base + INT_CLEAR);
}
static uint32_t addr_low(vaddr_t addr)
{
	return (uint32_t)addr;
}
static uint32_t addr_high(vaddr_t addr __maybe_unused)
{
#if (UINTPTR_MAX == UINT64_MAX)
	return addr >> 32;
#else
	return 0;
#endif
}
void tzc_configure_region(uint8_t region, vaddr_t region_base, uint32_t attr)
{
	assert(tzc.base);
	assert(region < tzc.num_regions);
	if (region) {
		tzc_write_region_base_low(tzc.base, region,
					  addr_low(region_base));
		tzc_write_region_base_high(tzc.base, region,
					   addr_high(region_base));
		tzc_write_region_attributes(tzc.base, region, attr);
	} else {
		tzc_write_region_attributes(tzc.base, region,
					    attr & TZC_ATTR_SP_MASK);
	}
}
void tzc_set_action(enum tzc_action action)
{
	assert(tzc.base);
	tzc_write_action(tzc.base, action);
}
#if TRACE_LEVEL >= TRACE_DEBUG
static uint32_t tzc_read_region_base_low(vaddr_t base, uint32_t region)
{
	return read32(base + REGION_SETUP_LOW_OFF(region));
}
static uint32_t tzc_read_region_base_high(vaddr_t base, uint32_t region)
{
	return read32(base + REGION_SETUP_HIGH_OFF(region));
}
#define	REGION_MAX	16
void tzc_dump_state(void)
{
	uint32_t n;
	uint32_t temp_32reg, temp_32reg_h;
	DMSG("enter");
	DMSG("security_inversion_en %x\n",
	     read32(tzc.base + SECURITY_INV_EN_OFF));
	for (n = 0; n <= REGION_MAX; n++) {
		temp_32reg = tzc_read_region_attributes(tzc.base, n);
		if (!(temp_32reg & TZC_ATTR_REGION_EN_MASK))
			continue;
		DMSG("\n");
		DMSG("region %d", n);
		temp_32reg = tzc_read_region_base_low(tzc.base, n);
		temp_32reg_h = tzc_read_region_base_high(tzc.base, n);
		DMSG("region_base: 0x%08x%08x", temp_32reg_h, temp_32reg);
		temp_32reg = tzc_read_region_attributes(tzc.base, n);
		DMSG("region sp: %x", temp_32reg >> TZC_ATTR_SP_SHIFT);
		DMSG("region size: %x\n", (temp_32reg & TZC_REGION_SIZE_MASK) >>
				TZC_REGION_SIZE_SHIFT);
	}
	DMSG("exit");
}
#endif 
