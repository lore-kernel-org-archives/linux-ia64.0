From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Oct 2006 15:52:13 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200610181552.k9IFqDoq018119@agluck-lia64.sc.intel.com>
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

 arch/ia64/configs/sn2_defconfig |  219 +++++++++++++++++++++++++++++++---------
 arch/ia64/kernel/acpi.c         |    9 -
 arch/ia64/kernel/irq_ia64.c     |   20 +++
 arch/ia64/kernel/pal.S          |   58 ++++------
 arch/ia64/kernel/perfmon.c      |    3 
 arch/ia64/kernel/time.c         |    6 +
 arch/ia64/sn/kernel/setup.c     |   12 --
 include/asm-ia64/io.h           |    4 
 include/asm-ia64/pal.h          |   11 --
 9 files changed, 232 insertions(+), 110 deletions(-)

Aron Griffis:
      [IA64] move ioremap/ioremap_nocache under __KERNEL__

Bjorn Helgaas:
      [IA64] remove unused PAL_CALL_IC_OFF
      [IA64] reformat pal.S to fit in 80 columns, fix typos
      [IA64] remove unused acpi_kbd_controller_present, acpi_legacy_devices

Jack Steiner:
      [IA64] - Allow IPIs in timer loop
      [IA64] Count resched interrupts

Jes Sorensen:
      [IA64] update sn2_defconfig

Tony Luck:
      [IA64] perfmon fix for global IRQ fix

... and the complete "git what changed -p" ...

commit 9b3377f9921766b6193861d0e3194854b1d765fe
Author: Jack Steiner <steiner@sgi.com>
Date:   Mon Oct 16 16:17:43 2006 -0500

    [IA64] Count resched interrupts
    
    Count the number of "resched" interrupts that each cpu receives.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 68339dd..9c6dafa 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -180,7 +180,9 @@ #endif /* IRQ_DEBUG */
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
-		if (!IS_RESCHEDULE(vector)) {
+		if (unlikely(IS_RESCHEDULE(vector)))
+			 kstat_this_cpu.irqs[vector]++;
+		else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
@@ -225,7 +227,9 @@ void ia64_process_pending_intr(void)
 	  * Perform normal interrupt style processing
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
-		if (!IS_RESCHEDULE(vector)) {
+		if (unlikely(IS_RESCHEDULE(vector)))
+			 kstat_this_cpu.irqs[vector]++;
+		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
@@ -258,11 +262,22 @@ #endif
 #ifdef CONFIG_SMP
 extern irqreturn_t handle_IPI (int irq, void *dev_id);
 
+static irqreturn_t dummy_handler (int irq, void *dev_id)
+{
+	BUG();
+}
+
 static struct irqaction ipi_irqaction = {
 	.handler =	handle_IPI,
 	.flags =	IRQF_DISABLED,
 	.name =		"IPI"
 };
+
+static struct irqaction resched_irqaction = {
+	.handler =	dummy_handler,
+	.flags =	SA_INTERRUPT,
+	.name =		"resched"
+};
 #endif
 
 void
@@ -287,6 +302,7 @@ init_IRQ (void)
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
+	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();

commit 219902677351665bf0513115592a6dd665cf06e8
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Fri Sep 29 12:58:31 2006 -0600

    [IA64] remove unused acpi_kbd_controller_present, acpi_legacy_devices
    
    Nobody uses either one anymore.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 32c3abe..73ef4a8 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -64,9 +64,6 @@ EXPORT_SYMBOL(pm_idle);
 void (*pm_power_off) (void);
 EXPORT_SYMBOL(pm_power_off);
 
-unsigned char acpi_kbd_controller_present = 1;
-unsigned char acpi_legacy_devices;
-
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
@@ -628,12 +625,6 @@ static int __init acpi_parse_fadt(unsign
 
 	fadt = (struct fadt_descriptor *)fadt_header;
 
-	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
-		acpi_kbd_controller_present = 0;
-
-	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
-		acpi_legacy_devices = 1;
-
 	acpi_register_gsi(fadt->sci_int, ACPI_LEVEL_SENSITIVE, ACPI_ACTIVE_LOW);
 	return 0;
 }
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 5f2dcba..7a2d824 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -65,7 +65,6 @@ extern void sn_timer_init(void);
 extern unsigned long last_time_offset;
 extern void (*ia64_mark_idle) (int);
 extern void snidle(int);
-extern unsigned char acpi_kbd_controller_present;
 extern unsigned long long (*ia64_printk_clock)(void);
 
 unsigned long sn_rtc_cycles_per_second;
@@ -452,17 +451,6 @@ #endif				/* def(CONFIG_VT) && def(CONFI
 
 	ia64_printk_clock = ia64_sn2_printk_clock;
 
-	/*
-	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
-	 * support here so we don't have to listen to failed keyboard probe
-	 * messages.
-	 */
-	if (is_shub1() && version <= 0x0209 && acpi_kbd_controller_present) {
-		printk(KERN_INFO "Disabling legacy keyboard support as prom "
-		       "is too old and doesn't provide FADT\n");
-		acpi_kbd_controller_present = 0;
-	}
-
 	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
 
 	/*

commit 8611342f3dda0e13970e724129a8e2066de1362e
Author: Jes Sorensen <jes@sgi.com>
Date:   Mon Oct 9 05:24:57 2006 -0400

    [IA64] update sn2_defconfig
    
    The current sn2_defconfig is obsolete, in particular the recent ATA
    changes are a pain, so here's a patch to get things in sync ... at
    least for a day or two :)
    
    Update sn_defconfig to match current community kernel tree.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 0f14a82..64e951d 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -1,8 +1,9 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.17-rc3
-# Thu Apr 27 11:48:23 2006
+# Linux kernel version: 2.6.19-rc1
+# Mon Oct  9 10:53:59 2006
 #
+CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
 
 #
 # Code maturity level options
@@ -18,16 +19,22 @@ CONFIG_LOCALVERSION=""
 # CONFIG_LOCALVERSION_AUTO is not set
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
+# CONFIG_IPC_NS is not set
 CONFIG_POSIX_MQUEUE=y
 # CONFIG_BSD_PROCESS_ACCT is not set
-CONFIG_SYSCTL=y
+CONFIG_TASKSTATS=y
+# CONFIG_TASK_DELAY_ACCT is not set
+# CONFIG_UTS_NS is not set
 # CONFIG_AUDIT is not set
 # CONFIG_IKCONFIG is not set
 CONFIG_CPUSETS=y
 CONFIG_RELAY=y
 CONFIG_INITRAMFS_SOURCE=""
 CONFIG_CC_OPTIMIZE_FOR_SIZE=y
+CONFIG_TASK_XACCT=y
+CONFIG_SYSCTL=y
 # CONFIG_EMBEDDED is not set
+# CONFIG_SYSCTL_SYSCALL is not set
 CONFIG_KALLSYMS=y
 CONFIG_KALLSYMS_ALL=y
 # CONFIG_KALLSYMS_EXTRA_PASS is not set
@@ -40,6 +47,8 @@ CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_SHMEM=y
 CONFIG_SLAB=y
+CONFIG_VM_EVENT_COUNTERS=y
+CONFIG_RT_MUTEXES=y
 # CONFIG_TINY_SHMEM is not set
 CONFIG_BASE_SMALL=0
 # CONFIG_SLOB is not set
@@ -58,6 +67,7 @@ CONFIG_STOP_MACHINE=y
 #
 # Block layer
 #
+CONFIG_BLOCK=y
 # CONFIG_BLK_DEV_IO_TRACE is not set
 
 #
@@ -89,7 +99,7 @@ CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
 CONFIG_IA64_UNCACHED_ALLOCATOR=y
-CONFIG_DMA_IS_DMA32=y
+CONFIG_AUDIT_ARCH=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
 # CONFIG_IA64_HP_ZX1 is not set
@@ -116,6 +126,7 @@ CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUS24
 # CONFIG_HOTPLUG_CPU is not set
+CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y
 CONFIG_SELECT_MEMORY_MODEL=y
@@ -128,6 +139,7 @@ CONFIG_NEED_MULTIPLE_NODES=y
 # CONFIG_SPARSEMEM_STATIC is not set
 CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_MIGRATION=y
+CONFIG_RESOURCES_64BIT=y
 CONFIG_ARCH_SELECT_MEMORY_MODEL=y
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_ARCH_FLATMEM_ENABLE=y
@@ -135,15 +147,24 @@ CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
 CONFIG_NODES_SHIFT
+CONFIG_ARCH_POPULATES_NODE_MAP=y
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
+CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
 CONFIG_SGI_SN=y
+# CONFIG_IA64_ESI is not set
+
+#
+# SN Devices
+#
+CONFIG_SGI_IOC4=y
+CONFIG_SGI_IOC3=y
 
 #
 # Firmware Drivers
@@ -159,6 +180,7 @@ #
 CONFIG_PM=y
 # CONFIG_PM_LEGACY is not set
 # CONFIG_PM_DEBUG is not set
+# CONFIG_PM_SYSFS_DEPRECATED is not set
 
 #
 # ACPI (Advanced Configuration and Power Interface) Support
@@ -166,6 +188,7 @@ #
 CONFIG_ACPI=y
 # CONFIG_ACPI_BUTTON is not set
 # CONFIG_ACPI_FAN is not set
+# CONFIG_ACPI_DOCK is not set
 # CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_NUMA=y
 CONFIG_ACPI_BLACKLIST_YEAR=0
@@ -185,7 +208,12 @@ # Bus options (PCI, PCMCIA)
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
+CONFIG_PCIEPORTBUS=y
+CONFIG_HOTPLUG_PCI_PCIE=y
+# CONFIG_HOTPLUG_PCI_PCIE_POLL_EVENT_MODE is not set
+CONFIG_PCIEAER=y
 # CONFIG_PCI_MSI is not set
+# CONFIG_PCI_MULTITHREAD_PROBE is not set
 # CONFIG_PCI_DEBUG is not set
 
 #
@@ -215,6 +243,9 @@ # CONFIG_NETDEBUG is not set
 CONFIG_PACKET=y
 CONFIG_PACKET_MMAP=y
 CONFIG_UNIX=y
+CONFIG_XFRM=y
+# CONFIG_XFRM_USER is not set
+# CONFIG_XFRM_SUB_POLICY is not set
 # CONFIG_NET_KEY is not set
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
@@ -231,19 +262,31 @@ # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
 # CONFIG_INET_XFRM_TUNNEL is not set
 # CONFIG_INET_TUNNEL is not set
+CONFIG_INET_XFRM_MODE_TRANSPORT=y
+CONFIG_INET_XFRM_MODE_TUNNEL=y
+CONFIG_INET_XFRM_MODE_BEET=y
 CONFIG_INET_DIAG=m
 CONFIG_INET_TCP_DIAG=m
 # CONFIG_TCP_CONG_ADVANCED is not set
-CONFIG_TCP_CONG_BIC=y
+CONFIG_TCP_CONG_CUBIC=y
+CONFIG_DEFAULT_TCP_CONG="cubic"
 CONFIG_IPV6=m
 # CONFIG_IPV6_PRIVACY is not set
 # CONFIG_IPV6_ROUTER_PREF is not set
 # CONFIG_INET6_AH is not set
 # CONFIG_INET6_ESP is not set
 # CONFIG_INET6_IPCOMP is not set
+# CONFIG_IPV6_MIP6 is not set
 # CONFIG_INET6_XFRM_TUNNEL is not set
 # CONFIG_INET6_TUNNEL is not set
+CONFIG_INET6_XFRM_MODE_TRANSPORT=m
+CONFIG_INET6_XFRM_MODE_TUNNEL=m
+CONFIG_INET6_XFRM_MODE_BEET=m
+# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
 # CONFIG_IPV6_TUNNEL is not set
+# CONFIG_IPV6_SUBTREES is not set
+# CONFIG_IPV6_MULTIPLE_TABLES is not set
+# CONFIG_NETWORK_SECMARK is not set
 # CONFIG_NETFILTER is not set
 
 #
@@ -269,7 +312,6 @@ # CONFIG_IPX is not set
 # CONFIG_ATALK is not set
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
-# CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 
@@ -298,6 +340,7 @@ CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
 CONFIG_FW_LOADER=y
 # CONFIG_DEBUG_DRIVER is not set
+# CONFIG_SYS_HYPERVISOR is not set
 
 #
 # Connector - unified userspace <-> kernelspace linker
@@ -335,6 +378,7 @@ # CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=y
 CONFIG_BLK_DEV_RAM_COUNT
 CONFIG_BLK_DEV_RAM_SIZE@96
+CONFIG_BLK_DEV_RAM_BLOCKSIZE24
 CONFIG_BLK_DEV_INITRD=y
 # CONFIG_CDROM_PKTCDVD is not set
 CONFIG_ATA_OVER_ETH=m
@@ -381,6 +425,7 @@ # CONFIG_BLK_DEV_CS5520 is not set
 # CONFIG_BLK_DEV_CS5530 is not set
 # CONFIG_BLK_DEV_HPT34X is not set
 # CONFIG_BLK_DEV_HPT366 is not set
+# CONFIG_BLK_DEV_JMICRON is not set
 # CONFIG_BLK_DEV_SC1200 is not set
 # CONFIG_BLK_DEV_PIIX is not set
 # CONFIG_BLK_DEV_IT821X is not set
@@ -404,6 +449,7 @@ # SCSI device support
 #
 # CONFIG_RAID_ATTRS is not set
 CONFIG_SCSI=y
+CONFIG_SCSI_NETLINK=y
 CONFIG_SCSI_PROC_FS=y
 
 #
@@ -425,12 +471,14 @@ CONFIG_SCSI_CONSTANTS=y
 # CONFIG_SCSI_LOGGING is not set
 
 #
-# SCSI Transport Attributes
+# SCSI Transports
 #
 CONFIG_SCSI_SPI_ATTRS=y
 CONFIG_SCSI_FC_ATTRS=y
 CONFIG_SCSI_ISCSI_ATTRS=m
 CONFIG_SCSI_SAS_ATTRS=y
+CONFIG_SCSI_SAS_LIBSAS=y
+# CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
 
 #
 # SCSI low-level drivers
@@ -443,46 +491,82 @@ # CONFIG_SCSI_AACRAID is not set
 # CONFIG_SCSI_AIC7XXX is not set
 # CONFIG_SCSI_AIC7XXX_OLD is not set
 # CONFIG_SCSI_AIC79XX is not set
+# CONFIG_SCSI_AIC94XX is not set
+# CONFIG_SCSI_ARCMSR is not set
 # CONFIG_MEGARAID_NEWGEN is not set
 # CONFIG_MEGARAID_LEGACY is not set
 # CONFIG_MEGARAID_SAS is not set
-CONFIG_SCSI_SATA=y
-# CONFIG_SCSI_SATA_AHCI is not set
-# CONFIG_SCSI_SATA_SVW is not set
-# CONFIG_SCSI_ATA_PIIX is not set
-# CONFIG_SCSI_SATA_MV is not set
-# CONFIG_SCSI_SATA_NV is not set
-# CONFIG_SCSI_PDC_ADMA is not set
-# CONFIG_SCSI_SATA_QSTOR is not set
-# CONFIG_SCSI_SATA_PROMISE is not set
-# CONFIG_SCSI_SATA_SX4 is not set
-# CONFIG_SCSI_SATA_SIL is not set
-# CONFIG_SCSI_SATA_SIL24 is not set
-# CONFIG_SCSI_SATA_SIS is not set
-# CONFIG_SCSI_SATA_ULI is not set
-# CONFIG_SCSI_SATA_VIA is not set
-CONFIG_SCSI_SATA_VITESSE=y
+# CONFIG_SCSI_HPTIOP is not set
 # CONFIG_SCSI_DMX3191D is not set
 # CONFIG_SCSI_FUTURE_DOMAIN is not set
 # CONFIG_SCSI_IPS is not set
 # CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
+# CONFIG_SCSI_STEX is not set
 # CONFIG_SCSI_SYM53C8XX_2 is not set
 # CONFIG_SCSI_IPR is not set
 CONFIG_SCSI_QLOGIC_1280=y
 CONFIG_SCSI_QLA_FC=y
-CONFIG_SCSI_QLA2XXX_EMBEDDED_FIRMWARE=y
-# CONFIG_SCSI_QLA21XX is not set
-CONFIG_SCSI_QLA22XX=y
-CONFIG_SCSI_QLA2300=y
-CONFIG_SCSI_QLA2322=y
-# CONFIG_SCSI_QLA24XX is not set
+# CONFIG_SCSI_QLA_ISCSI is not set
 # CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
 # CONFIG_SCSI_DEBUG is not set
 
 #
+# Serial ATA (prod) and Parallel ATA (experimental) drivers
+#
+CONFIG_ATA=y
+# CONFIG_SATA_AHCI is not set
+# CONFIG_SATA_SVW is not set
+# CONFIG_ATA_PIIX is not set
+# CONFIG_SATA_MV is not set
+# CONFIG_SATA_NV is not set
+# CONFIG_PDC_ADMA is not set
+# CONFIG_SATA_QSTOR is not set
+# CONFIG_SATA_PROMISE is not set
+# CONFIG_SATA_SX4 is not set
+# CONFIG_SATA_SIL is not set
+# CONFIG_SATA_SIL24 is not set
+# CONFIG_SATA_SIS is not set
+# CONFIG_SATA_ULI is not set
+# CONFIG_SATA_VIA is not set
+CONFIG_SATA_VITESSE=y
+# CONFIG_PATA_ALI is not set
+# CONFIG_PATA_AMD is not set
+# CONFIG_PATA_ARTOP is not set
+# CONFIG_PATA_ATIIXP is not set
+# CONFIG_PATA_CMD64X is not set
+# CONFIG_PATA_CS5520 is not set
+# CONFIG_PATA_CS5530 is not set
+# CONFIG_PATA_CYPRESS is not set
+# CONFIG_PATA_EFAR is not set
+# CONFIG_ATA_GENERIC is not set
+# CONFIG_PATA_HPT366 is not set
+# CONFIG_PATA_HPT37X is not set
+# CONFIG_PATA_HPT3X2N is not set
+# CONFIG_PATA_HPT3X3 is not set
+# CONFIG_PATA_IT821X is not set
+# CONFIG_PATA_JMICRON is not set
+# CONFIG_PATA_TRIFLEX is not set
+# CONFIG_PATA_MPIIX is not set
+# CONFIG_PATA_OLDPIIX is not set
+# CONFIG_PATA_NETCELL is not set
+# CONFIG_PATA_NS87410 is not set
+# CONFIG_PATA_OPTI is not set
+# CONFIG_PATA_OPTIDMA is not set
+# CONFIG_PATA_PDC_OLD is not set
+# CONFIG_PATA_RADISYS is not set
+# CONFIG_PATA_RZ1000 is not set
+# CONFIG_PATA_SC1200 is not set
+# CONFIG_PATA_SERVERWORKS is not set
+# CONFIG_PATA_PDC2027X is not set
+# CONFIG_PATA_SIL680 is not set
+# CONFIG_PATA_SIS is not set
+# CONFIG_PATA_VIA is not set
+# CONFIG_PATA_WINBOND is not set
+
+#
 # Multi-device support (RAID and LVM)
 #
 CONFIG_MD=y
@@ -491,12 +575,12 @@ CONFIG_MD_LINEAR=y
 CONFIG_MD_RAID0=y
 CONFIG_MD_RAID1=y
 # CONFIG_MD_RAID10 is not set
-CONFIG_MD_RAID5=y
+CONFIG_MD_RAID456=y
 # CONFIG_MD_RAID5_RESHAPE is not set
-# CONFIG_MD_RAID6 is not set
 CONFIG_MD_MULTIPATH=y
 # CONFIG_MD_FAULTY is not set
 CONFIG_BLK_DEV_DM=y
+# CONFIG_DM_DEBUG is not set
 CONFIG_DM_CRYPT=m
 CONFIG_DM_SNAPSHOT=m
 CONFIG_DM_MIRROR=m
@@ -563,6 +647,7 @@ # CONFIG_SKY2 is not set
 # CONFIG_SK98LIN is not set
 CONFIG_TIGON3=y
 # CONFIG_BNX2 is not set
+# CONFIG_QLA3XXX is not set
 
 #
 # Ethernet (10000 Mbit)
@@ -571,6 +656,7 @@ CONFIG_CHELSIO_T1=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
 # CONFIG_S2IO_NAPI is not set
+# CONFIG_MYRI10GE is not set
 
 #
 # Token Ring devices
@@ -612,6 +698,7 @@ #
 # Input device support
 #
 CONFIG_INPUT=y
+# CONFIG_INPUT_FF_MEMLESS is not set
 
 #
 # Userland interfaces
@@ -646,6 +733,7 @@ #
 CONFIG_VT=y
 CONFIG_VT_CONSOLE=y
 CONFIG_HW_CONSOLE=y
+# CONFIG_VT_HW_CONSOLE_BINDING is not set
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_COMPUTONE is not set
 # CONFIG_ROCKETPORT is not set
@@ -659,10 +747,12 @@ # CONFIG_SYNCLINK_GT is not set
 # CONFIG_N_HDLC is not set
 # CONFIG_SPECIALIX is not set
 # CONFIG_SX is not set
+# CONFIG_RIO is not set
 # CONFIG_STALDRV is not set
 CONFIG_SGI_SNSC=y
 CONFIG_SGI_TIOCX=y
 CONFIG_SGI_MBCS=m
+CONFIG_MSPEC=y
 
 #
 # Serial drivers
@@ -701,6 +791,7 @@ #
 # Ftape, the floppy tape device driver
 #
 CONFIG_AGP=y
+# CONFIG_AGP_SIS is not set
 # CONFIG_AGP_VIA is not set
 CONFIG_AGP_SGI_TIOCA=y
 # CONFIG_DRM is not set
@@ -730,7 +821,6 @@ # CONFIG_SPI_MASTER is not set
 #
 # Dallas's 1-wire bus
 #
-# CONFIG_W1 is not set
 
 #
 # Hardware Monitoring support
@@ -741,6 +831,7 @@ # CONFIG_HWMON_VID is not set
 #
 # Misc devices
 #
+# CONFIG_TIFM_CORE is not set
 
 #
 # Multimedia devices
@@ -756,6 +847,7 @@ # CONFIG_USB_DABUSB is not set
 #
 # Graphics support
 #
+CONFIG_FIRMWARE_EDID=y
 # CONFIG_FB is not set
 
 #
@@ -764,6 +856,7 @@ #
 CONFIG_VGA_CONSOLE=y
 # CONFIG_VGACON_SOFT_SCROLLBACK is not set
 CONFIG_DUMMY_CONSOLE=y
+# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
 
 #
 # Sound
@@ -794,6 +887,7 @@ #
 CONFIG_USB_EHCI_HCD=m
 # CONFIG_USB_EHCI_SPLIT_ISO is not set
 # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
+# CONFIG_USB_EHCI_TT_NEWSCHED is not set
 # CONFIG_USB_ISP116X_HCD is not set
 CONFIG_USB_OHCI_HCD=m
 # CONFIG_USB_OHCI_BIG_ENDIAN is not set
@@ -843,6 +937,7 @@ # CONFIG_USB_ATI_REMOTE is not set
 # CONFIG_USB_ATI_REMOTE2 is not set
 # CONFIG_USB_KEYSPAN_REMOTE is not set
 # CONFIG_USB_APPLETOUCH is not set
+# CONFIG_USB_TRANCEVIBRATOR is not set
 
 #
 # USB Imaging devices
@@ -874,15 +969,18 @@ # USB Miscellaneous drivers
 #
 # CONFIG_USB_EMI62 is not set
 # CONFIG_USB_EMI26 is not set
+# CONFIG_USB_ADUTUX is not set
 # CONFIG_USB_AUERSWALD is not set
 # CONFIG_USB_RIO500 is not set
 # CONFIG_USB_LEGOTOWER is not set
 # CONFIG_USB_LCD is not set
 # CONFIG_USB_LED is not set
+# CONFIG_USB_CYPRESS_CY7C63 is not set
 # CONFIG_USB_CYTHERM is not set
-# CONFIG_USB_PHIDGETKIT is not set
-# CONFIG_USB_PHIDGETSERVO is not set
+# CONFIG_USB_PHIDGET is not set
 # CONFIG_USB_IDMOUSE is not set
+# CONFIG_USB_FTDI_ELAN is not set
+# CONFIG_USB_APPLEDISPLAY is not set
 # CONFIG_USB_SISUSBVGA is not set
 # CONFIG_USB_LD is not set
 
@@ -919,18 +1017,15 @@ #
 CONFIG_INFINIBAND=m
 # CONFIG_INFINIBAND_USER_MAD is not set
 CONFIG_INFINIBAND_USER_ACCESS=m
+CONFIG_INFINIBAND_ADDR_TRANS=y
 CONFIG_INFINIBAND_MTHCA=m
 CONFIG_INFINIBAND_MTHCA_DEBUG=y
+# CONFIG_INFINIBAND_AMSO1100 is not set
 CONFIG_INFINIBAND_IPOIB=m
 CONFIG_INFINIBAND_IPOIB_DEBUG=y
 # CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
 CONFIG_INFINIBAND_SRP=m
-
-#
-# SN Devices
-#
-CONFIG_SGI_IOC4=y
-CONFIG_SGI_IOC3=y
+# CONFIG_INFINIBAND_ISER is not set
 
 #
 # EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
@@ -942,6 +1037,19 @@ #
 # CONFIG_RTC_CLASS is not set
 
 #
+# DMA Engine support
+#
+# CONFIG_DMA_ENGINE is not set
+
+#
+# DMA Clients
+#
+
+#
+# DMA Devices
+#
+
+#
 # File systems
 #
 CONFIG_EXT2_FS=y
@@ -965,15 +1073,16 @@ CONFIG_REISERFS_FS_SECURITY=y
 # CONFIG_JFS_FS is not set
 CONFIG_FS_POSIX_ACL=y
 CONFIG_XFS_FS=y
-CONFIG_XFS_EXPORT=y
 CONFIG_XFS_QUOTA=y
 # CONFIG_XFS_SECURITY is not set
 CONFIG_XFS_POSIX_ACL=y
 CONFIG_XFS_RT=y
+# CONFIG_GFS2_FS is not set
 # CONFIG_OCFS2_FS is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
 CONFIG_INOTIFY=y
+CONFIG_INOTIFY_USER=y
 CONFIG_QUOTA=y
 # CONFIG_QFMT_V1 is not set
 # CONFIG_QFMT_V2 is not set
@@ -1007,8 +1116,10 @@ # Pseudo filesystems
 #
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
+CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
+# CONFIG_TMPFS_POSIX_ACL is not set
 CONFIG_HUGETLBFS=y
 CONFIG_HUGETLB_PAGE=y
 CONFIG_RAMFS=y
@@ -1046,7 +1157,7 @@ CONFIG_NFSD_V4=y
 CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=m
 CONFIG_LOCKD_V4=y
-CONFIG_EXPORTFS=y
+CONFIG_EXPORTFS=m
 CONFIG_NFS_COMMON=y
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
@@ -1056,7 +1167,9 @@ CONFIG_SMB_FS=m
 # CONFIG_SMB_NLS_DEFAULT is not set
 CONFIG_CIFS=m
 # CONFIG_CIFS_STATS is not set
+# CONFIG_CIFS_WEAK_PW_HASH is not set
 # CONFIG_CIFS_XATTR is not set
+# CONFIG_CIFS_DEBUG2 is not set
 # CONFIG_CIFS_EXPERIMENTAL is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
@@ -1129,6 +1242,10 @@ # CONFIG_NLS_KOI8_U is not set
 CONFIG_NLS_UTF8=y
 
 #
+# Distributed Lock Manager
+#
+
+#
 # Library routines
 #
 # CONFIG_CRC_CCITT is not set
@@ -1138,9 +1255,11 @@ CONFIG_LIBCRC32C=m
 CONFIG_ZLIB_INFLATE=m
 CONFIG_ZLIB_DEFLATE=m
 CONFIG_GENERIC_ALLOCATOR=y
+CONFIG_PLIST=y
 CONFIG_GENERIC_HARDIRQS=y
 CONFIG_GENERIC_IRQ_PROBE=y
 CONFIG_GENERIC_PENDING_IRQ=y
+CONFIG_IRQ_PER_CPU=y
 
 #
 # Instrumentation Support
@@ -1152,20 +1271,26 @@ #
 # Kernel hacking
 #
 # CONFIG_PRINTK_TIME is not set
+CONFIG_ENABLE_MUST_CHECK=y
 CONFIG_MAGIC_SYSRQ=y
+# CONFIG_UNUSED_SYMBOLS is not set
 CONFIG_DEBUG_KERNEL=y
 CONFIG_LOG_BUF_SHIFT 
 CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
-CONFIG_DEBUG_PREEMPT=y
-# CONFIG_DEBUG_MUTEXES is not set
+# CONFIG_DEBUG_RT_MUTEXES is not set
+# CONFIG_RT_MUTEX_TESTER is not set
 # CONFIG_DEBUG_SPINLOCK is not set
+# CONFIG_DEBUG_MUTEXES is not set
+# CONFIG_DEBUG_RWSEMS is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
 # CONFIG_DEBUG_KOBJECT is not set
 CONFIG_DEBUG_INFO=y
 # CONFIG_DEBUG_FS is not set
 # CONFIG_DEBUG_VM is not set
+# CONFIG_DEBUG_LIST is not set
 CONFIG_FORCED_INLINING=y
 # CONFIG_RCU_TORTURE_TEST is not set
 CONFIG_IA64_GRANULE_16MB=y
@@ -1186,6 +1311,10 @@ #
 # Cryptographic options
 #
 CONFIG_CRYPTO=y
+CONFIG_CRYPTO_ALGAPI=y
+CONFIG_CRYPTO_BLKCIPHER=m
+CONFIG_CRYPTO_HASH=y
+CONFIG_CRYPTO_MANAGER=m
 CONFIG_CRYPTO_HMAC=y
 # CONFIG_CRYPTO_NULL is not set
 # CONFIG_CRYPTO_MD4 is not set
@@ -1195,6 +1324,8 @@ # CONFIG_CRYPTO_SHA256 is not set
 # CONFIG_CRYPTO_SHA512 is not set
 # CONFIG_CRYPTO_WP512 is not set
 # CONFIG_CRYPTO_TGR192 is not set
+CONFIG_CRYPTO_ECB=m
+CONFIG_CRYPTO_CBC=m
 CONFIG_CRYPTO_DES=m
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set

commit 4d5a31977cc69be8786e0033d5c148e5c62ae949
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Thu Oct 12 16:21:17 2006 -0600

    [IA64] reformat pal.S to fit in 80 columns, fix typos
    
    Reformat to fit in 80 columns.  Fix a couple typos.  Remove
    a couple unused labels.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index 5f50e6b..0b53344 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -21,11 +21,12 @@ pal_entry_point:
 	.text
 
 /*
- * Set the PAL entry point address.  This could be written in C code, but we do it here
- * to keep it all in one module (besides, it's so trivial that it's
+ * Set the PAL entry point address.  This could be written in C code, but we
+ * do it here to keep it all in one module (besides, it's so trivial that it's
  * not a big deal).
  *
- * in0		Address of the PAL entry point (text address, NOT a function descriptor).
+ * in0		Address of the PAL entry point (text address, NOT a function
+ *		descriptor).
  */
 GLOBAL_ENTRY(ia64_pal_handler_init)
 	alloc r3=ar.pfs,1,0,0,0
@@ -36,9 +37,9 @@ GLOBAL_ENTRY(ia64_pal_handler_init)
 END(ia64_pal_handler_init)
 
 /*
- * Default PAL call handler.  This needs to be coded in assembly because it uses
- * the static calling convention, i.e., the RSE may not be used and calls are
- * done via "br.cond" (not "br.call").
+ * Default PAL call handler.  This needs to be coded in assembly because it
+ * uses the static calling convention, i.e., the RSE may not be used and
+ * calls are done via "br.cond" (not "br.call").
  */
 GLOBAL_ENTRY(ia64_pal_default_handler)
 	mov r8=-1
@@ -91,8 +92,8 @@ END(ia64_pal_call_static)
  * Make a PAL call using the stacked registers calling convention.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
@@ -126,18 +127,18 @@ END(ia64_pal_call_stacked)
  * Make a physical mode PAL call using the static registers calling convention.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  *
  * PSR_LP, PSR_TB, PSR_ID, PSR_DA are never set by the kernel.
  * So we don't need to clear them.
  */
-#define PAL_PSR_BITS_TO_CLEAR							\
-	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT  | IA64_PSR_DB | IA64_PSR_RT |	\
-	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |		\
+#define PAL_PSR_BITS_TO_CLEAR						      \
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT  | IA64_PSR_DB | IA64_PSR_RT |\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	      \
 	 IA64_PSR_DFL | IA64_PSR_DFH)
 
-#define PAL_PSR_BITS_TO_SET							\
+#define PAL_PSR_BITS_TO_SET						      \
 	(IA64_PSR_BN)
 
 
@@ -173,7 +174,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_static)
 	;;
 	andcm r16=loc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=ia64_switch_mode_phys
-.ret1:	mov rp = r8			// install return address (physical)
+	mov rp = r8			// install return address (physical)
 	mov loc5 = r19
 	mov loc6 = r20
 	br.cond.sptk.many b7
@@ -183,7 +184,6 @@ GLOBAL_ENTRY(ia64_pal_call_phys_static)
 	mov r19=loc5
 	mov r20=loc6
 	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
-.ret2:
 	mov psr.l = loc3		// restore init PSR
 
 	mov ar.pfs = loc1
@@ -198,8 +198,8 @@ END(ia64_pal_call_phys_static)
  * Make a PAL call using the stacked registers in physical mode.
  *
  * Inputs:
- * 	in0         Index of PAL service
- * 	in2 - in3   Remaning PAL arguments
+ *	in0         Index of PAL service
+ *	in2 - in3   Remaining PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
@@ -207,7 +207,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	movl	loc2 = pal_entry_point
 1:	{
 	  mov r28  = in0		// copy procedure index
-	  mov loc0 = rp		// save rp
+	  mov loc0 = rp			// save rp
 	}
 	.body
 	;;
@@ -240,7 +240,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	mov r16=loc3			// r16= original psr
 	mov r19=loc5
 	mov r20=loc6
-	br.call.sptk.many rp=ia64_switch_mode_virt	// return to virtual mode
+	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
 
 	mov psr.l  = loc3		// restore init PSR
 	mov ar.pfs = loc1
@@ -252,10 +252,11 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 END(ia64_pal_call_phys_stacked)
 
 /*
- * Save scratch fp scratch regs which aren't saved in pt_regs already (fp10-fp15).
+ * Save scratch fp scratch regs which aren't saved in pt_regs already
+ * (fp10-fp15).
  *
- * NOTE: We need to do this since firmware (SAL and PAL) may use any of the scratch
- * regs fp-low partition.
+ * NOTE: We need to do this since firmware (SAL and PAL) may use any of the
+ * scratch regs fp-low partition.
  *
  * Inputs:
  *      in0	Address of stack storage for fp regs

commit c12fb1885787dcc2e20c4b88149e1e607e1293b2
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Thu Oct 12 16:20:59 2006 -0600

    [IA64] remove unused PAL_CALL_IC_OFF
    
    Linux maps PAL instructions with an ITR, but uses a DTC for PAL data.
    Section 11.10.2.1.3, "Making PAL Procedures Calls in Physical or Virtual
    Mode," of the SDM (rev 2.2), says we must therefore make all PAL calls
    with PSR.ic = 1 so that Linux can handle any TLB faults.
    
    PAL_CALL_IC_OFF is currently unused, and as long as we use the ITR + DTC
    strategy, we can't use it.  So remove it.  I also removed the code in
    ia64_pal_call_static() that conditionally cleared PSR.ic.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index ebaf1e6..5f50e6b 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -50,12 +50,10 @@ END(ia64_pal_default_handler)
  *
  * in0         Index of PAL service
  * in1 - in3   Remaining PAL arguments
- * in4	       1 => clear psr.ic,  0 => don't clear psr.ic
- *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
-	alloc loc1 = ar.pfs,5,5,0,0
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
+	alloc loc1 = ar.pfs,4,5,0,0
 	movl loc2 = pal_entry_point
 1:	{
 	  mov r28 = in0
@@ -64,7 +62,6 @@ GLOBAL_ENTRY(ia64_pal_call_static)
 	}
 	;;
 	ld8 loc2 = [loc2]		// loc2 <- entry point
-	tbit.nz p6,p7 = in4, 0
 	adds r8 = 1f-1b,r8
 	mov loc4=ar.rsc			// save RSE configuration
 	;;
@@ -74,13 +71,11 @@ GLOBAL_ENTRY(ia64_pal_call_static)
 	.body
 	mov r30 = in2
 
-(p6)	rsm psr.i | psr.ic
 	mov r31 = in3
 	mov b7 = loc2
 
-(p7)	rsm psr.i
+	rsm psr.i
 	;;
-(p6)	srlz.i
 	mov rp = r8
 	br.cond.sptk.many b7
 1:	mov psr.l = loc3
diff --git a/include/asm-ia64/pal.h b/include/asm-ia64/pal.h
index 2c8fd92..4283ddc 100644
--- a/include/asm-ia64/pal.h
+++ b/include/asm-ia64/pal.h
@@ -764,7 +764,7 @@ struct ia64_pal_retval {
  * (generally 0) MUST be passed.  Reserved parameters are not optional
  * parameters.
  */
-extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64, u64);
+extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u64);
 extern struct ia64_pal_retval ia64_pal_call_phys_stacked (u64, u64, u64, u64);
@@ -774,14 +774,7 @@ extern void ia64_load_scratch_fpregs (st
 #define PAL_CALL(iprv,a0,a1,a2,a3) do {			\
 	struct ia64_fpreg fr[6];			\
 	ia64_save_scratch_fpregs(fr);			\
-	iprv = ia64_pal_call_static(a0, a1, a2, a3, 0);	\
-	ia64_load_scratch_fpregs(fr);			\
-} while (0)
-
-#define PAL_CALL_IC_OFF(iprv,a0,a1,a2,a3) do {		\
-	struct ia64_fpreg fr[6];			\
-	ia64_save_scratch_fpregs(fr);			\
-	iprv = ia64_pal_call_static(a0, a1, a2, a3, 1);	\
+	iprv = ia64_pal_call_static(a0, a1, a2, a3);	\
 	ia64_load_scratch_fpregs(fr);			\
 } while (0)
 

commit accaddb27a2d544e38e10ff2a2782b33bbbad913
Author: Jack Steiner <steiner@sgi.com>
Date:   Mon Oct 16 12:56:54 2006 -0500

    [IA64] - Allow IPIs in timer loop
    
    Allow pending IPIs to interrupt a timer interrupt that is looping
    in the do_timer() "while" loop in timer_interrupt(). (Interrupts are
    allowed at only 1 spot in the code).
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 41169a9..39e0cd3 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -84,6 +84,12 @@ timer_interrupt (int irq, void *dev_id)
 
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
+
+		/*
+		 * Allow IPIs to interrupt the timer loop.
+		 */
+		local_irq_enable();
+		local_irq_disable();
 	}
 
 	do {

commit ffc45571dfb4b70e7eda8d97f64a05f5e5a992ac
Author: Aron Griffis <aron@hp.com>
Date:   Tue Oct 17 00:28:15 2006 -0400

    [IA64] move ioremap/ioremap_nocache under __KERNEL__
    
    I noticed these are declared extern outside of __KERNEL__, but surely
    they wouldn't be available to userland since they're defined in
    ioremap.c.  Am I missing something here?
    
    If I'm right about this, then there's probably a good deal of other
    stuff in io.h that could move inside __KERNEL__, but at least this is
    a start.
    
    Signed-off-by: Aron Griffis <aron@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/io.h b/include/asm-ia64/io.h
index 43bfff6..855c30a 100644
--- a/include/asm-ia64/io.h
+++ b/include/asm-ia64/io.h
@@ -417,6 +417,8 @@ #ifndef outl_p
 # define outl_p		outl
 #endif
 
+# ifdef __KERNEL__
+
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
 
@@ -430,8 +432,6 @@ #define dmi_ioremap ioremap
 #define dmi_iounmap(x,l) iounmap(x)
 #define dmi_alloc(l) kmalloc(l, GFP_ATOMIC)
 
-# ifdef __KERNEL__
-
 /*
  * String version of IO memory access ops:
  */

commit 3bbe486b361b317ac7103378ed3d1aab4779715e
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Oct 17 14:28:16 2006 -0700

    [IA64] perfmon fix for global IRQ fix
    
    Missed one piece of ia64 fallout from the global IRQ patch
     7d12e780e003f93433d49ce78cfedf4b4c52adc5
    
    Perfmon interrupt handler needs to use get_irq_regs() too.
    
    Acked-by: stephane eranian <eranian@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 281004f..3aaede0 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -5558,12 +5558,13 @@ report_spurious2:
 }
 
 static irqreturn_t
-pfm_interrupt_handler(int irq, void *arg, struct pt_regs *regs)
+pfm_interrupt_handler(int irq, void *arg)
 {
 	unsigned long start_cycles, total_cycles;
 	unsigned long min, max;
 	int this_cpu;
 	int ret;
+	struct pt_regs *regs = get_irq_regs();
 
 	this_cpu = get_cpu();
 	if (likely(!pfm_alt_intr_handler)) {
