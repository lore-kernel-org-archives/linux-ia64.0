From: Ashok Raj <ashok.raj@intel.com>
Date: Mon, 07 Jun 2004 17:22:26 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040607102226.A19556@unix-os.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
To: linux-ia64@vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 07, 2004 at 09:41:49AM -0700, Dave Hansen wrote:
> On Mon, 2004-06-07 at 07:08, Ashok Raj wrote:plugging.
> > +		if (systemcfg->platform == PLATFORM_PSERIES_LPAR)
> > +			cpu->no_control=1;
> 
> That condition is also inverted.  Should read:
> 
> if (systemcfg->platform != PLATFORM_PSERIES_LPAR)
> 	cpu->no_control = 1;

Good catch...I knew i mentioned untested :-)

fixed patch attached...

Cheers,
ashok

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p00001_cpu_control_file.patch"


Signed-off-by: Ashok Raj <ashok.raj@intel.com>

D: This file provides ability for caller of register_cpu() to either create
D: a control file, or not. This can be handy if a particular platform decides
D: that certain CPU's are not removable. Hence would like to not create
D: a control file.


---

 linux-2.6.7-rc2-root/arch/ppc64/kernel/sysfs.c |   10 ++++++++++
 linux-2.6.7-rc2-root/drivers/base/cpu.c        |    4 +++-
 linux-2.6.7-rc2-root/include/linux/cpu.h       |    1 +
 3 files changed, 14 insertions(+), 1 deletion(-)

diff -puN include/linux/cpu.h~cpu_control_file include/linux/cpu.h
--- linux-2.6.7-rc2/include/linux/cpu.h~cpu_control_file	2004-06-06 12:54:02.319017387 -0700
+++ linux-2.6.7-rc2-root/include/linux/cpu.h	2004-06-07 06:25:44.667732023 -0700
@@ -27,6 +27,7 @@
 
 struct cpu {
 	int node_id;		/* The node which contains the CPU */
+	int no_control;		/* Should the sysfs control file be created? */
 	struct sys_device sysdev;
 };
 
diff -puN drivers/base/cpu.c~cpu_control_file drivers/base/cpu.c
--- linux-2.6.7-rc2/drivers/base/cpu.c~cpu_control_file	2004-06-06 12:56:47.349375320 -0700
+++ linux-2.6.7-rc2-root/drivers/base/cpu.c	2004-06-07 07:03:12.624937664 -0700
@@ -58,6 +58,8 @@ static inline void register_cpu_control(
 
 /*
  * register_cpu - Setup a driverfs device for a CPU.
+ * @cpu - Callers can set the cpu->no_control field to 1, to indicate not to
+ *		  generate a control file in sysfs for this CPU.
  * @num - CPU number to use when creating the device.
  *
  * Initialize and register the CPU device.
@@ -75,7 +77,7 @@ int __init register_cpu(struct cpu *cpu,
 		error = sysfs_create_link(&root->sysdev.kobj,
 					  &cpu->sysdev.kobj,
 					  kobject_name(&cpu->sysdev.kobj));
-	if (!error)
+	if (!error && !cpu->no_control)
 		register_cpu_control(cpu);
 	return error;
 }
diff -puN arch/ppc64/kernel/sysfs.c~cpu_control_file arch/ppc64/kernel/sysfs.c
--- linux-2.6.7-rc2/arch/ppc64/kernel/sysfs.c~cpu_control_file	2004-06-06 13:12:06.467033408 -0700
+++ linux-2.6.7-rc2-root/arch/ppc64/kernel/sysfs.c	2004-06-07 10:12:45.999901454 -0700
@@ -325,6 +325,16 @@ static int __init topology_init(void)
 #ifdef CONFIG_NUMA
 		parent = &node_devices[cpu_to_node(cpu)];
 #endif
+		/*
+		 * For now, we just see if the system supports making
+		 * the RTAS calls for CPU hotplug.  But, there may be a
+		 * more comprehensive way to do this for an individual
+		 * CPU.  For instance, the boot cpu might never be valid
+		 * for hotplugging.
+		 */
+		if (systemcfg->platform != PLATFORM_PSERIES_LPAR)
+			cpu->no_control=1;
+
 		register_cpu(c, cpu, parent);
 
 		register_cpu_pmc(&c->sysdev);

_

--M9NhX3UHpAaciwkO--
