From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Mar 2006 19:54:26 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200603081954.k28JsQKw007998@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/gensparse_defconfig |   12 ++++++++++--
 arch/ia64/kernel/cyclone.c            |    2 +-
 arch/ia64/kernel/mca_drv.c            |   16 +++++++++++-----
 arch/ia64/sn/kernel/sn2/sn2_smp.c     |    2 +-
 arch/ia64/sn/kernel/tiocx.c           |    2 +-
 drivers/char/mmtimer.c                |    2 +-
 drivers/serial/sn_console.c           |    2 +-
 7 files changed, 26 insertions(+), 12 deletions(-)

Bjorn Helgaas:
      [IA64] gensparse_defconfig: turn on PNPACPI
      [IA64] don't report !sn2 or !summit hardware as an error
      [IA64] SGI SN drivers: don't report !sn2 hardware as an error

Russ Anderson:
      [IA64] Increase severity of MCA recovery messages
      [IA64] mca recovery return value when no bus check

diff-tree e1c48554ae295de984eee83a7798e7fb394a1629 (from f032f90809ebbbd28feb90f97add2e0a869a42ed)
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Fri Mar 3 16:42:26 2006 -0600

    [IA64] mca recovery return value when no bus check
    
    When there is no bus check, the return code should be failure, not success.
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 53ffb06..e883d85 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -568,10 +568,15 @@ recover_from_processor_error(int platfor
 		return 0;
 
 	/*
-	 * If there is no bus error, record is weird but we need not to recover.
+	 * The cache check and bus check bits have four possible states
+	 *   cc bc
+	 *    0  0	Weird record, not recovered
+	 *    1  0	Cache error, not recovered
+	 *    0  1	I/O error, attempt recovery
+	 *    1  1	Memory error, attempt recovery
 	 */
 	if (psp->bc = 0 || pbci = NULL)
-		return 1;
+		return 0;
 
 	/*
 	 * Sorry, we cannot handle so many.

diff-tree f032f90809ebbbd28feb90f97add2e0a869a42ed (from 6c5e62159cdef89d8385958c9d8c88efa867110c)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Fri Mar 3 15:34:34 2006 -0700

    [IA64] SGI SN drivers: don't report !sn2 hardware as an error
    
    This stuff is all in the generic ia64 kernel, and the new initcall error
    reporting complains about them.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/drivers/char/mmtimer.c b/drivers/char/mmtimer.c
index c923781..1b05fa6 100644
--- a/drivers/char/mmtimer.c
+++ b/drivers/char/mmtimer.c
@@ -675,7 +675,7 @@ static int __init mmtimer_init(void)
 	cnodeid_t node, maxn = -1;
 
 	if (!ia64_platform_is("sn2"))
-		return -1;
+		return 0;
 
 	/*
 	 * Sanity check the cycles/sec variable
diff --git a/drivers/serial/sn_console.c b/drivers/serial/sn_console.c
index 43e67d6..60ea4a3 100644
--- a/drivers/serial/sn_console.c
+++ b/drivers/serial/sn_console.c
@@ -820,7 +820,7 @@ static int __init sn_sal_module_init(voi
 	int retval;
 
 	if (!ia64_platform_is("sn2"))
-		return -ENODEV;
+		return 0;
 
 	printk(KERN_INFO "sn_console: Console driver init\n");
 

diff-tree 6c5e62159cdef89d8385958c9d8c88efa867110c (from 57ebc9918f8747c9db7e65659dfd632d4db99e3a)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Fri Mar 3 15:33:47 2006 -0700

    [IA64] don't report !sn2 or !summit hardware as an error
    
    This stuff is all in the generic ia64 kernel, and the new initcall error
    reporting complains about them.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index 6ade379..e00b215 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -36,7 +36,7 @@ int __init init_cyclone_clock(void)
 	u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
 
 	if (!use_cyclone)
-		return -ENODEV;
+		return 0;
 
 	printk(KERN_INFO "Summit chipset: Starting Cyclone Counter.\n");
 
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 24eefb2..b2e1e74 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -446,7 +446,7 @@ static struct proc_dir_entry *proc_sn2_p
 static int __init sn2_ptc_init(void)
 {
 	if (!ia64_platform_is("sn2"))
-		return -ENOSYS;
+		return 0;
 
 	if (!(proc_sn2_ptc = create_proc_entry(PTC_BASENAME, 0444, NULL))) {
 		printk(KERN_ERR "unable to create %s proc entry", PTC_BASENAME);
diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index 8a56f8b..99cb28e 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -484,7 +484,7 @@ static int __init tiocx_init(void)
 	int found_tiocx_device = 0;
 
 	if (!ia64_platform_is("sn2"))
-		return -ENODEV;
+		return 0;
 
 	bus_register(&tiocx_bus_type);
 

diff-tree 57ebc9918f8747c9db7e65659dfd632d4db99e3a (from ea0e92a613a1caf85583c83cd131cef7d0f5571d)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Thu Mar 2 16:59:50 2006 -0700

    [IA64] gensparse_defconfig: turn on PNPACPI
    
    Turn on CONFIG_PNPACPI.  I recently removed 8250_acpi.c.  All devices
    previously claimed by 8250_acpi.c should now be claimed by 8250_pnp.c.
    This depends on having CONFIG_PNPACPI so ACPI devices show up as PNP
    devices.
    
    All other ia64 defconfigs either have CONFIG_PNPACPI already, or
    don't have 8250 support turned on at all.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index 184678f..744fd2f 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.16-rc5
-# Mon Feb 27 16:15:43 2006
+# Thu Mar  2 16:39:10 2006
 #
 
 #
@@ -312,7 +312,13 @@ CONFIG_FW_LOADER=m
 #
 # Plug and Play support
 #
-# CONFIG_PNP is not set
+CONFIG_PNP=y
+# CONFIG_PNP_DEBUG is not set
+
+#
+# Protocols
+#
+CONFIG_PNPACPI=y
 
 #
 # Block devices
@@ -357,6 +363,7 @@ CONFIG_BLK_DEV_IDESCSI=m
 # IDE chipset support/bugfixes
 #
 CONFIG_IDE_GENERIC=y
+# CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
 # CONFIG_IDEPCI_SHARE_IRQ is not set
 # CONFIG_BLK_DEV_OFFBOARD is not set
@@ -525,6 +532,7 @@ CONFIG_DUMMY=m
 # CONFIG_BONDING is not set
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
+# CONFIG_NET_SB1000 is not set
 
 #
 # ARCnet devices

diff-tree ea0e92a613a1caf85583c83cd131cef7d0f5571d (from d0b004840bd3b5ff2f2a0ad14fa0bd43349f5175)
Author: Russ Anderson <rja@sgi.com>
Date:   Tue Mar 7 15:23:25 2006 -0800

    [IA64] Increase severity of MCA recovery messages
    
    The MCA recovery messages are currently KERN_DEBUG,
    so they don't show up in /var/log/messages (by default).
    Increase the severity to KERN_ERR, for the initial
    message (and also add the physical address to this
    message). Leave the successful isolation message as
    KERN_DEBUG, but increase the severity when isolation
    fails to KERN_CRIT.
    
    [Russ' patch made these all KERN_CRIT]
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 8fd93af..53ffb06 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -123,8 +123,9 @@ mca_page_isolate(unsigned long paddr)
 void
 mca_handler_bh(unsigned long paddr)
 {
-	printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
-		current->pid, current->comm);
+	printk(KERN_ERR
+		"OS_MCA: process [pid: %d](%s) encounters MCA (paddr=%lx)\n",
+		current->pid, current->comm, paddr);
 
 	spin_lock(&mca_bh_lock);
 	switch (mca_page_isolate(paddr)) {
@@ -132,7 +133,7 @@ mca_handler_bh(unsigned long paddr)
 		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
 		break;
 	case ISOLATE_NG:
-		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+		printk(KERN_CRIT "Page isolation: ( %lx ) failure.\n", paddr);
 		break;
 	default:
 		break;
