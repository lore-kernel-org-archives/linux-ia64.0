From: Jes Sorensen <jes@trained-monkey.org>
Date: Wed, 14 Jan 2004 14:36:43 +0000
Subject: [patch] quiet down SMP boot messages
Message-Id: <16389.21499.530675.399501@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[sent it to the wrong list first - trying again and spelling David's
name properly - my apologies]

Hi David,

I proposed a patch for this some months ago while 2.5 was in freeze
mode. Since Linus and Andrew are now taking patches again, I would like
to propose this one again for 2.6.x.

Basically I'd love to get rid of some of the excessive printks we are
getting for each CPU spinning up (I'll post a seperate patch to
linux-kernel for non ia64 specific printks).

Comments?

Thanks,
Jes


diff -urN -X /usr/people/jes/exclude-linux orig/linux-2.6.1-mm3-boot/arch/ia64/kernel/setup.c linux-2.6.1-mm3/arch/ia64/kernel/setup.c
--- orig/linux-2.6.1-mm3-boot/arch/ia64/kernel/setup.c	Wed Jan 14 02:59:48 2004
+++ linux-2.6.1-mm3/arch/ia64/kernel/setup.c	Wed Jan 14 05:23:51 2004
@@ -516,8 +516,6 @@
 		impl_va_msb = vm2.pal_vm_info_2_s.impl_va_msb;
 		phys_addr_size = vm1.pal_vm_info_1_s.phys_add_size;
 	}
-	printk(KERN_INFO "CPU %d: %lu virtual and %lu physical address bits\n",
-	       smp_processor_id(), impl_va_msb + 1, phys_addr_size);
 	c->unimpl_va_mask = ~((7L<<61) | ((1L << (impl_va_msb + 1)) - 1));
 	c->unimpl_pa_mask = ~((1L<<63) | ((1L << phys_addr_size) - 1));
 }
diff -urN -X /usr/people/jes/exclude-linux orig/linux-2.6.1-mm3-boot/arch/ia64/kernel/smpboot.c linux-2.6.1-mm3/arch/ia64/kernel/smpboot.c
--- orig/linux-2.6.1-mm3-boot/arch/ia64/kernel/smpboot.c	Sun Jan 11 07:00:35 2004
+++ linux-2.6.1-mm3/arch/ia64/kernel/smpboot.c	Wed Jan 14 05:24:55 2004
@@ -401,10 +401,7 @@
 	}
 	Dprintk("\n");
 
-	if (cpu_isset(cpu, cpu_callin_map)) {
-		/* number CPUs logically, starting from 1 (BSP is 0) */
-		printk(KERN_INFO "CPU%d: CPU has booted.\n", cpu);
-	} else {
+	if (!cpu_isset(cpu, cpu_callin_map)) {
 		printk(KERN_ERR "Processor 0x%x/0x%x is stuck.\n", cpu, sapicid);
 		ia64_cpu_to_sapicid[cpu] = -1;
 		cpu_clear(cpu, cpu_online_map);  /* was set in smp_callin() */
@@ -578,14 +575,11 @@
 	if (sapicid = -1)
 		return -EINVAL;
 
-	printk(KERN_INFO "Processor %d/%d is spinning up...\n", sapicid, cpu);
-
 	/* Processor goes to start_secondary(), sets online flag */
 	ret = do_boot_cpu(sapicid, cpu);
 	if (ret < 0)
 		return ret;
 
-	printk(KERN_INFO "Processor %d has spun up...\n", cpu);
 	return 0;
 }
 
diff -urN -X /usr/people/jes/exclude-linux orig/linux-2.6.1-mm3-boot/arch/ia64/sn/kernel/setup.c linux-2.6.1-mm3/arch/ia64/sn/kernel/setup.c
--- orig/linux-2.6.1-mm3-boot/arch/ia64/sn/kernel/setup.c	Wed Jan 14 02:59:48 2004
+++ linux-2.6.1-mm3/arch/ia64/sn/kernel/setup.c	Wed Jan 14 05:25:24 2004
@@ -386,9 +386,6 @@
 	cnode = nasid_to_cnodeid(nasid);
 	slice = cpu_physical_id_to_slice(cpuphyid);
 
-	printk("CPU %d: nasid %d, slice %d, cnode %d\n",
-			smp_processor_id(), nasid, slice, cnode);
-
 	memset(pda, 0, sizeof(pda));
 	pda->p_nodepda = nodepdaindr[cnode];
 	pda->led_address = (typeof(pda->led_address)) (LED0 + (slice<<LED_CPU_SHIFT));

