From: Alex Chiang <achiang@hp.com>
Date: Mon, 10 Mar 2008 22:27:35 +0000
Subject: [PATCH, RFC] Create 'slot' sysfs attribute in
Message-Id: <20080310222735.GA22619@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, lenb@kernel.org
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Len, Tony,

A while back, I submitted a patch to expose the value of the _SUN
method for CPUs. On ia64, the "physical id" field in
/proc/cpuinfo isn't sufficient for some legacy HP ia64 platforms,
as they do not have a modern SAL or PAL.

	http://lkml.org/lkml/2007/10/30/529

That patch wasn't so great because as Len pointed out, /proc/acpi
is a deprecated interface.

Here is another try that attempts to present a generic "slot"
attribute in sysfs that leaves the various architectures free to
implement however they like.

Yes, I am aware of the physical_package_id attribute. However,
that doesn't necessarily map to a slot on the system board.
Additionally, it's broken on the same ia64 systems where
/proc/cpuinfo is broken, because it's trying to read the same
field. :-/

On ia64, I have a somewhat ugly implementation, where the ACPI
processor driver is filling in the answer. I chose this approach
because I couldn't figure out how to do it in the base CPU
driver, since calling the _SUN method requires the ACPI
interpreter to be initialized, and it didn't look like that was
the case when we did things like identify_siblings(), for
instance.

Finally, there is something that looks odd in struct
cpuinfo_ia64, where there are now two #ifdef CONFIG_SMP
statements. I did this because adding the new 'slot' member
created a 4-byte hole in the struct. It felt a little cleaner to
me to move the 'int cpu;' member upwards to fill in the hole, and
then my 'slot' could take the spot of 'cpu'.

I'd like to get feedback on both:

	- the concept in general of creating a new sysfs
	  attribute

	- the ia64 implementation, specifically

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>

Physical slot information for CPUs is important for many reasons,
including managability. For instance, if a platform supports
physical CPU hotplug, it would be nice for the user to know which
physical CPU module to actually unplug after offlining it.

The "physical id" field in /proc/cpuinfo is broken/missing on
older ia64 platforms that do not have modern firmware.

/sys/devices/system/cpu/cpuN/topology/physical_package_id exists,
but is broken on those same platforms because it's simply reading
the same field that would have been presented in /proc/cpuinfo.

Create a 'slot' attribute and define an interface that may be
populated via alternate sources, without breaking existing
functionality.

Implement this interface on ia64 by invoking the _SUN method on a
per cpu basis.

Leave other archs alone for now.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/setup.c      |    1 +
 arch/ia64/kernel/topology.c   |    6 ++++++
 drivers/acpi/processor_core.c |    5 +++++
 drivers/base/topology.c       |    9 +++++++++
 include/asm-ia64/cpu.h        |    1 +
 include/asm-ia64/processor.h  |    7 ++++++-
 include/asm-ia64/topology.h   |    1 +
 include/asm-x86/cpu.h         |    1 +
 8 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ebd1a09..34de68a 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -735,6 +735,7 @@ identify_cpu (struct cpuinfo_ia64 *c)
 	 */
 	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
 	c->socket_id = -1;
+	c->slot = -1;
 
 	identify_siblings(c);
 
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index a2484fc..3810b48 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -27,6 +27,12 @@
 
 static struct ia64_cpu *sysfs_cpus;
 
+void arch_set_topology_slot(int num, u32 slot)
+{
+	cpu_data(num)->slot = slot;
+}
+EXPORT_SYMBOL(arch_set_topology_slot);
+
 int arch_register_cpu(int num)
 {
 #if defined (CONFIG_ACPI) && defined (CONFIG_HOTPLUG_CPU)
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index a3cc8a9..89a9ad5 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -590,6 +590,11 @@ static int acpi_processor_get_info(struct acpi_processor *pr, unsigned has_uid)
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Processor [%d:%d]\n", pr->id,
 			  pr->acpi_id));
 
+	status = acpi_evaluate_object(pr->handle, "_SUN", NULL, &buffer);
+	if (ACPI_FAILURE(status))
+		object.integer.value = -1;
+	arch_set_topology_slot(pr->id, object.integer.value);
+
 	if (!object.processor.pblk_address)
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "No PBLK (NULL address)\n"));
 	else if (object.processor.pblk_length != 6)
diff --git a/drivers/base/topology.c b/drivers/base/topology.c
index e1d3ad4..4fcffca 100644
--- a/drivers/base/topology.c
+++ b/drivers/base/topology.c
@@ -57,6 +57,14 @@ define_one_ro(physical_package_id);
 #define ref_physical_package_id_attr
 #endif
 
+#ifdef	topology_slot
+define_id_show_func(slot);
+define_one_ro(slot);
+#define ref_slot_attr			&attr_slot.attr,
+#else
+#define ref_slot_attr
+#endif
+
 #ifdef topology_core_id
 define_id_show_func(core_id);
 define_one_ro(core_id);
@@ -83,6 +91,7 @@ define_one_ro(core_siblings);
 
 static struct attribute *default_attrs[] = {
 	ref_physical_package_id_attr
+	ref_slot_attr
 	ref_core_id_attr
 	ref_thread_siblings_attr
 	ref_core_siblings_attr
diff --git a/include/asm-ia64/cpu.h b/include/asm-ia64/cpu.h
index e87fa32..393e545 100644
--- a/include/asm-ia64/cpu.h
+++ b/include/asm-ia64/cpu.h
@@ -14,6 +14,7 @@ DECLARE_PER_CPU(struct ia64_cpu, cpu_devices);
 
 DECLARE_PER_CPU(int, cpu_state);
 
+extern void arch_set_topology_slot(int num, u32 slot);
 extern int arch_register_cpu(int num);
 #ifdef CONFIG_HOTPLUG_CPU
 extern void arch_unregister_cpu(int);
diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
index 741f7ec..066553c 100644
--- a/include/asm-ia64/processor.h
+++ b/include/asm-ia64/processor.h
@@ -125,6 +125,10 @@ struct ia64_psr {
  */
 struct cpuinfo_ia64 {
 	__u32 softirq_pending;
+
+#ifdef CONFIG_SMP
+	int cpu;
+#endif
 	__u64 itm_delta;	/* # of clock cycles between clock ticks */
 	__u64 itm_next;		/* interval timer mask value to use for next clock tick */
 	__u64 nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_freq */
@@ -140,7 +144,6 @@ struct cpuinfo_ia64 {
 
 #ifdef CONFIG_SMP
 	__u64 loops_per_jiffy;
-	int cpu;
 	__u32 socket_id;	/* physical processor socket id */
 	__u16 core_id;		/* core id */
 	__u16 thread_id;	/* thread id */
@@ -150,6 +153,8 @@ struct cpuinfo_ia64 {
 	__u8  threads_per_core;	/* Threads per core */
 #endif
 
+	__u32 slot;		/* physical slot; can differ from socket_id */
+
 	/* CPUID-derived information: */
 	__u64 ppn;
 	__u64 features;
diff --git a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
index 2d67b72..3b0ab1c 100644
--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -110,6 +110,7 @@ void build_cpu_to_node_map(void);
 
 #ifdef CONFIG_SMP
 #define topology_physical_package_id(cpu)	(cpu_data(cpu)->socket_id)
+#define topology_slot(cpu)			(cpu_data(cpu)->slot)
 #define topology_core_id(cpu)			(cpu_data(cpu)->core_id)
 #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
 #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
diff --git a/include/asm-x86/cpu.h b/include/asm-x86/cpu.h
index 73f2ea8..43132a2 100644
--- a/include/asm-x86/cpu.h
+++ b/include/asm-x86/cpu.h
@@ -11,6 +11,7 @@ struct x86_cpu {
 	struct cpu cpu;
 };
 
+extern void arch_set_topology_slot(int num, u32 slot);
 #ifdef CONFIG_HOTPLUG_CPU
 extern int arch_register_cpu(int num);
 extern void arch_unregister_cpu(int);
-- 
1.5.3.1.g1e61

