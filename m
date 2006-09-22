From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 22 Sep 2006 01:07:21 +0000
Subject: [BUGFIX] [PATCH] [IA64] node hotplug : fixup cpu-to-node
Message-Id: <20060922100721.4714a8ed.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@osdl.org>

I tested node hoplug with NUMA machine whcih equips physical node-hotplug.
And found panic (see below). This is bacause node_to_cpu_mask is not update=
d to valid
value. patch is attached.
=3D
Sep 21 14:15:26 drpq kernel:  [<a00000010000c700>] __ia64_leave_kernel+0x0/=
0x280
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
26d80 bsp=E00001401d421618
Sep 21 14:15:26 drpq kernel:  [<a000000100062040>] sd_degenerate+0x80/0xe0
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
26f50 bsp=E00001401d4215e0
Sep 21 14:15:26 drpq kernel:  [<a000000100065710>] cpu_attach_domain+0x90/0=
x1e0
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
26f50 bsp=E00001401d421598
Sep 21 14:15:26 drpq kernel:  [<a00000010006da20>] build_sched_domains+0x14=
e0/0x2360
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
26f50 bsp=E00001401d4214c0
Sep 21 14:15:26 drpq kernel:  [<a00000010006e8f0>] arch_init_sched_domains+=
0x50/0x80
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
27da0 bsp=E00001401d4214a0
Sep 21 14:15:26 drpq kernel:  [<a00000010006e9c0>] update_sched_domains+0xa=
0/0xe0
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421478
Sep 21 14:15:26 drpq kernel:  [<a0000001006201b0>] notifier_call_chain+0x50=
/0xc0
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421440
Sep 21 14:15:26 drpq kernel:  [<a00000010009ede0>] blocking_notifier_call_c=
hain+0x40/0x80
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421408
Sep 21 14:15:26 drpq kernel:  [<a0000001000bccb0>] cpu_up+0x290/0x300
Sep 21 14:15:26 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d4213c8
Sep 21 14:15:27 drpq kernel:  [<a0000001003d2b90>] store_online+0x70/0xe0
Sep 21 14:15:27 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421398
Sep 21 14:15:27 drpq kernel:  [<a0000001003c9e20>] sysdev_store+0x60/0xa0
Sep 21 14:15:27 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421360
Sep 21 14:15:27 drpq kernel:  [<a0000001001edfa0>] sysfs_write_file+0x240/0=
x2e0
Sep 21 14:15:27 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421310
Sep 21 14:15:27 drpq kernel:  [<a000000100156ae0>] vfs_write+0x200/0x3a0
Sep 21 14:15:27 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d4212c0
Sep 21 14:15:27 drpq kernel:  [<a000000100157630>] sys_write+0x70/0xe0
Sep 21 14:15:27 drpq kernel:                                 sp=E00001401d4=
27e20 bsp=E00001401d421248
=3D

-Kame
=3D
When a cpu is not tied to its node at(before) cpu-onlining, the system pani=
cs.
node_to_cpu_mask[] should be set to valid value before notifier of CPU_ONLI=
NE
is called.(if not, the system panics.)

It can happen when a cpu is physically offlined at boot time (ia64).
(*)See arch/ia64/kernel/numa.c. To bind a cpu to a node, we need physical_id
   of a cpu. But smp_build_cpu_map() in smpboot.c will not set physical_id =
of
   *not present* cpus.

This patch updates node_to_cpumask() and cpu_to_nid_map[] just after
onlining and offlining a cpu.

Also fixes pxm_to_nid usage. acpi_map_pxm_to_nid() should be called here.

Tested on a NUMA machine which supports hardware-node-hot-add.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 arch/ia64/kernel/acpi.c    |    5 +++--
 arch/ia64/kernel/smpboot.c |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+), 2 deletions(-)

Index: linux-2.6.18/arch/ia64/kernel/smpboot.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.18.orig/arch/ia64/kernel/smpboot.c	20=
06-09-20 12:42:06.000000000 +0900
+++ linux-2.6.18/arch/ia64/kernel/smpboot.c	2006-09-22 09:33:55.000000000 +=
0900
@@ -59,6 +59,7 @@
 #include <asm/system.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
+#include <asm/topology.h>
=20
 #define SMP_DEBUG 0
=20
@@ -377,6 +378,7 @@
 	int cpuid, phys_id, itc_master;
 	extern void ia64_init_itm(void);
 	extern volatile int time_keeper_id;
+	int nid;
=20
 #ifdef CONFIG_PERFMON
 	extern void pfm_init_percpu(void);
@@ -396,6 +398,17 @@
=20
 	lock_ipi_calllock();
 	cpu_set(cpuid, cpu_online_map);
+#ifdef CONFIG_NUMA
+	nid =3D node_cpuid[cpuid].nid;
+	/* this can be removed when node-hptplug by cpu-hot-add is implemented */
+	if (!node_online(nid))
+		nid =3D 0;
+	/* see also build_cpu_to_node_map() in numa.c */
+	if (!cpu_isset(cpuid, node_to_cpumask(nid))) {
+		cpu_set(cpuid, node_to_cpumask(nid));
+		cpu_to_node_map[cpuid] =3D nid;
+	}
+#endif
 	unlock_ipi_calllock();
 	per_cpu(cpu_state, cpuid) =3D CPU_ONLINE;
=20
@@ -701,6 +714,7 @@
 int __cpu_disable(void)
 {
 	int cpu =3D smp_processor_id();
+	int nid =3D cpu_to_node(cpu);
=20
 	/*
 	 * dont permit boot processor for now
@@ -719,6 +733,10 @@
=20
 	remove_siblinginfo(cpu);
 	cpu_clear(cpu, cpu_online_map);
+#ifdef CONFIG_NUMA
+	cpu_clear(cpu, node_to_cpumask(nid));
+	cpu_to_node_map[cpu] =3D 0;
+#endif
 	fixup_irqs();
 	local_flush_tlb_all();
 	cpu_clear(cpu, cpu_callin_map);
Index: linux-2.6.18/arch/ia64/kernel/acpi.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.18.orig/arch/ia64/kernel/acpi.c	2006-=
09-20 12:42:06.000000000 +0900
+++ linux-2.6.18/arch/ia64/kernel/acpi.c	2006-09-22 09:28:00.000000000 +0900
@@ -771,14 +771,15 @@
 {
 #ifdef CONFIG_ACPI_NUMA
 	int pxm_id;
+	int nid;
=20
 	pxm_id =3D acpi_get_pxm(handle);
-
+	nid =3D acpi_map_pxm_to_node(pxm_id);
 	/*
 	 * Assuming that the container driver would have set the proximity
 	 * domain and would have initialized pxm_to_node(pxm_id) && pxm_flag
 	 */
-	node_cpuid[cpu].nid =3D (pxm_id < 0) ? 0 : pxm_to_node(pxm_id);
+	node_cpuid[cpu].nid =3D nid;
=20
 	node_cpuid[cpu].phys_id =3D physid;
 #endif

