From: john stultz <johnstul@us.ibm.com>
Date: Tue, 18 Nov 2003 01:01:54 +0000
Subject: [RFC][PATCH] linux-2.4.23-pre9_ia64-cyclone_A0
Message-Id: <marc-linux-ia64-106911773604958@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Resent to the proper mailing list.]

Hi all, 
	This patch was developed for the distros to support the cyclone time
source on IBM x455 systems. x455 systems are multi-node NUMA systems
which suffer from unsynced ITCs, which can cause non-monotonically
increasing results from gettimeofday(). Very similar code was
implemented in the i386 arch to resolve the same issue on x440s.

This patch is against the ia64 bk (~2.4.23-pre9) tree. I don't have a
2.5 version ready yet, but I'm currently working to port this code to
the to use the struct time_interpolator interface. So a 2.5 patch should
follow soon.

Any comments or feedback would be appreciated. 

thanks
-john


diff -Nru a/arch/ia64/config.in b/arch/ia64/config.in
--- a/arch/ia64/config.in	Fri Nov 14 16:32:59 2003
+++ b/arch/ia64/config.in	Fri Nov 14 16:32:59 2003
@@ -119,6 +119,8 @@
 tristate '/proc/pal support' CONFIG_IA64_PALINFO
 tristate '/proc/efi/vars support' CONFIG_EFI_VARS
 
+bool 'Support Cyclone(EXA) Clock' CONFIG_IA64_CYCLONE
+
 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
 bool 'BSD Process Accounting' CONFIG_BSD_PROCESS_ACCT
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Fri Nov 14 16:32:59 2003
+++ b/arch/ia64/kernel/Makefile	Fri Nov 14 16:32:59 2003
@@ -26,5 +26,6 @@
 obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
+obj-$(CONFIG_IA64_CYCLONE) += cyclone.o
 
 include $(TOPDIR)/Rules.make
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Fri Nov 14 16:32:59 2003
+++ b/arch/ia64/kernel/acpi.c	Fri Nov 14 16:32:59 2003
@@ -49,6 +49,7 @@
 #include <asm/page.h>
 #include <asm/system.h>
 #include <asm/numa.h>
+#include <asm/cyclone.h>
 

 #define PREFIX			"ACPI: "
@@ -201,6 +202,16 @@
 	return AE_OK;
 }
 
+/* Hook from generic ACPI tables.c */
+void __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+{
+	if (!strncmp(oem_id, "IBM", 3) &&
+	    (!strncmp(oem_table_id, "SERMOW", 6))){
+		/*Start cyclone clock*/
+		cyclone_setup(0);
+	}
+}
+
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI_BOOT
@@ -430,6 +441,10 @@
 		ipi_base_addr = (unsigned long) ioremap(acpi_madt->lapic_address, 0);
 
 	printk(KERN_INFO PREFIX "Local APIC address 0x%lx\n", ipi_base_addr);
+
+	acpi_madt_oem_check(acpi_madt->header.oem_id, 
+		acpi_madt->header.oem_table_id);
+
 	return 0;
 }
 
diff -Nru a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/cyclone.c	Fri Nov 14 16:32:59 2003
@@ -0,0 +1,115 @@
+#include <linux/smp.h>
+
+/* IBM Summit (EXA) Cyclone counter code*/
+#define CYCLONE_CBAR_ADDR 0xFEB00CD0
+#define CYCLONE_PMCC_OFFSET 0x51A0
+#define CYCLONE_MPMC_OFFSET 0x51D0
+#define CYCLONE_MPCS_OFFSET 0x51A8
+#define CYCLONE_TIMER_FREQ 100000000
+
+int use_cyclone;
+int __init cyclone_setup(char *str) 
+{
+	use_cyclone = 1;
+	return 1;
+}
+
+static u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
+static u32 last_tick_cyclone;
+
+unsigned long do_gettimeoffset_cyclone(void)
+{
+	u32 offset;
+
+	/* Read the cyclone timer */
+	offset = cyclone_timer[0];
+	/* .. relative to previous jiffy */
+	offset = offset - last_tick_cyclone;
+
+	/* convert cyclone ticks to microseconds */	
+	offset = offset/(CYCLONE_TIMER_FREQ/1000000);
+
+	/* our adjusted time offset in microseconds */
+	return (unsigned long)offset;
+}
+
+void mark_timeoffset_cyclone(void)
+{
+	/* inc one tick */
+	last_tick_cyclone += CYCLONE_TIMER_FREQ/HZ;
+}
+
+
+void __init init_cyclone_clock(void)
+{
+	u64* reg;	
+	u64 base;		/* saved cyclone base address */
+	u64 offset;		/* offset from pageaddr to cyclone_timer register */
+	int i;
+	
+	printk(KERN_INFO "Summit chipset: Starting Cyclone Counter.\n");
+
+	/* find base address */
+	offset = (CYCLONE_CBAR_ADDR);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR register.\n");
+		use_cyclone = 0;
+		return;
+	}
+	base = *reg;	
+	if(!base){
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR value.\n");
+		use_cyclone = 0;
+		return;
+	}
+	iounmap(reg);
+		
+	/* setup PMCC */
+	offset = (base + CYCLONE_PMCC_OFFSET);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid PMCC register.\n");
+		use_cyclone = 0;
+		return;
+	}
+	reg[0] = 0x00000001;
+	iounmap(reg);
+	
+	/* setup MPCS */
+	offset = (base + CYCLONE_MPCS_OFFSET);
+	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
+	if(!reg){
+		printk(KERN_ERR "Summit chipset: Could not find valid MPCS register.\n");
+		use_cyclone = 0;
+		return;
+	}
+	reg[0] = 0x00000001;
+	iounmap(reg);
+	
+	/* map in cyclone_timer */
+	offset = (base + CYCLONE_MPMC_OFFSET);
+	cyclone_timer = (u32*)ioremap_nocache(offset, sizeof(u32));
+	if(!cyclone_timer){
+		printk(KERN_ERR "Summit chipset: Could not find valid MPMC register.\n");
+		use_cyclone = 0;
+		return;
+	}
+
+	/*quick test to make sure its ticking*/
+	for(i=0; i<3; i++){
+		u32 old = cyclone_timer[0];
+		int stall = 100;
+		while(stall--) barrier();
+		if(cyclone_timer[0] = old){
+			printk(KERN_ERR "Summit chipset: Counter not counting! DISABLED\n");
+			iounmap(cyclone_timer);
+			cyclone_timer = 0;
+			use_cyclone = 0;
+			return;
+		}
+	}
+	/* initialize last tick */
+	last_tick_cyclone = cyclone_timer[0];
+}
+
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Fri Nov 14 16:32:59 2003
+++ b/arch/ia64/kernel/time.c	Fri Nov 14 16:32:59 2003
@@ -22,6 +22,7 @@
 #include <asm/ptrace.h>
 #include <asm/sal.h>
 #include <asm/system.h>
+#include <asm/cyclone.h>
 
 extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
@@ -68,6 +69,9 @@
 	unsigned long now, last_tick;
 #	define time_keeper_id	0	/* smp_processor_id() of time-keeper */
 
+	if(use_cyclone)
+		return do_gettimeoffset_cyclone() + lost * (1000000 / HZ);
+
 	last_tick = (cpu_data(time_keeper_id)->itm_next
 		     - (lost + 1)*cpu_data(time_keeper_id)->itm_delta);
 
@@ -178,6 +182,8 @@
 			write_lock(&xtime_lock);
 			do_timer(regs);
 			local_cpu_data->itm_next = new_itm;
+			if(use_cyclone)
+				mark_timeoffset_cyclone();
 			write_unlock(&xtime_lock);
 		} else
 			local_cpu_data->itm_next = new_itm;
@@ -293,4 +299,6 @@
 	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
 	efi_gettimeofday((struct timeval *) &xtime);
 	ia64_init_itm();
+	if(use_cyclone)
+		init_cyclone_clock();
 }
diff -Nru a/include/asm-ia64/cyclone.h b/include/asm-ia64/cyclone.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-ia64/cyclone.h	Fri Nov 14 16:32:59 2003
@@ -0,0 +1,22 @@
+#ifndef ASM_IA64_CYCLONE_H
+#define ASM_IA64_CYCLONE_H
+
+#ifdef	CONFIG_IA64_CYCLONE
+extern int use_cyclone;
+extern int __init cyclone_setup(char*);
+extern unsigned long do_gettimeoffset_cyclone(void);
+extern void mark_timeoffset_cyclone(void);
+extern void __init init_cyclone_clock(void);
+#else	/* CONFIG_IA64_CYCLONE */
+#define use_cyclone 0
+static inline void cyclone_setup(char* s) 
+{
+	printk(KERN_ERR "Cyclone Counter: System not configured"
+					" w/ CONFIG_IA64_CYCLONE.\n");
+}
+static inline unsigned long do_gettimeoffset_cyclone(void){}
+static inline void mark_timeoffset_cyclone(void){}
+static inline void init_cyclone_clock(void){}
+#endif	/* CONFIG_IA64_CYCLONE */
+
+#endif	/* !ASM_IA64_CYCLONE_H */




