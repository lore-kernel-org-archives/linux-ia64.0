From: Ashok Raj <ashok.raj@intel.com>
Date: Sun, 06 Jun 2004 20:27:23 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040606132723.A10563@unix-os.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
To: linux-ia64@vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 05, 2004 at 12:22:21PM -0700, Dave Hansen wrote:
> knowledge about the system from the pure layout of sysfs.  Waiting until
> __cpu_disable() to tell the user that there was no possibility of the
> cpu being offlined seems a bit late in the process.  Your idea about the
> cpuinfo file in sysfs is definitely right; it has *exactly* the
> information that I'm trying to present.  But, the current sysfs
> guidelines tend to discourage single files with lots of information like
> those in /proc.  

How does the attached patch look? I would try to keep away from proliferation of
common->arch->platform code as little as possible. What i have done is
send a hint for suppressing the control file creation based on what was
set in the struct cpu, before calling register_cpu() by the arch specific 
topology_init() functions. No new __arch/__platform functions.

here is the untested patch for PPC64, does this seem to do what you need?

Cheers,
ashok

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p00001_cpu_control_file.patch"



D: This file provides ability for caller of register_cpu() to either create
D: a control file, or not. This can be handy if a particular platform decides
D: that certain CPU's are not removable. Hence would like to not create
D: a control file.


---

 linux-2.6.7-rc2-root/arch/ppc64/kernel/sysfs.c |   10 ++++++++++
 linux-2.6.7-rc2-root/drivers/base/cpu.c        |    2 +-
 linux-2.6.7-rc2-root/include/linux/cpu.h       |    1 +
 3 files changed, 12 insertions(+), 1 deletion(-)

diff -puN include/linux/cpu.h~cpu_control_file include/linux/cpu.h
--- linux-2.6.7-rc2/include/linux/cpu.h~cpu_control_file	2004-06-06 12:54:02.319017387 -0700
+++ linux-2.6.7-rc2-root/include/linux/cpu.h	2004-06-06 12:56:01.663805054 -0700
@@ -27,6 +27,7 @@
 
 struct cpu {
 	int node_id;		/* The node which contains the CPU */
+	int not_removable;	/* This cpu is not removable */
 	struct sys_device sysdev;
 };
 
diff -puN drivers/base/cpu.c~cpu_control_file drivers/base/cpu.c
--- linux-2.6.7-rc2/drivers/base/cpu.c~cpu_control_file	2004-06-06 12:56:47.349375320 -0700
+++ linux-2.6.7-rc2-root/drivers/base/cpu.c	2004-06-06 12:58:12.390434486 -0700
@@ -75,7 +75,7 @@ int __init register_cpu(struct cpu *cpu,
 		error = sysfs_create_link(&root->sysdev.kobj,
 					  &cpu->sysdev.kobj,
 					  kobject_name(&cpu->sysdev.kobj));
-	if (!error)
+	if (!error && !cpu->not_removable)
 		register_cpu_control(cpu);
 	return error;
 }
diff -puN arch/ppc64/kernel/sysfs.c~cpu_control_file arch/ppc64/kernel/sysfs.c
--- linux-2.6.7-rc2/arch/ppc64/kernel/sysfs.c~cpu_control_file	2004-06-06 13:12:06.467033408 -0700
+++ linux-2.6.7-rc2-root/arch/ppc64/kernel/sysfs.c	2004-06-06 13:12:43.805919713 -0700
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
+		if (systemcfg->platform == PLATFORM_PSERIES_LPAR)
+			cpu->not_removable=1;
+
 		register_cpu(c, cpu, parent);
 
 		register_cpu_pmc(&c->sysdev);

_

--WIyZ46R2i8wDzkSu--
