From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 14 Feb 2005 17:09:51 +0000
Subject: Re: CPU Hotplug - Support for BSP removal
Message-Id: <1108400991.6175.27.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050212071417.B26140@unix-os.sc.intel.com>
In-Reply-To: <20050212071417.B26140@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2005-02-12 at 07:14 -0800, Ashok Raj wrote:
> Hi
> 
> This patch requires the cpei retarget patch posted earlier. 
> 
> CAVEAT: tiger4 BIOS does not have the right value for branch reg0 when handed
> off to OS. I observed i could handoff the BSP to SAL, but due to incorrect jump
> address in b0, it ends up in some while (1); loop later. So we cannot send 
> another IPI to wakeup the bsp. The system seemed to run fine with rest of
> the processors.

  In my reading of the spec, I don't see how we can count on the BSP b0
being the appropriate value for return to SAL.  If I don't enable the
fixup option, we branch off to some bad address and the CPU is lost.
With the fixup, hotplugging the BSP on and rx2600 seems to work.

> I havent done much with the cpep stuff.

  At a minimum, the patches below are required.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

--- linux/arch/ia64/Kconfig	2005-02-14 09:36:15.642178325 -0700
+++ linux/arch/ia64/Kconfig	2005-02-14 09:36:29.286709408 -0700
@@ -285,7 +285,7 @@
 
 config BSP_REMOVE_WORKAROUND
 	bool "Enable temporary workaround to fix b0 value for CPU hotplug"
-	depends on PERMIT_BSP_REMOVE && FORCE_CPEI_RETARGET && EXPERIMENTAL
+	depends on PERMIT_BSP_REMOVE && EXPERIMENTAL
 	default y
 	---help---
 	On tiger 4 systems's BSP's branch reg 0 (b0) is not set correctly.
--- linux/arch/ia64/kernel/topology.c	2005-02-14 09:37:20.191005660 -0700
+++ linux/arch/ia64/kernel/topology.c	2005-02-14 09:26:30.178318310 -0700
@@ -31,6 +31,7 @@
 int arch_register_cpu(int num)
 {
 	struct node *parent = NULL;
+	extern int cpe_vector;
 	
 #ifdef CONFIG_NUMA
 	parent = &sysfs_nodes[cpu_to_node(num)];
@@ -40,7 +41,7 @@
 	 * If CPEI cannot be re-targetted, and this is
 	 * CPEI target, then dont create the control file
 	 */
-	if (!can_cpei_retarget() && is_cpu_cpei_target(num))
+	if (cpe_vector > 0 && !can_cpei_retarget() && is_cpu_cpei_target(num))
 		sysfs_cpus[num].cpu.no_control = 1;
 
 	return register_cpu(&sysfs_cpus[num].cpu, num, parent);


