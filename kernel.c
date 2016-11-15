#include "include/stdlib.h"
#include "include/interrupts.h"
#include "include/tty.h"

typedef struct {
	unsigned long long base;
	unsigned long long size;
} BootModuleInfo;

void kernel_main(char boot_disk_id, void *memory_map, BootModuleInfo *boot_module_list) {
	init_interrupts();
	init_tty();
	set_text_attr(0x02);
	clear_screen();
	printf("Welcome to MyOS!\n");
	printf("Boot disk id is %d\n", boot_disk_id);
	printf("Memory map at 0x%x\n", memory_map);
	printf("Boot module list at 0x%x\n", boot_module_list);
	printf("String is %s, char is %c, number is %d, hex number is 0x%x", __DATE__, 'A', 1234, 0x1234);
} 