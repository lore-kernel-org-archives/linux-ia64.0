From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 07 Jun 2004 05:05:35 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <1086584735.30138.130.camel@nighthawk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-E5KwcFXj9fgCEmrt68U3"
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
To: linux-ia64@vger.kernel.org


--=-E5KwcFXj9fgCEmrt68U3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2004-06-06 at 13:27, Ashok Raj wrote:
> On Sat, Jun 05, 2004 at 12:22:21PM -0700, Dave Hansen wrote:
> > knowledge about the system from the pure layout of sysfs.  Waiting until
> > __cpu_disable() to tell the user that there was no possibility of the
> > cpu being offlined seems a bit late in the process.  Your idea about the
> > cpuinfo file in sysfs is definitely right; it has *exactly* the
> > information that I'm trying to present.  But, the current sysfs
> > guidelines tend to discourage single files with lots of information like
> > those in /proc.  
> 
> How does the attached patch look? I would try to keep away from proliferation of
> common->arch->platform code as little as possible. What i have done is
> send a hint for suppressing the control file creation based on what was
> set in the struct cpu, before calling register_cpu() by the arch specific 
> topology_init() functions. No new __arch/__platform functions.
> 
> here is the untested patch for PPC64, does this seem to do what you need?

I like that patch a lot.  It certainly removes any argument about
function names :)

Can we maybe change the name of the new field a bit?

-- Dave

--=-E5KwcFXj9fgCEmrt68U3
Content-Disposition: attachment; filename=cpuhotplug-online-2.6.7-rc2-mm2-5.patch
Content-Type: text/x-patch; name=cpuhotplug-online-2.6.7-rc2-mm2-5.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

diff -urp linux-2.6.7-rc2-mm2-clean/arch/ppc64/kernel/sysfs.c linux-2.6.7-rc2-mm2-cpuonline2/arch/ppc64/kernel/sysfs.c
--- linux-2.6.7-rc2-mm2-clean/arch/ppc64/kernel/sysfs.c	Fri Jun  4 13:27:13 2004
+++ linux-2.6.7-rc2-mm2-cpuonline2/arch/ppc64/kernel/sysfs.c	Sun Jun  6 21:58:55 2004
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
+			cpu->can_control = 1;
+
 		register_cpu(c, cpu, parent);
 
 		register_cpu_pmc(&c->sysdev);
diff -urp linux-2.6.7-rc2-mm2-clean/drivers/base/cpu.c linux-2.6.7-rc2-mm2-cpuonline2/drivers/base/cpu.c
--- linux-2.6.7-rc2-mm2-clean/drivers/base/cpu.c	Fri Jun  4 13:27:09 2004
+++ linux-2.6.7-rc2-mm2-cpuonline2/drivers/base/cpu.c	Sun Jun  6 21:59:35 2004
@@ -75,7 +75,7 @@ int __init register_cpu(struct cpu *cpu,
 		error = sysfs_create_link(&root->sysdev.kobj,
 					  &cpu->sysdev.kobj,
 					  kobject_name(&cpu->sysdev.kobj));
-	if (!error)
+	if (!error && !cpu->can_control)
 		register_cpu_control(cpu);
 	return error;
 }
diff -urp linux-2.6.7-rc2-mm2-clean/include/linux/cpu.h linux-2.6.7-rc2-mm2-cpuonline2/include/linux/cpu.h
--- linux-2.6.7-rc2-mm2-clean/include/linux/cpu.h	Fri Jun  4 13:27:11 2004
+++ linux-2.6.7-rc2-mm2-cpuonline2/include/linux/cpu.h	Sun Jun  6 21:58:35 2004
@@ -27,6 +27,7 @@
 
 struct cpu {
 	int node_id;		/* The node which contains the CPU */
+	int can_control;	/* Should the sysfs control file be created? */
 	struct sys_device sysdev;
 };
 

--=-E5KwcFXj9fgCEmrt68U3--

