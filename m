From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 Jan 2003 01:00:06 +0000
Subject: fusion driver (was: [Linux-ia64] kernel update (relative to 2.5.52))
Message-Id: <marc-linux-ia64-105590709805635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 21 Dec 2002 01:00:09 -0800, David Mosberger <davidm@linux.hpl=
.hp.com> said:

  David> Hoewever, the MPT Fusion SCSI driver broke pretty badly in
  David> 2.5.50: it just freezes the machine while it's probing for
  David> SCSI devices.  Someone who actually knows something about
  David> this driver needs to take a good look at this.

The attached patch is part of 2.5.54 and applies cleanly on top of
2.5.52.  Better still, it makes the fusion driver work again.

Enjoy,

	--david

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.930.1.2 -> 1.930.1.3
#	drivers/message/fusion/mptctl.c	1.10    -> 1.11  =20
#	drivers/message/fusion/mptbase.h	1.7     -> 1.8   =20
#	drivers/message/fusion/mptbase.c	1.7     -> 1.8   =20
#	drivers/message/fusion/linux_compat.h	1.6     -> 1.7   =20
#	drivers/message/fusion/mptscsih.c	1.15    -> 1.16  =20
#	drivers/message/fusion/mptctl.h	1.3     -> 1.4   =20
#	drivers/message/fusion/mptscsih.h	1.13    -> 1.14  =20
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.13
# [ARM] Allow arch/arm/kernel/asm-offsets.s to be regenerated
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.14
# [ARM] Convert semaphore initialisers to C99 syntax.
#=20
# The semaphore initialisers were using the old gcc syntax.  Add
# sema_count() implementation for the sa11x0 audio implementation.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.15
# [ARM] IOP310 build fixes
#=20
# Add <asm/arch/iop310.h> include, needed for platform implementation of
# architecture private __virt_to_bus / __bus_to_virt.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.16
# [ARM] Allow arch/arm/kernel/bios32.c to build for iop310
#=20
# bios32.c uses outb(), and therefore should have asm/io.h included.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.17
# [ARM] Make jornada720 build again
#=20
# - Add missing include files.
# - Fail to set pcmcia socket state for invalid socket numbers.
# - Fix locla_ typo.
# - Make pcmcia_jornada720_exit __devexit, not __exit.
# - Don't initialise jornada720 machine specifics if not running
#   on jornada720.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.18
# [ARM] Minor fixes to drivers/pcmcia/sa1111_generic.c.
#=20
# Only set IRQ type after a successful request_irq().
# Driver now known as sa1111-pcmcia in driverfs.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.19
# [ARM] Fix ups for ARM generic dma mapping interface
#=20
# This brings the ARM dma mapping functionality into line with
# the current generic interface, allowing any struct device to
# be passed into the dma_* functions.
#=20
# Further cleanups will be possible when the USB layer is
# converted to use the dma_* API.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.20
# [ARM] Sanitise sa1111 and neponset device driver names.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.21
# [ARM] Update mach-types
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.22
# [ARM] Add basic support for enable/disable_irq_wake.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.23
# [ARM] Add support for IRQ-based wakeup for SA11x0 CPUs
#=20
# This patch adds support for enable/disable_irq_wake for the SA11x0
# CPUs, allowing drivers or other code to select which IRQs are able
# to wake the CPU from sleep mode.
# --------------------------------------------
# 03/01/01	rmk@flint.arm.linux.org.uk	1.911.26.24
# [ARM] Add IRQ wake support for SA1111 PS/2 interfaces.
# --------------------------------------------
# 03/01/01	pdelaney@lsil.com	1.930.1.3
# [PATCH] Fusion-MPT Update (2.03.01.01)
#=20
# This upgrades the Fusion-MPT driver from 2.03.00.02 to 2.03.01.01.
#=20
# Bug Fixes:
#  o Added back missing queuecommand entry point define ?!
#  o Added to code to break marriage of two controllers during unload
#   (could cause a panic)
#  o SCSI driver will de-register with base driver if no SCSI-capable
#    adapters found
#=20
# Minor Changes:
#  o Removed errant spaces at ends of lines  (most of the changes)
#  o Moved code around (and in-lined) some functions for performance reason=
s.
#  o Modified /proc functionality to facilitate testing with 2.5
#  o Added a call to synchronize_irq on unload (HP request)
#  o Modified load of base to close a potential hole
#  o Added code to set the FW IO coalescing depth (IBM request)
#  o Changed return when mptctl driver registration fails (Kernel.org reque=
st)
#  o SCSI driver detect routine calls a generic spinlock for all kernels
#    (Kernel.org request)
#  o Controller RAID page dynamic instead of static
#=20
# Currently running a multi-disk stress test w/ 2.5.53,  this patch and dri=
ver
# built-in. Verified basic reset handling is working properly.
# --------------------------------------------
#
diff -Nru a/drivers/message/fusion/linux_compat.h b/drivers/message/fusion/=
linux_compat.h
--- a/drivers/message/fusion/linux_compat.h	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/linux_compat.h	Thu Jan  2 15:40:31 2003
@@ -246,41 +246,30 @@
 #endif
=20
 /*
- *  We use our new error handling code if the kernel version is 2.5.1 or n=
ewer.
+ *  We use our new error handling code if the kernel version is 2.4.18 or =
newer.
  */
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,1)
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,4,18)
         #define MPT_SCSI_USE_NEW_EH
 #endif
=20
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,28)
-#define mptscsih_lock(iocp, flags) \
-                spin_lock_irqsave(&iocp->FreeQlock, flags)
-#else
-#define mptscsih_lock(iocp, flags) \
-({	save_flags(flags); \
-	cli(); \
-})
-#endif
-
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,28)
-#define mptscsih_unlock(iocp, flags) \
-                spin_unlock_irqrestore(&iocp->FreeQlock, flags)
-#else
-#define mptscsih_unlock(iocp, flags)  restore_flags(flags);
-#endif
-
-
 #if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,41)
-#define mpt_work_struct work_struct=20
+#define mpt_work_struct work_struct
 #define MPT_INIT_WORK(_task, _func, _data) INIT_WORK(_task, _func, _data)
 #else
-#define mpt_work_struct tq_struct=20
+#define mpt_work_struct tq_struct
 #define MPT_INIT_WORK(_task, _func, _data) \
 ({	(_task)->sync =3D 0; \
 	(_task)->routine =3D (_func); \
 	(_task)->data =3D (void *) (_data); \
 })
 #endif
+
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,28)
+#define mptscsih_sync_irq(_irq) synchronize_irq(_irq)
+#else
+#define mptscsih_sync_irq(_irq) synchronize_irq()
+#endif
+
=20
=20
 /*}-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
diff -Nru a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptba=
se.c
--- a/drivers/message/fusion/mptbase.c	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptbase.c	Thu Jan  2 15:40:31 2003
@@ -49,7 +49,7 @@
  *  (mailto:sjralston1@netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptbase.c,v 1.123 2002/10/17 20:15:56 pdelaney Exp $
+ *  $Id: mptbase.c,v 1.125 2002/12/03 21:26:32 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -208,6 +208,7 @@
 static int	mpt_GetScsiPortSettings(MPT_ADAPTER *ioc, int portnum);
 static int	mpt_readScsiDevicePageHeaders(MPT_ADAPTER *ioc, int portnum);
 static int	mpt_findImVolumes(MPT_ADAPTER *ioc);
+static void 	mpt_read_ioc_pg_1(MPT_ADAPTER *ioc);
 static void	mpt_timer_expired(unsigned long data);
 static int	SendEventNotification(MPT_ADAPTER *ioc, u8 EvSwitch);
 static int	SendEventAck(MPT_ADAPTER *ioc, EventNotificationReply_t *evnp);
@@ -443,7 +444,7 @@
 			 */
 			if ((mf) && ((mf >=3D MPT_INDEX_2_MFPTR(ioc, ioc->req_depth))
 				|| (mf < ioc->req_frames)) ) {
-				printk(MYIOC_s_WARN_FMT=20
+				printk(MYIOC_s_WARN_FMT
 					"mpt_interrupt: Invalid mf (%p) req_idx (%d)!\n", ioc->name, (void *)=
mf, req_idx);
 				cb_idx =3D 0;
 				pa =3D 0;
@@ -451,14 +452,14 @@
 			}
 			if ((pa) && (mr) && ((mr >=3D MPT_INDEX_2_RFPTR(ioc, ioc->req_depth))
 				|| (mr < ioc->reply_frames)) ) {
-				printk(MYIOC_s_WARN_FMT=20
+				printk(MYIOC_s_WARN_FMT
 					"mpt_interrupt: Invalid rf (%p)!\n", ioc->name, (void *)mr);
 				cb_idx =3D 0;
 				pa =3D 0;
 				freeme =3D 0;
 			}
 			if (cb_idx > (MPT_MAX_PROTOCOL_DRIVERS-1)) {
-				printk(MYIOC_s_WARN_FMT=20
+				printk(MYIOC_s_WARN_FMT
 					"mpt_interrupt: Invalid cb_idx (%d)!\n", ioc->name, cb_idx);
 				cb_idx =3D 0;
 				pa =3D 0;
@@ -576,9 +577,11 @@
 		CONFIGPARMS *pCfg;
 		unsigned long flags;
=20
-		dprintk((MYIOC_s_INFO_FMT "config_complete (mf=3D%p,mr=3D%p)\n",
+		dcprintk((MYIOC_s_INFO_FMT "config_complete (mf=3D%p,mr=3D%p)\n",
 				ioc->name, mf, reply));
=20
+		DBG_DUMP_REPLY_FRAME(reply)
+
 		pCfg =3D * ((CONFIGPARMS **)((u8 *) mf + ioc->req_sz - sizeof(void *)));
=20
 		if (pCfg) {
@@ -599,7 +602,7 @@
 				u16		 status;
=20
 				status =3D le16_to_cpu(pReply->IOCStatus) & MPI_IOCSTATUS_MASK;
-				dprintk((KERN_NOTICE "  IOCStatus=3D%04xh, IOCLogInfo=3D%08xh\n",
+				dcprintk((KERN_NOTICE "  IOCStatus=3D%04xh, IOCLogInfo=3D%08xh\n",
 				     status, le32_to_cpu(pReply->IOCLogInfo)));
=20
 				pCfg->status =3D status;
@@ -943,7 +946,7 @@
  *	mpt_add_sge - Place a simple SGE at address pAddr.
  *	@pAddr: virtual address for SGE
  *	@flagslength: SGE flags and data transfer length
- *	@dma_addr: Physical address=20
+ *	@dma_addr: Physical address
  *
  *	This routine places a MPT request frame back on the MPT adapter's
  *	FreeQ.
@@ -973,7 +976,7 @@
  *	@pAddr: virtual address for SGE
  *	@next: nextChainOffset value (u32's)
  *	@length: length of next SGL segment
- *	@dma_addr: Physical address=20
+ *	@dma_addr: Physical address
  *
  *	This routine places a MPT request frame back on the MPT adapter's
  *	FreeQ.
@@ -986,7 +989,7 @@
 		u32 tmp =3D dma_addr & 0xFFFFFFFF;
=20
 		pChain->Length =3D cpu_to_le16(length);
-		pChain->Flags =3D MPI_SGE_FLAGS_CHAIN_ELEMENT | mpt_addr_size();=20
+		pChain->Flags =3D MPI_SGE_FLAGS_CHAIN_ELEMENT | mpt_addr_size();
=20
 		pChain->NextChainOffset =3D next;
=20
@@ -1283,7 +1286,7 @@
 		return r;
=20
 	if (!pci_set_dma_mask(pdev, mask)) {
-		dprintk((KERN_INFO MYNAM=20
+		dprintk((KERN_INFO MYNAM
 			": 64 BIT PCI BUS DMA ADDRESSING SUPPORTED\n"));
 	} else if (pci_set_dma_mask(pdev, (u64) 0xffffffff)) {
 		printk(KERN_WARNING MYNAM ": 32 BIT PCI BUS DMA ADDRESSING NOT SUPPORTED=
\n");
@@ -1470,6 +1473,12 @@
 	ioc->active =3D 0;
 	CHIPREG_WRITE32(&ioc->chip->IntStatus, 0);
=20
+	/* tack onto tail of our MPT adapter list */
+	Q_ADD_TAIL(&MptAdapters, ioc, MPT_ADAPTER);
+
+	/* Set lookup ptr. */
+	mpt_adapters[ioc->id] =3D ioc;
+
 	ioc->pci_irq =3D -1;
 	if (pdev->irq) {
 		r =3D request_irq(pdev->irq, mpt_interrupt, SA_SHIRQ, ioc->name, ioc);
@@ -1482,6 +1491,8 @@
 			printk(MYIOC_s_ERR_FMT "Unable to allocate interrupt %s!\n",
 					ioc->name, __irq_itoa(pdev->irq));
 #endif
+			Q_DEL_ITEM(ioc);
+			mpt_adapters[ioc->id] =3D NULL;
 			iounmap(mem);
 			kfree(ioc);
 			return -EBUSY;
@@ -1498,16 +1509,10 @@
 #endif
 	}
=20
-	/* tack onto tail of our MPT adapter list */
-	Q_ADD_TAIL(&MptAdapters, ioc, MPT_ADAPTER);
-
-	/* Set lookup ptr. */
-	mpt_adapters[ioc->id] =3D ioc;
-
 	/* NEW!  20010220 -sralston
 	 * Check for "bound ports" (929, 929X, 1030, 1035) to reduce redundant re=
sets.
 	 */
-	if ((ioc->chip_type =3D FC929) || (ioc->chip_type =3D C1030)=20
+	if ((ioc->chip_type =3D FC929) || (ioc->chip_type =3D C1030)
 			|| (ioc->chip_type =3D C1035) || (ioc->chip_type =3D FC929X))
 		mpt_detect_bound_ports(ioc, pdev);
=20
@@ -1638,6 +1643,9 @@
 				printk(KERN_WARNING MYNAM ": firmware upload failure!\n");
 			/* Handle the alt IOC too */
 			if ((alt_ioc_ready) && (ioc->alt_ioc->upload_fw)){
+				ddlprintk((MYIOC_s_INFO_FMT
+					"Alt-ioc firmware upload required!\n",
+					ioc->name));
 				r =3D mpt_do_upload(ioc->alt_ioc, sleepFlag);
 				if (r !=3D 0)
 					printk(KERN_WARNING MYNAM ": firmware upload failure!\n");
@@ -1706,14 +1714,18 @@
 			 */
 			mpt_GetScsiPortSettings(ioc, 0);
=20
-			/* Get version and length of SDP 1=20
+			/* Get version and length of SDP 1
 			 */
 			mpt_readScsiDevicePageHeaders(ioc, 0);
=20
-			/* Find IM volumes=20
+			/* Find IM volumes
 			 */
 			if (ioc->facts.MsgVersion >=3D 0x0102)
 				mpt_findImVolumes(ioc);
+
+			/* Check, and possibly reset, the coalescing value
+			 */
+			mpt_read_ioc_pg_1(ioc);
 		}
=20
 		GetIoUnitPage2(ioc);
@@ -1819,7 +1831,7 @@
 			ddlprintk((KERN_INFO MYNAM ": Pushing FW onto adapter\n"));
=20
 			if ((state =3D mpt_downloadboot(this, NO_SLEEP)) < 0) {
-				printk(KERN_WARNING MYNAM=20
+				printk(KERN_WARNING MYNAM
 					": firmware downloadboot failure (%d)!\n", state);
 			}
 		}
@@ -1919,6 +1931,11 @@
=20
 		sz_first =3D this->alloc_total;
=20
+		if (this->alt_ioc !=3D NULL) {
+			this->alt_ioc->alt_ioc =3D NULL;
+			this->alt_ioc =3D NULL;
+		}
+
 		mpt_adapter_disable(this, 1);
=20
 		if (this->pci_irq !=3D -1) {
@@ -1998,8 +2015,8 @@
  *
  *	Returns:
  *		 1 - DIAG reset and READY
- *		 0 - READY initially OR soft reset and READY=20
- *		-1 - Any failure on KickStart=20
+ *		 0 - READY initially OR soft reset and READY
+ *		-1 - Any failure on KickStart
  *		-2 - Msg Unit Reset Failed
  *		-3 - IO Unit Reset Failed
  *		-4 - IOC owned by a PEER
@@ -2042,7 +2059,7 @@
 			else
 				statefault =3D 4;
 		}
-	}=20
+	}
=20
 	/*
 	 *	Check to see if IOC is in FAULT state.
@@ -2244,7 +2261,7 @@
 		facts->RequestFrameSize =3D le16_to_cpu(facts->RequestFrameSize);
=20
 		/*
-		 * FC f/w version changed between 1.1 and 1.2=20
+		 * FC f/w version changed between 1.1 and 1.2
 		 *	Old: u16{Major(4),Minor(4),SubMinor(8)}
 		 *	New: u32{Major(8),Minor(8),Unit(8),Dev(8)}
 		 */
@@ -2417,10 +2434,10 @@
 	if (ioc->facts.Flags & MPI_IOCFACTS_FLAGS_FW_DOWNLOAD_BOOT) {
 		if ((ioc->cached_fw) || (ioc->alt_ioc && ioc->alt_ioc->cached_fw))
 			ioc_init.Flags =3D MPI_IOCINIT_FLAGS_DISCARD_FW_IMAGE;
-		else=20
+		else
 			ioc->upload_fw =3D 1;
 	}
-	ddlprintk((MYIOC_s_INFO_FMT "flags %d, upload_fw %d \n",=20
+	ddlprintk((MYIOC_s_INFO_FMT "flags %d, upload_fw %d \n",
 		   ioc->name, ioc_init.Flags, ioc->upload_fw));
=20
 	if ((int)ioc->chip_type <=3D (int)FC929) {
@@ -2554,8 +2571,8 @@
  * Outputs: frags - number of fragments needed
  * Return NULL if failed.
  */
-void *=20
-mpt_alloc_fw_memory(MPT_ADAPTER *ioc, int size, int *frags, int *alloc_sz)=
=20
+void *
+mpt_alloc_fw_memory(MPT_ADAPTER *ioc, int size, int *frags, int *alloc_sz)
 {
 	fw_image_t	**cached_fw =3D NULL;
 	u8		*mem =3D NULL;
@@ -2564,7 +2581,7 @@
 	int		bytes_left, bytes, num_frags;
 	int		sz, ii;
=20
-	/* cached_fw=20
+	/* cached_fw
 	 */
 	sz =3D ioc->num_fw_frags * sizeof(void *);
 	mem =3D kmalloc(sz, GFP_ATOMIC);
@@ -2721,8 +2738,8 @@
 	ioc->num_fw_frags =3D ioc->req_sz - sizeof(FWUpload_t) + sizeof(dma_addr_=
t) + sizeof(u32) -1;
 	ioc->num_fw_frags /=3D sizeof(dma_addr_t) + sizeof(u32);
=20
-	ioc->cached_fw =3D (fw_image_t **) mpt_alloc_fw_memory(ioc,=20
-			ioc->facts.FWImageSize, &num_frags, &alloc_sz);=20
+	ioc->cached_fw =3D (fw_image_t **) mpt_alloc_fw_memory(ioc,
+			ioc->facts.FWImageSize, &num_frags, &alloc_sz);
=20
 	if (ioc->cached_fw =3D NULL) {
 		/* Major Failure.
@@ -2769,8 +2786,8 @@
 		sgeoffset +=3D sizeof(u32) + sizeof(dma_addr_t);
 	}
=20
-	mpt_add_sge(&request[sgeoffset],=20
-			MPT_SGE_FLAGS_SSIMPLE_READ |(u32) ioc->cached_fw[ii]->size,=20
+	mpt_add_sge(&request[sgeoffset],
+			MPT_SGE_FLAGS_SSIMPLE_READ |(u32) ioc->cached_fw[ii]->size,
 			ioc->cached_fw[ii]->fw_dma);
=20
 	sgeoffset +=3D sizeof(u32) + sizeof(dma_addr_t);
@@ -3117,8 +3134,8 @@
  *		 0 - no reset due to History bit, READY=09
  *		-1 - no reset due to History bit but not READY=09
  *		     OR reset but failed to come READY
- *		-2 - no reset, could not enter DIAG mode=20
- *		-3 - reset but bad FW bit=20
+ *		-2 - no reset, could not enter DIAG mode
+ *		-3 - reset but bad FW bit
  */
 static int
 KickStart(MPT_ADAPTER *ioc, int force, int sleepFlag)
@@ -3254,18 +3271,14 @@
 				ioc->name, diag0val, diag1val));
 #endif
 		/* Write the PreventIocBoot bit */
-#if 1
 		if ((ioc->cached_fw) || (ioc->alt_ioc && ioc->alt_ioc->cached_fw)) {
-#else
-		if (ioc->facts.Flags & MPI_IOCFACTS_FLAGS_FW_DOWNLOAD_BOOT) {
-#endif
 			diag0val |=3D MPI_DIAG_PREVENT_IOC_BOOT;
 			CHIPREG_WRITE32(&ioc->chip->Diagnostic, diag0val);
 		}
=20
 		/*
 		 * Disable the ARM (Bug fix)
-		 *=20
+		 *
 		 */
 		CHIPREG_WRITE32(&ioc->chip->Diagnostic, diag0val | MPI_DIAG_DISABLE_ARM);
 		mdelay (1);
@@ -3304,11 +3317,7 @@
 			/* FIXME?  Examine results here? */
 		}
=20
-#if 1
 		if ((ioc->cached_fw) || (ioc->alt_ioc && ioc->alt_ioc->cached_fw)) {
-#else
-		if (ioc->facts.Flags & MPI_IOCFACTS_FLAGS_FW_DOWNLOAD_BOOT) {
-#endif
 			/* If the DownloadBoot operation fails, the
 			 * IOC will be left unusable. This is a fatal error
 			 * case.  _diag_reset will return < 0
@@ -3318,7 +3327,7 @@
 #ifdef MPT_DEBUG
 				if (ioc->alt_ioc)
 					diag1val =3D CHIPREG_READ32(&ioc->alt_ioc->chip->Diagnostic);
-				dprintk((MYIOC_s_INFO_FMT=20
+				dprintk((MYIOC_s_INFO_FMT
 					"DbG2b: diag0=3D%08x, diag1=3D%08x\n",
 					ioc->name, diag0val, diag1val));
 #endif
@@ -3335,7 +3344,7 @@
 				}
 			}
 			if ((count =3D mpt_downloadboot(ioc, sleepFlag)) < 0) {
-				printk(KERN_WARNING MYNAM=20
+				printk(KERN_WARNING MYNAM
 					": firmware downloadboot failure (%d)!\n", count);
 			}
=20
@@ -3467,7 +3476,7 @@
 	if ((r =3D WaitForDoorbellAck(ioc, 2, sleepFlag)) < 0)
 		return r;
=20
-	/* FW ACK'd request, wait for READY state=20
+	/* FW ACK'd request, wait for READY state
 	 */
 	cntdn =3D HZ * 15;
 	count =3D 0;
@@ -3631,6 +3640,9 @@
 	}
 	spin_unlock_irqrestore(&ioc->FreeQlock, flags);
=20
+#ifdef MFCNT
+	ioc->mfcnt =3D 0;
+#endif
=20
 	if (ioc->sense_buf_pool =3D NULL) {
 		sz =3D (ioc->req_depth * MPT_SENSE_BUFFER_ALLOC);
@@ -4267,7 +4279,7 @@
 	int			 ii;
 	int			 data, rc =3D 0;
=20
-	/* Allocate memory=20
+	/* Allocate memory
 	 */
 	if (!ioc->spi_data.nvram) {
 		int	 sz;
@@ -4446,12 +4458,17 @@
 	ioc->spi_data.sdp0version =3D cfg.hdr->PageVersion;
 	ioc->spi_data.sdp0length =3D cfg.hdr->PageLength;
=20
+	dcprintk((MYIOC_s_INFO_FMT "Headers: 0: version %d length %d\n",
+			ioc->name, ioc->spi_data.sdp0version, ioc->spi_data.sdp0length));
+
+	dcprintk((MYIOC_s_INFO_FMT "Headers: 1: version %d length %d\n",
+			ioc->name, ioc->spi_data.sdp1version, ioc->spi_data.sdp1length));
 	return 0;
 }
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /**
- *	mpt_findImVolumes - Identify IDs of hidden disks and RAID Volumes=20
+ *	mpt_findImVolumes - Identify IDs of hidden disks and RAID Volumes
  *	@ioc: Pointer to a Adapter Strucutre
  *	@portnum: IOC port number
  *
@@ -4464,17 +4481,13 @@
 mpt_findImVolumes(MPT_ADAPTER *ioc)
 {
 	IOCPage2_t		*pIoc2 =3D NULL;
-	IOCPage3_t		*pIoc3 =3D NULL;
 	ConfigPageIoc2RaidVol_t	*pIocRv =3D NULL;
-	u8			*mem;
 	dma_addr_t		 ioc2_dma;
-	dma_addr_t		 ioc3_dma;
 	CONFIGPARMS		 cfg;
 	ConfigPageHeader_t	 header;
 	int			 jj;
 	int			 rc =3D 0;
 	int			 iocpage2sz;
-	int			 iocpage3sz =3D 0;
 	u8			 nVols, nPhys;
 	u8			 vid, vbus, vioc;
=20
@@ -4541,44 +4554,7 @@
 		/* No physical disks. Done.
 		 */
 	} else {
-		/* There is at least one physical disk.
-		 * Read and save IOC Page 3
-		 */
-		header.PageVersion =3D 0;
-		header.PageLength =3D 0;
-		header.PageNumber =3D 3;
-		header.PageType =3D MPI_CONFIG_PAGETYPE_IOC;
-		cfg.hdr =3D &header;
-		cfg.physAddr =3D -1;
-		cfg.pageAddr =3D 0;
-		cfg.action =3D MPI_CONFIG_ACTION_PAGE_HEADER;
-		cfg.dir =3D 0;
-		cfg.timeout =3D 0;
-		if (mpt_config(ioc, &cfg) !=3D 0)
-			goto done_and_free;
-
-		if (header.PageLength =3D 0)
-			goto done_and_free;
-
-		/* Read Header good, alloc memory
-		 */
-		iocpage3sz =3D header.PageLength * 4;
-		pIoc3 =3D pci_alloc_consistent(ioc->pcidev, iocpage3sz, &ioc3_dma);
-		if (!pIoc3)
-			goto done_and_free;
-
-		/* Read the Page and save the data
-		 * into malloc'd memory.
-		 */
-		cfg.physAddr =3D ioc3_dma;
-		cfg.action =3D MPI_CONFIG_ACTION_PAGE_READ_CURRENT;
-		if (mpt_config(ioc, &cfg) =3D 0) {
-			mem =3D kmalloc(iocpage3sz, GFP_ATOMIC);
-			if (mem) {
-				memcpy(mem, (u8 *)pIoc3, iocpage3sz);
-				ioc->spi_data.pIocPg3 =3D (IOCPage3_t *) mem;
-			}
-		}
+		mpt_read_ioc_pg_3(ioc);
 	}
=20
 done_and_free:
@@ -4587,14 +4563,159 @@
 		pIoc2 =3D NULL;
 	}
=20
+	return rc;
+}
+
+int
+mpt_read_ioc_pg_3(MPT_ADAPTER *ioc)
+{
+	IOCPage3_t		*pIoc3 =3D NULL;
+	u8			*mem;
+	CONFIGPARMS		 cfg;
+	ConfigPageHeader_t	 header;
+	dma_addr_t		 ioc3_dma;
+	int			 iocpage3sz =3D 0;
+
+	/* Free the old page
+	 */
+	if (ioc->spi_data.pIocPg3) {
+		kfree(ioc->spi_data.pIocPg3);
+		ioc->spi_data.pIocPg3 =3D NULL;
+	}
+
+	/* There is at least one physical disk.
+	 * Read and save IOC Page 3
+	 */
+	header.PageVersion =3D 0;
+	header.PageLength =3D 0;
+	header.PageNumber =3D 3;
+	header.PageType =3D MPI_CONFIG_PAGETYPE_IOC;
+	cfg.hdr =3D &header;
+	cfg.physAddr =3D -1;
+	cfg.pageAddr =3D 0;
+	cfg.action =3D MPI_CONFIG_ACTION_PAGE_HEADER;
+	cfg.dir =3D 0;
+	cfg.timeout =3D 0;
+	if (mpt_config(ioc, &cfg) !=3D 0)
+		return 0;
+
+	if (header.PageLength =3D 0)
+		return 0;
+
+	/* Read Header good, alloc memory
+	 */
+	iocpage3sz =3D header.PageLength * 4;
+	pIoc3 =3D pci_alloc_consistent(ioc->pcidev, iocpage3sz, &ioc3_dma);
+	if (!pIoc3)
+		return 0;
+
+	/* Read the Page and save the data
+	 * into malloc'd memory.
+	 */
+	cfg.physAddr =3D ioc3_dma;
+	cfg.action =3D MPI_CONFIG_ACTION_PAGE_READ_CURRENT;
+	if (mpt_config(ioc, &cfg) =3D 0) {
+		mem =3D kmalloc(iocpage3sz, GFP_ATOMIC);
+		if (mem) {
+			memcpy(mem, (u8 *)pIoc3, iocpage3sz);
+			ioc->spi_data.pIocPg3 =3D (IOCPage3_t *) mem;
+		}
+	}
+
 	if (pIoc3) {
 		pci_free_consistent(ioc->pcidev, iocpage3sz, pIoc3, ioc3_dma);
 		pIoc3 =3D NULL;
 	}
=20
-	return rc;
+	return 0;
 }
=20
+static void
+mpt_read_ioc_pg_1(MPT_ADAPTER *ioc)
+{
+	IOCPage1_t		*pIoc1 =3D NULL;
+	CONFIGPARMS		 cfg;
+	ConfigPageHeader_t	 header;
+	dma_addr_t		 ioc1_dma;
+	int			 iocpage1sz =3D 0;
+	u32			 tmp;
+
+	/* Check the Coalescing Timeout in IOC Page 1
+	 */
+	header.PageVersion =3D 0;
+	header.PageLength =3D 0;
+	header.PageNumber =3D 1;
+	header.PageType =3D MPI_CONFIG_PAGETYPE_IOC;
+	cfg.hdr =3D &header;
+	cfg.physAddr =3D -1;
+	cfg.pageAddr =3D 0;
+	cfg.action =3D MPI_CONFIG_ACTION_PAGE_HEADER;
+	cfg.dir =3D 0;
+	cfg.timeout =3D 0;
+	if (mpt_config(ioc, &cfg) !=3D 0)
+		return;
+
+	if (header.PageLength =3D 0)
+		return;
+
+	/* Read Header good, alloc memory
+	 */
+	iocpage1sz =3D header.PageLength * 4;
+	pIoc1 =3D pci_alloc_consistent(ioc->pcidev, iocpage1sz, &ioc1_dma);
+	if (!pIoc1)
+		return;
+
+	/* Read the Page and check coalescing timeout
+	 */
+	cfg.physAddr =3D ioc1_dma;
+	cfg.action =3D MPI_CONFIG_ACTION_PAGE_READ_CURRENT;
+	if (mpt_config(ioc, &cfg) =3D 0) {
+	=09
+		tmp =3D le32_to_cpu(pIoc1->Flags) & MPI_IOCPAGE1_REPLY_COALESCING;
+		if (tmp =3D MPI_IOCPAGE1_REPLY_COALESCING) {
+			tmp =3D le32_to_cpu(pIoc1->CoalescingTimeout);
+
+			dprintk((MYIOC_s_INFO_FMT "Coalescing Enabled Timeout =3D %d\n",
+					ioc->name, tmp));
+
+			if (tmp > MPT_COALESCING_TIMEOUT) {
+				pIoc1->CoalescingTimeout =3D cpu_to_le32(MPT_COALESCING_TIMEOUT);
+
+				/* Write NVRAM and current
+				 */
+				cfg.dir =3D 1;
+				cfg.action =3D MPI_CONFIG_ACTION_PAGE_WRITE_CURRENT;
+				if (mpt_config(ioc, &cfg) =3D 0) {
+					dprintk((MYIOC_s_INFO_FMT "Reset Current Coalescing Timeout to =3D %d=
\n",
+							ioc->name, MPT_COALESCING_TIMEOUT));
+
+					cfg.action =3D MPI_CONFIG_ACTION_PAGE_WRITE_NVRAM;
+					if (mpt_config(ioc, &cfg) =3D 0) {
+						dprintk((MYIOC_s_INFO_FMT "Reset NVRAM Coalescing Timeout to =3D %d\=
n",
+								ioc->name, MPT_COALESCING_TIMEOUT));
+					} else {
+						dprintk((MYIOC_s_INFO_FMT "Reset NVRAM Coalescing Timeout Failed\n",
+									ioc->name));
+					}
+
+				} else {
+					dprintk((MYIOC_s_WARN_FMT "Reset of Current Coalescing Timeout Failed=
!\n",
+								ioc->name));
+				}
+			}
+
+		} else {
+			dprintk((MYIOC_s_WARN_FMT "Coalescing Disabled\n", ioc->name));
+		}
+	}
+
+	if (pIoc1) {
+		pci_free_consistent(ioc->pcidev, iocpage1sz, pIoc1, ioc1_dma);
+		pIoc1 =3D NULL;
+	}
+
+	return;
+}
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -4690,7 +4811,7 @@
 	 */
 	in_isr =3D in_interrupt();
 	if (in_isr) {
-		dprintk((MYIOC_s_WARN_FMT "Config request not allowed in ISR context!\n",
+		dcprintk((MYIOC_s_WARN_FMT "Config request not allowed in ISR context!\n=
",
 				ioc->name));
 		return -EPERM;
 	}
@@ -4698,7 +4819,7 @@
 	/* Get and Populate a free Frame
 	 */
 	if ((mf =3D mpt_get_msg_frame(mpt_base_index, ioc->id)) =3D NULL) {
-		dprintk((MYIOC_s_WARN_FMT "mpt_config: no msg frames!\n",
+		dcprintk((MYIOC_s_WARN_FMT "mpt_config: no msg frames!\n",
 				ioc->name));
 		return -EAGAIN;
 	}
@@ -4731,7 +4852,7 @@
=20
 	mpt_add_sge((char *)&pReq->PageBufferSGE, flagsLength, pCfg->physAddr);
=20
-	dprintk((MYIOC_s_INFO_FMT "Sending Config request type %d, page %d and ac=
tion %d\n",
+	dcprintk((MYIOC_s_INFO_FMT "Sending Config request type %d, page %d and a=
ction %d\n",
 		ioc->name, pReq->Header.PageType, pReq->Header.PageNumber, pReq->Action)=
);
=20
 	/* Append pCfg pointer to end of mf
@@ -4778,7 +4899,7 @@
 {
 	MPT_ADAPTER *ioc =3D (MPT_ADAPTER *) data;
=20
-	dprintk((MYIOC_s_WARN_FMT "mpt_timer_expired! \n", ioc->name));
+	dcprintk((MYIOC_s_WARN_FMT "mpt_timer_expired! \n", ioc->name));
=20
 	/* Perform a FW reload */
 	if (mpt_HardResetHandler(ioc, NO_SLEEP) < 0)
@@ -4788,7 +4909,7 @@
 	 * Hard reset clean-up will wake up
 	 * process and free all resources.
 	 */
-	dprintk((MYIOC_s_WARN_FMT "mpt_timer_expired complete!\n", ioc->name));
+	dcprintk((MYIOC_s_WARN_FMT "mpt_timer_expired complete!\n", ioc->name));
=20
 	return;
 }
@@ -4829,7 +4950,7 @@
 	} else {
 		CONFIGPARMS *pNext;
=20
-		/* Search the configQ for internal commands.=20
+		/* Search the configQ for internal commands.
 		 * Flush the Q, and wake up all suspended threads.
 		 */
 #if 1
@@ -5096,8 +5217,7 @@
 			 */
 			if (isense_idx =3D ii)
 				len +=3D sprintf(buf+len, "  Fusion MPT isense driver\n");
-		} else
-			break;
+		}
 	}
=20
 	MPT_PROC_READ_RETURN(buf,start,offset,request,eof,len);
@@ -5774,6 +5894,7 @@
 EXPORT_SYMBOL(mpt_stm_index);
 EXPORT_SYMBOL(mpt_HardResetHandler);
 EXPORT_SYMBOL(mpt_config);
+EXPORT_SYMBOL(mpt_read_ioc_pg_3);
 EXPORT_SYMBOL(mpt_alloc_fw_memory);
 EXPORT_SYMBOL(mpt_free_fw_memory);
=20
@@ -5843,6 +5964,7 @@
 fusion_exit(void)
 {
 	MPT_ADAPTER *this;
+	struct pci_dev *pdev =3D NULL;
=20
 	dprintk((KERN_INFO MYNAM ": fusion_exit() called!\n"));
=20
@@ -5861,8 +5983,13 @@
=20
 		this->active =3D 0;
=20
+		pdev =3D (struct pci_dev *)this->pcidev;
+		mptscsih_sync_irq(pdev->irq);
+
 		/* Clear any lingering interrupt */
 		CHIPREG_WRITE32(&this->chip->IntStatus, 0);
+
+		CHIPREG_READ32(&this->chip->IntStatus);
=20
 		Q_DEL_ITEM(this);
 		mpt_adapter_dispose(this);
diff -Nru a/drivers/message/fusion/mptbase.h b/drivers/message/fusion/mptba=
se.h
--- a/drivers/message/fusion/mptbase.h	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptbase.h	Thu Jan  2 15:40:31 2003
@@ -13,7 +13,7 @@
  *  (mailto:sjralston1@netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptbase.h,v 1.136 2002/10/21 13:51:54 pdelaney Exp $
+ *  $Id: mptbase.h,v 1.141 2002/12/03 21:26:32 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -80,8 +80,8 @@
 #define COPYRIGHT	"Copyright (c) 1999-2002 " MODULEAUTHOR
 #endif
=20
-#define MPT_LINUX_VERSION_COMMON	"2.03.00.02"
-#define MPT_LINUX_PACKAGE_NAME		"@(#)mptlinux-2.03.00.02"
+#define MPT_LINUX_VERSION_COMMON	"2.03.01.01"
+#define MPT_LINUX_PACKAGE_NAME		"@(#)mptlinux-2.03.01.01"
 #define WHAT_MAGIC_STRING		"@" "(" "#" ")"
=20
 #define show_mptmod_ver(s,ver)  \
@@ -134,8 +134,10 @@
 #define	 CAN_SLEEP			1
 #define  NO_SLEEP			0
=20
-/*=20
- * SCSI transfer rate defines.=20
+#define MPT_COALESCING_TIMEOUT		0x10
+
+/*
+ * SCSI transfer rate defines.
  */
 #define MPT_ULTRA320			0x08
 #define MPT_ULTRA160			0x09
@@ -524,7 +526,7 @@
 #define MPT_SCSICFG_DV_PENDING		0x04	/* DV on this physical id pending */
 #define MPT_SCSICFG_DV_NOT_DONE		0x08	/* DV has not been performed */
 #define MPT_SCSICFG_BLK_NEGO		0x10	/* WriteSDP1 with WDTR and SDTR disable=
d */
-
+#define MPT_SCSICFG_RELOAD_IOC_PG3	0x20	/* IOC Pg 3 data is obsolete */
 						/* Args passed to writeSDP1: */
 #define MPT_SCSICFG_USE_NVRAM		0x01	/* WriteSDP1 using NVRAM */
 #define MPT_SCSICFG_ALL_IDS		0x02	/* WriteSDP1 to all IDS */
@@ -756,6 +758,12 @@
 #define nehprintk(x)
 #endif
=20
+#if defined(MPT_DEBUG_CONFIG) || defined(MPT_DEBUG)
+#define dcprintk(x) printk x
+#else
+#define dcprintk(x)
+#endif
+
 #define MPT_INDEX_2_MFPTR(ioc,idx) \
 	(MPT_FRAME_HDR*)( (u8*)(ioc)->req_frames + (ioc)->req_sz * (idx) )
=20
@@ -1009,6 +1017,7 @@
 extern int	 mpt_config(MPT_ADAPTER *ioc, CONFIGPARMS *cfg);
 extern void	*mpt_alloc_fw_memory(MPT_ADAPTER *ioc, int size, int *frags, i=
nt *alloc_sz);
 extern void	 mpt_free_fw_memory(MPT_ADAPTER *ioc, fw_image_t **alt_img);
+extern int	 mpt_read_ioc_pg_3(MPT_ADAPTER *ioc);
=20
 /*
  *  Public data decl's...
diff -Nru a/drivers/message/fusion/mptctl.c b/drivers/message/fusion/mptctl=
.c
--- a/drivers/message/fusion/mptctl.c	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptctl.c	Thu Jan  2 15:40:31 2003
@@ -34,7 +34,7 @@
  *  (mailto:sjralston1@netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptctl.c,v 1.61 2002/10/17 20:15:57 pdelaney Exp $
+ *  $Id: mptctl.c,v 1.63 2002/12/03 21:26:33 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -2911,9 +2911,9 @@
 #endif		/*} sparc */
=20
 	/* Register this device */
-	if (misc_register(&mptctl_miscdev) =3D -1) {
+	err =3D misc_register(&mptctl_miscdev);
+	if (err < 0) {
 		printk(KERN_ERR MYNAM ": Can't register misc device [minor=3D%d].\n", MP=
T_MINOR);
-		err =3D -EBUSY;
 		goto out_fail;
 	}
 	printk(KERN_INFO MYNAM ": Registered with Fusion MPT base driver\n");
diff -Nru a/drivers/message/fusion/mptctl.h b/drivers/message/fusion/mptctl=
.h
--- a/drivers/message/fusion/mptctl.h	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptctl.h	Thu Jan  2 15:40:31 2003
@@ -20,7 +20,7 @@
  *  (mailto:sjralston1@netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptctl.h,v 1.12 2002/10/17 20:15:58 pdelaney Exp $
+ *  $Id: mptctl.h,v 1.13 2002/12/03 21:26:33 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
diff -Nru a/drivers/message/fusion/mptscsih.c b/drivers/message/fusion/mpts=
csih.c
--- a/drivers/message/fusion/mptscsih.c	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptscsih.c	Thu Jan  2 15:40:31 2003
@@ -26,7 +26,7 @@
  *  (mailto:sjralston1@netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptscsih.c,v 1.103 2002/10/17 20:15:59 pdelaney Exp $
+ *  $Id: mptscsih.c,v 1.104 2002/12/03 21:26:34 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -159,11 +159,9 @@
 static int	mptscsih_io_done(MPT_ADAPTER *ioc, MPT_FRAME_HDR *mf, MPT_FRAME=
_HDR *r);
 static void	mptscsih_report_queue_full(Scsi_Cmnd *sc, SCSIIOReply_t *pScsi=
Reply, SCSIIORequest_t *pScsiReq);
 static int	mptscsih_taskmgmt_complete(MPT_ADAPTER *ioc, MPT_FRAME_HDR *mf,=
 MPT_FRAME_HDR *r);
-static int	mptscsih_io_direction(Scsi_Cmnd *cmd);
=20
 static int	mptscsih_AddSGE(MPT_SCSI_HOST *hd, Scsi_Cmnd *SCpnt,
 				 SCSIIORequest_t *pReq, int req_idx);
-static int	mptscsih_getFreeChainBuffer(MPT_SCSI_HOST *hd, int *retIndex);
 static void	mptscsih_freeChainBuffers(MPT_SCSI_HOST *hd, int req_idx);
 static int	mptscsih_initChainBuffers (MPT_SCSI_HOST *hd, int init);
 static void	copy_sense_data(Scsi_Cmnd *sc, MPT_SCSI_HOST *hd, MPT_FRAME_HD=
R *mf, SCSIIOReply_t *pScsiReply);
@@ -274,6 +272,436 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
+ *  Private inline routines...
+ */
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/* 19991030 -sralston
+ *  Return absolute SCSI data direction:
+ *     1 =3D _DATA_OUT
+ *     0 =3D _DIR_NONE
+ *    -1 =3D _DATA_IN
+ *
+ * Changed: 3-20-2002 pdelaney to use the default data
+ * direction and the defines set up in the
+ * 2.4 kernel series
+ *     1 =3D _DATA_OUT	changed to SCSI_DATA_WRITE (1)
+ *     0 =3D _DIR_NONE	changed to SCSI_DATA_NONE (3)
+ *    -1 =3D _DATA_IN	changed to SCSI_DATA_READ (2)
+ * If the direction is unknown, fall through to original code.
+ *
+ * Mid-layer bug fix(): sg interface generates the wrong data
+ * direction in some cases. Set the direction the hard way for
+ * the most common commands.
+ */
+static inline int
+mptscsih_io_direction(Scsi_Cmnd *cmd)
+{
+	switch (cmd->cmnd[0]) {
+	case WRITE_6:	=09
+	case WRITE_10:	=09
+		return SCSI_DATA_WRITE;
+		break;
+	case READ_6:	=09
+	case READ_10:	=09
+		return SCSI_DATA_READ;
+		break;
+	}
+
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,4,0)
+	if (cmd->sc_data_direction !=3D SCSI_DATA_UNKNOWN)
+		return cmd->sc_data_direction;
+#endif
+	switch (cmd->cmnd[0]) {
+	/*  _DATA_OUT commands	*/
+	case WRITE_6:		case WRITE_10:		case WRITE_12:
+	case WRITE_LONG:	case WRITE_SAME:	case WRITE_BUFFER:
+	case WRITE_VERIFY:	case WRITE_VERIFY_12:
+	case COMPARE:		case COPY:		case COPY_VERIFY:
+	case SEARCH_EQUAL:	case SEARCH_HIGH:	case SEARCH_LOW:
+	case SEARCH_EQUAL_12:	case SEARCH_HIGH_12:	case SEARCH_LOW_12:
+	case MODE_SELECT:	case MODE_SELECT_10:	case LOG_SELECT:
+	case SEND_DIAGNOSTIC:	case CHANGE_DEFINITION: case UPDATE_BLOCK:
+	case SET_WINDOW:	case MEDIUM_SCAN:	case SEND_VOLUME_TAG:
+	case REASSIGN_BLOCKS:
+	case PERSISTENT_RESERVE_OUT:
+	case 0xea:
+	case 0xa3:
+		return SCSI_DATA_WRITE;
+
+	/*  No data transfer commands  */
+	case SEEK_6:		case SEEK_10:
+	case RESERVE:		case RELEASE:
+	case TEST_UNIT_READY:
+	case START_STOP:
+	case ALLOW_MEDIUM_REMOVAL:
+		return SCSI_DATA_NONE;
+
+	/*  Conditional data transfer commands	*/
+	case FORMAT_UNIT:
+		if (cmd->cmnd[1] & 0x10)	/* FmtData (data out phase)? */
+			return SCSI_DATA_WRITE;
+		else
+			return SCSI_DATA_NONE;
+
+	case VERIFY:
+		if (cmd->cmnd[1] & 0x02)	/* VERIFY:BYTCHK (data out phase)? */
+			return SCSI_DATA_WRITE;
+		else
+			return SCSI_DATA_NONE;
+
+	case RESERVE_10:
+		if (cmd->cmnd[1] & 0x03)	/* RESERVE:{LongID|Extent} (data out phase)? */
+			return SCSI_DATA_WRITE;
+		else
+			return SCSI_DATA_NONE;
+
+	/*  Must be data _IN!  */
+	default:
+		return SCSI_DATA_READ;
+	}
+} /* mptscsih_io_direction() */
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/**
+ *	mptscsih_add_sge - Place a simple SGE at address pAddr.
+ *	@pAddr: virtual address for SGE
+ *	@flagslength: SGE flags and data transfer length
+ *	@dma_addr: Physical address
+ *
+ *	This routine places a MPT request frame back on the MPT adapter's
+ *	FreeQ.
+ */
+static inline void
+mptscsih_add_sge(char *pAddr, u32 flagslength, dma_addr_t dma_addr)
+{
+	if (sizeof(dma_addr_t) =3D sizeof(u64)) {
+		SGESimple64_t *pSge =3D (SGESimple64_t *) pAddr;
+		u32 tmp =3D dma_addr & 0xFFFFFFFF;
+
+		pSge->FlagsLength =3D cpu_to_le32(flagslength);
+		pSge->Address.Low =3D cpu_to_le32(tmp);
+		tmp =3D (u32) ((u64)dma_addr >> 32);
+		pSge->Address.High =3D cpu_to_le32(tmp);
+
+	} else {
+		SGESimple32_t *pSge =3D (SGESimple32_t *) pAddr;
+		pSge->FlagsLength =3D cpu_to_le32(flagslength);
+		pSge->Address =3D cpu_to_le32(dma_addr);
+	}
+} /* mptscsih_add_sge() */
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/**
+ *	mptscsih_add_chain - Place a chain SGE at address pAddr.
+ *	@pAddr: virtual address for SGE
+ *	@next: nextChainOffset value (u32's)
+ *	@length: length of next SGL segment
+ *	@dma_addr: Physical address
+ *
+ *	This routine places a MPT request frame back on the MPT adapter's
+ *	FreeQ.
+ */
+static inline void
+mptscsih_add_chain(char *pAddr, u8 next, u16 length, dma_addr_t dma_addr)
+{
+	if (sizeof(dma_addr_t) =3D sizeof(u64)) {
+		SGEChain64_t *pChain =3D (SGEChain64_t *) pAddr;
+		u32 tmp =3D dma_addr & 0xFFFFFFFF;
+
+		pChain->Length =3D cpu_to_le16(length);
+		pChain->Flags =3D MPI_SGE_FLAGS_CHAIN_ELEMENT | mpt_addr_size();
+
+		pChain->NextChainOffset =3D next;
+
+		pChain->Address.Low =3D cpu_to_le32(tmp);
+		tmp =3D (u32) ((u64)dma_addr >> 32);
+		pChain->Address.High =3D cpu_to_le32(tmp);
+	} else {
+		SGEChain32_t *pChain =3D (SGEChain32_t *) pAddr;
+		pChain->Length =3D cpu_to_le16(length);
+		pChain->Flags =3D MPI_SGE_FLAGS_CHAIN_ELEMENT | mpt_addr_size();
+		pChain->NextChainOffset =3D next;
+		pChain->Address =3D cpu_to_le32(dma_addr);
+	}
+} /* mptscsih_add_chain() */
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/*
+ *	mptscsih_getFreeChainBuffes - Function to get a free chain
+ *	from the MPT_SCSI_HOST FreeChainQ.
+ *	@hd: Pointer to the MPT_SCSI_HOST instance
+ *	@req_idx: Index of the SCSI IO request frame. (output)
+ *
+ *	return SUCCESS or FAILED
+ */
+static inline int
+mptscsih_getFreeChainBuffer(MPT_SCSI_HOST *hd, int *retIndex)
+{
+	MPT_FRAME_HDR *chainBuf =3D NULL;
+	unsigned long flags;
+	int rc =3D FAILED;
+	int chain_idx =3D MPT_HOST_NO_CHAIN;
+
+	spin_lock_irqsave(&hd->ioc->FreeQlock, flags);
+	if (!Q_IS_EMPTY(&hd->FreeChainQ)) {
+
+		int offset;
+
+		chainBuf =3D hd->FreeChainQ.head;
+		Q_DEL_ITEM(&chainBuf->u.frame.linkage);
+		offset =3D (u8 *)chainBuf - (u8 *)hd->ChainBuffer;
+		chain_idx =3D offset / hd->ioc->req_sz;
+		rc =3D SUCCESS;
+	}
+	spin_unlock_irqrestore(&hd->ioc->FreeQlock, flags);
+
+
+	*retIndex =3D chain_idx;
+
+	dsgprintk((MYIOC_s_INFO_FMT "getFreeChainBuffer (index %d), got buf=3D%p\=
n",
+			hd->ioc->name, *retIndex, chainBuf));
+
+	return rc;
+} /* mptscsih_getFreeChainBuffer() */
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/*
+ *	mptscsih_AddSGE - Add a SGE (plus chain buffers) to the
+ *	SCSIIORequest_t Message Frame.
+ *	@hd: Pointer to MPT_SCSI_HOST structure
+ *	@SCpnt: Pointer to Scsi_Cmnd structure
+ *	@pReq: Pointer to SCSIIORequest_t structure
+ *
+ *	Returns ...
+ */
+static int
+mptscsih_AddSGE(MPT_SCSI_HOST *hd, Scsi_Cmnd *SCpnt,
+		SCSIIORequest_t *pReq, int req_idx)
+{
+	char 	*psge;
+	char	*chainSge;
+	struct scatterlist *sg;
+	int	 frm_sz;
+	int	 sges_left, sg_done;
+	int	 chain_idx =3D MPT_HOST_NO_CHAIN;
+	int	 sgeOffset;
+	int	 numSgeSlots, numSgeThisFrame;
+	u32	 sgflags, sgdir, thisxfer =3D 0;
+	int	 chain_dma_off =3D 0;
+	int	 newIndex;
+	int	 ii;
+	dma_addr_t v2;
+
+	sgdir =3D le32_to_cpu(pReq->Control) & MPI_SCSIIO_CONTROL_DATADIRECTION_M=
ASK;
+	if (sgdir =3D MPI_SCSIIO_CONTROL_WRITE)  {
+		sgdir =3D MPT_TRANSFER_HOST_TO_IOC;
+	} else {
+		sgdir =3D MPT_TRANSFER_IOC_TO_HOST;
+	}
+
+	psge =3D (char *) &pReq->SGL;
+	frm_sz =3D hd->ioc->req_sz;
+
+	/* Map the data portion, if any.
+	 * sges_left  =3D 0 if no data transfer.
+	 */
+	sges_left =3D SCpnt->use_sg;
+	if (SCpnt->use_sg) {
+		sges_left =3D pci_map_sg(hd->ioc->pcidev,
+			       (struct scatterlist *) SCpnt->request_buffer,
+			       SCpnt->use_sg,
+			       scsi_to_pci_dma_dir(SCpnt->sc_data_direction));
+	} else if (SCpnt->request_bufflen) {
+		dma_addr_t	 buf_dma_addr;
+		scPrivate	*my_priv;
+
+		buf_dma_addr =3D pci_map_single(hd->ioc->pcidev,
+				      SCpnt->request_buffer,
+				      SCpnt->request_bufflen,
+				      scsi_to_pci_dma_dir(SCpnt->sc_data_direction));
+
+		/* We hide it here for later unmap. */
+		my_priv =3D (scPrivate *) &SCpnt->SCp;
+		my_priv->p1 =3D (void *)(ulong) buf_dma_addr;
+
+		dsgprintk((MYIOC_s_INFO_FMT "SG: non-SG for %p, len=3D%d\n",
+				hd->ioc->name, SCpnt, SCpnt->request_bufflen));
+
+		mptscsih_add_sge((char *) &pReq->SGL,
+			0xD1000000|MPT_SGE_FLAGS_ADDRESSING|sgdir|SCpnt->request_bufflen,
+			buf_dma_addr);
+
+		return SUCCESS;
+	}
+
+	/* Handle the SG case.
+	 */
+	sg =3D (struct scatterlist *) SCpnt->request_buffer;
+	sg_done  =3D 0;
+	sgeOffset =3D sizeof(SCSIIORequest_t) - sizeof(SGE_IO_UNION);
+	chainSge =3D NULL;
+
+	/* Prior to entering this loop - the following must be set
+	 * current MF:  sgeOffset (bytes)
+	 *              chainSge (Null if original MF is not a chain buffer)
+	 *              sg_done (num SGE done for this MF)
+	 */
+
+nextSGEset:
+	numSgeSlots =3D ((frm_sz - sgeOffset) / (sizeof(u32) + sizeof(dma_addr_t)=
) );
+	numSgeThisFrame =3D (sges_left < numSgeSlots) ? sges_left : numSgeSlots;
+
+	sgflags =3D MPT_SGE_FLAGS_SIMPLE_ELEMENT | MPT_SGE_FLAGS_ADDRESSING | sgd=
ir;
+
+	/* Get first (num - 1) SG elements
+	 * Skip any SG entries with a length of 0
+	 * NOTE: at finish, sg and psge pointed to NEXT data/location positions
+	 */
+	for (ii=3D0; ii < (numSgeThisFrame-1); ii++) {
+		thisxfer =3D sg_dma_len(sg);
+		if (thisxfer =3D 0) {
+			sg ++; /* Get next SG element from the OS */
+			sg_done++;
+			continue;
+		}
+
+		v2 =3D sg_dma_address(sg);
+		mptscsih_add_sge(psge, sgflags | thisxfer, v2);
+
+		sg++;		/* Get next SG element from the OS */
+		psge +=3D (sizeof(u32) + sizeof(dma_addr_t));
+		sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
+		sg_done++;
+	}
+
+	if (numSgeThisFrame =3D sges_left) {
+		/* Add last element, end of buffer and end of list flags.
+		 */
+		sgflags |=3D MPT_SGE_FLAGS_LAST_ELEMENT |
+				MPT_SGE_FLAGS_END_OF_BUFFER |
+				MPT_SGE_FLAGS_END_OF_LIST;
+
+		/* Add last SGE and set termination flags.
+		 * Note: Last SGE may have a length of 0 - which should be ok.
+		 */
+		thisxfer =3D sg_dma_len(sg);
+
+		v2 =3D sg_dma_address(sg);
+		mptscsih_add_sge(psge, sgflags | thisxfer, v2);
+		/*
+		sg++;
+		psge +=3D (sizeof(u32) + sizeof(dma_addr_t));
+		*/
+		sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
+		sg_done++;
+
+		if (chainSge) {
+			/* The current buffer is a chain buffer,
+			 * but there is not another one.
+			 * Update the chain element
+			 * Offset and Length fields.
+			 */
+			mptscsih_add_chain((char *)chainSge, 0, sgeOffset, hd->ChainBufferDMA +=
 chain_dma_off);
+		} else {
+			/* The current buffer is the original MF
+			 * and there is no Chain buffer.
+			 */
+			pReq->ChainOffset =3D 0;
+		}
+	} else {
+		/* At least one chain buffer is needed.
+		 * Complete the first MF
+		 *  - last SGE element, set the LastElement bit
+		 *  - set ChainOffset (words) for orig MF
+		 *             (OR finish previous MF chain buffer)
+		 *  - update MFStructPtr ChainIndex
+		 *  - Populate chain element
+		 * Also
+		 * Loop until done.
+		 */
+
+		dsgprintk((MYIOC_s_INFO_FMT "SG: Chain Required! sg done %d\n",
+				hd->ioc->name, sg_done));
+
+		/* Set LAST_ELEMENT flag for last non-chain element
+		 * in the buffer. Since psge points at the NEXT
+		 * SGE element, go back one SGE element, update the flags
+		 * and reset the pointer. (Note: sgflags & thisxfer are already
+		 * set properly).
+		 */
+		if (sg_done) {
+			u32 *ptmp =3D (u32 *) (psge - (sizeof(u32) + sizeof(dma_addr_t)));
+			sgflags =3D le32_to_cpu(*ptmp);
+			sgflags |=3D MPT_SGE_FLAGS_LAST_ELEMENT;
+			*ptmp =3D cpu_to_le32(sgflags);
+		}
+
+		if (chainSge) {
+			/* The current buffer is a chain buffer.
+			 * chainSge points to the previous Chain Element.
+			 * Update its chain element Offset and Length (must
+			 * include chain element size) fields.
+			 * Old chain element is now complete.
+			 */
+			u8 nextChain =3D (u8) (sgeOffset >> 2);
+			sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
+			mptscsih_add_chain((char *)chainSge, nextChain, sgeOffset, hd->ChainBuf=
ferDMA + chain_dma_off);
+		} else {
+			/* The original MF buffer requires a chain buffer -
+			 * set the offset.
+			 * Last element in this MF is a chain element.
+			 */
+			pReq->ChainOffset =3D (u8) (sgeOffset >> 2);
+		}
+
+		sges_left -=3D sg_done;
+
+
+		/* NOTE: psge points to the beginning of the chain element
+		 * in current buffer. Get a chain buffer.
+		 */
+		if ((mptscsih_getFreeChainBuffer(hd, &newIndex)) =3D FAILED)
+			return FAILED;
+
+		/* Update the tracking arrays.
+		 * If chainSge =3D NULL, update ReqToChain, else ChainToChain
+		 */
+		if (chainSge) {
+			hd->ChainToChain[chain_idx] =3D newIndex;
+		} else {
+			hd->ReqToChain[req_idx] =3D newIndex;
+		}
+		chain_idx =3D newIndex;
+		chain_dma_off =3D hd->ioc->req_sz * chain_idx;
+
+		/* Populate the chainSGE for the current buffer.
+		 * - Set chain buffer pointer to psge and fill
+		 *   out the Address and Flags fields.
+		 */
+		chainSge =3D (char *) psge;
+		dsgprintk((KERN_INFO "  Current buff @ %p (index 0x%x)",
+				psge, req_idx));
+
+		/* Start the SGE for the next buffer
+		 */
+		psge =3D (char *) (hd->ChainBuffer + chain_dma_off);
+		sgeOffset =3D 0;
+		sg_done =3D 0;
+
+		dsgprintk((KERN_INFO "  Chain buff @ %p (index 0x%x)\n",
+				psge, chain_idx));
+
+		/* Start the SGE for the next buffer
+		 */
+
+		goto nextSGEset;
+	}
+
+	return SUCCESS;
+} /* mptscsih_AddSGE() */
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/*
  *	mptscsih_io_done - Main SCSI IO callback routine registered to
  *	Fusion MPT (base) driver
  *	@ioc: Pointer to MPT_ADAPTER structure
@@ -294,7 +722,7 @@
 	MPT_SCSI_HOST	*hd;
 	SCSIIORequest_t	*pScsiReq;
 	SCSIIOReply_t	*pScsiReply;
-#ifndef MPT_SCSI_USE_NEW_EH
+#if LINUX_VERSION_CODE <=3D KERNEL_VERSION(2,5,0)
 	unsigned long	 flags;
 #endif
 	u16		 req_idx;
@@ -305,7 +733,6 @@
 	    (mf >=3D MPT_INDEX_2_MFPTR(ioc, ioc->req_depth))) {
 		printk(MYIOC_s_ERR_FMT "%s req frame ptr! (=3D%p)!\n",
 				ioc->name, mf?"BAD":"NULL", (void *) mf);
-		/* return 1; CHECKME SteveR. Don't free. */
 		return 0;
 	}
=20
@@ -411,12 +838,12 @@
 #ifndef MPT_SCSI_USE_NEW_EH
 			search_taskQ_for_cmd(sc, hd);
 #endif
-			/* Linux handles an unsolicited DID_RESET better=20
+			/* Linux handles an unsolicited DID_RESET better
 			 * than an unsolicited DID_ABORT.
 			 */
 			sc->result =3D DID_RESET << 16;
=20
-			/* GEM Workaround. */=20
+			/* GEM Workaround. */
 			if (hd->is_spi)
 				mptscsih_no_negotiate(hd, sc->target);
 			break;
@@ -428,7 +855,7 @@
 #endif
 			sc->result =3D DID_RESET << 16;
=20
-			/* GEM Workaround. */=20
+			/* GEM Workaround. */
 			if (hd->is_spi)
 				mptscsih_no_negotiate(hd, sc->target);
 			break;
@@ -506,7 +933,7 @@
 				;
 			} else if (scsi_state & MPI_SCSI_STATE_AUTOSENSE_VALID) {
 				/*
-				 * If running agains circa 200003dd 909 MPT f/w,
+				 * If running against circa 200003dd 909 MPT f/w,
 				 * may get this (AUTOSENSE_VALID) for actual TASK_SET_FULL
 				 * (QUEUE_FULL) returned from device! --> get 0x0000?128
 				 * and with SenseBytes set to 0.
@@ -625,7 +1052,9 @@
=20
 	hd->ScsiLookup[req_idx] =3D NULL;
=20
-	sc->host_scribble =3D NULL;	/* CHECKME! - Do we need to clear this??? */
+#ifndef MPT_SCSI_USE_NEW_EH
+	sc->host_scribble =3D NULL;
+#endif
=20
         MPT_HOST_LOCK(flags);
 	sc->scsi_done(sc);		/* Issue the command callback */
@@ -894,7 +1323,7 @@
 	int		 ii;
 	int		 max =3D hd->ioc->req_depth;
=20
-#ifndef MPT_SCSI_USE_NEW_EH
+#if LINUX_VERSION_CODE <=3D KERNEL_VERSION(2,5,0)
 	unsigned long	 flags;
 #endif
=20
@@ -911,7 +1340,7 @@
 			search_taskQ_for_cmd(SCpnt, hd);
 #endif
=20
-			/* Search pendingQ, if found,=20
+			/* Search pendingQ, if found,
 			 * delete from Q. If found, do not decrement
 			 * queue_depth, command never posted.
 			 */
@@ -1061,7 +1490,7 @@
 	 * of chain buffers to be allocated.
 	 * index =3D chain_idx
 	 *
-	 * Calculate the number of chain buffers needed(plus 1) per I/O=20
+	 * Calculate the number of chain buffers needed(plus 1) per I/O
 	 * then multiply the the maximum number of simultaneous cmds
 	 *
 	 * num_sge =3D num sge in request frame + last chain buffer
@@ -1175,6 +1604,7 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 static int BeenHereDoneThat =3D 0;
+static char *info_kbuf =3D NULL;
=20
 /*  SCSI host fops start here...  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
@@ -1263,9 +1693,10 @@
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,0)
 			tpnt->proc_dir =3D &proc_mpt_scsihost;
 #endif
+			tpnt->proc_info =3D mptscsih_proc_info;
 			sh =3D scsi_register(tpnt, sizeof(MPT_SCSI_HOST));
 			if (sh !=3D NULL) {
-				mptscsih_lock(this, flags);
+				spin_lock_irqsave(&this->FreeQlock, flags);
 				sh->io_port =3D 0;
 				sh->n_io_port =3D 0;
 				sh->irq =3D 0;
@@ -1326,7 +1757,7 @@
 				} else {
 					numSGE =3D 1 + (scale - 1) * (this->facts.MaxChainDepth-1) + scale +
 						(this->req_sz - 64) / (sizeof(dma_addr_t) + sizeof(u32));
-				}=20
+				}
=20
 				if (numSGE < sh->sg_tablesize) {
 					/* Reset this value */
@@ -1340,7 +1771,7 @@
 				 */
 				scsi_set_pci_device(sh, this->pcidev);
=20
-				mptscsih_unlock(this, flags);
+				spin_unlock_irqrestore(&this->FreeQlock, flags);
=20
 				hd =3D (MPT_SCSI_HOST *) sh->hostdata;
 				hd->ioc =3D this;
@@ -1503,12 +1934,25 @@
 done:
 	if (mpt_scsi_hosts > 0)
 		register_reboot_notifier(&mptscsih_notifier);
+	else {
+		mpt_reset_deregister(ScsiDoneCtx);
+		dprintk((KERN_INFO MYNAM ": Deregistered for IOC reset notifications\n")=
);
+
+		mpt_event_deregister(ScsiDoneCtx);
+		dprintk((KERN_INFO MYNAM ": Deregistered for IOC event notifications\n")=
);
+
+		mpt_deregister(ScsiScanDvCtx);
+		mpt_deregister(ScsiTaskCtx);
+		mpt_deregister(ScsiDoneCtx);
+
+		if (info_kbuf !=3D NULL)
+			kfree(info_kbuf);
+	}
=20
 	return mpt_scsi_hosts;
 }
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
-    static char *info_kbuf =3D NULL;
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /**
  *	mptscsih_release - Unregister SCSI host from linux scsi mid-layer
@@ -1731,7 +2175,7 @@
 const char *
 mptscsih_info(struct Scsi_Host *SChost)
 {
-	MPT_SCSI_HOST *h;
+	MPT_SCSI_HOST *h =3D NULL;
 	int size =3D 0;
=20
 	if (info_kbuf =3D NULL)
@@ -1740,12 +2184,307 @@
=20
 	h =3D (MPT_SCSI_HOST *)SChost->hostdata;
 	info_kbuf[0] =3D '\0';
-	mpt_print_ioc_summary(h->ioc, info_kbuf, &size, 0, 0);
-	info_kbuf[size-1] =3D '\0';
+	if (h) {
+		mpt_print_ioc_summary(h->ioc, info_kbuf, &size, 0, 0);
+		info_kbuf[size-1] =3D '\0';
+	}
=20
 	return info_kbuf;
 }
=20
+struct info_str {
+	char *buffer;
+	int   length;
+	int   offset;
+	int   pos;
+};
+
+static void copy_mem_info(struct info_str *info, char *data, int len)
+{
+	if (info->pos + len > info->length)
+		len =3D info->length - info->pos;
+
+	if (info->pos + len < info->offset) {
+		info->pos +=3D len;
+		return;
+	}
+
+	if (info->pos < info->offset) {
+	        data +=3D (info->offset - info->pos);
+	        len  -=3D (info->offset - info->pos);
+	}
+
+	if (len > 0) {
+                memcpy(info->buffer + info->pos, data, len);
+                info->pos +=3D len;
+	}
+}
+
+static int copy_info(struct info_str *info, char *fmt, ...)
+{
+	va_list args;
+	char buf[81];
+	int len;
+
+	va_start(args, fmt);
+	len =3D vsprintf(buf, fmt, args);
+	va_end(args);
+
+	copy_mem_info(info, buf, len);
+	return len;
+}
+
+static int mptscsih_host_info(MPT_ADAPTER *ioc, char *pbuf, off_t offset, =
int len)
+{
+	struct info_str info;
+
+	info.buffer	=3D pbuf;
+	info.length	=3D len;
+	info.offset	=3D offset;
+	info.pos	=3D 0;
+
+	copy_info(&info, "%s: %s, ", ioc->name, ioc->prod_name);
+	copy_info(&info, "%s%08xh, ", MPT_FW_REV_MAGIC_ID_STRING, ioc->facts.FWVe=
rsion.Word);
+	copy_info(&info, "Ports=3D%d, ", ioc->facts.NumberOfPorts);
+	copy_info(&info, "MaxQ=3D%d\n", ioc->req_depth);
+
+	return ((info.pos > info.offset) ? info.pos - info.offset : 0);
+}
+
+struct mptscsih_usrcmd {
+	ulong target;
+	ulong lun;
+	ulong data;
+	ulong cmd;
+};
+
+#define UC_GET_SPEED	0x10
+
+static void mptscsih_exec_user_cmd(MPT_ADAPTER *ioc, struct mptscsih_usrcm=
d *uc)
+{
+	CONFIGPARMS		 cfg;
+	dma_addr_t		 cfg_dma_addr =3D -1;
+	ConfigPageHeader_t	 header;
+
+	dprintk(("exec_user_command: ioc %p cmd %ld target=3D%ld\n",=20
+			ioc, uc->cmd, uc->target));
+
+	switch (uc->cmd) {
+	case UC_GET_SPEED:
+		{
+			SCSIDevicePage0_t	*pData =3D NULL;
+
+			if (ioc->spi_data.sdp0length =3D 0)
+				return;
+
+			pData =3D (SCSIDevicePage0_t *)pci_alloc_consistent(ioc->pcidev,
+				 ioc->spi_data.sdp0length * 4, &cfg_dma_addr);
+
+			if (pData =3D NULL)
+				return;
+
+			header.PageVersion =3D ioc->spi_data.sdp0version;
+			header.PageLength =3D ioc->spi_data.sdp0length;
+			header.PageNumber =3D 0;
+			header.PageType =3D MPI_CONFIG_PAGETYPE_SCSI_DEVICE;
+
+			cfg.hdr =3D &header;
+			cfg.action =3D MPI_CONFIG_ACTION_PAGE_READ_CURRENT;
+			cfg.dir =3D 0;
+			cfg.pageAddr =3D (u32) uc->target; /* bus << 8 | target */
+			cfg.physAddr =3D cfg_dma_addr;
+
+			if (mpt_config(ioc, &cfg) =3D 0) {
+				u32 np =3D le32_to_cpu(pData->NegotiatedParameters);
+				u32 tmp =3D np & MPI_SCSIDEVPAGE0_NP_WIDE;
+
+				printk("Target %d: %s;",
+						(u32) uc->target,
+						tmp ? "Wide" : "Narrow");
+
+				tmp =3D np & MPI_SCSIDEVPAGE0_NP_NEG_SYNC_OFFSET_MASK;
+				if (tmp) {
+					u32 speed =3D 0;
+					printk(" Synchronous");
+					tmp =3D (tmp >> 16);
+					printk(" (Offset=3D0x%x", tmp);
+					tmp =3D np & MPI_SCSIDEVPAGE0_NP_NEG_SYNC_PERIOD_MASK;
+					tmp =3D (tmp >> 8);
+					printk(" Factor=3D0x%x)", tmp);
+					if (tmp <=3D MPT_ULTRA320)
+						speed=160;
+					else if (tmp <=3D MPT_ULTRA160)
+						speed=80;
+					else if (tmp <=3D MPT_ULTRA2)
+						speed@;
+					else if (tmp <=3D MPT_ULTRA)
+						speed ;
+					else if (tmp <=3D MPT_FAST)
+						speed=10;
+					else if (tmp <=3D MPT_SCSI)
+						speed=3D5;
+
+					if (np & MPI_SCSIDEVPAGE0_NP_WIDE)
+						speed*=3D2;
+
+					printk(" %dMB/sec\n", speed);
+
+				} else=20
+					printk(" Asynchronous.\n");
+			} else {
+				printk("failed\n" );
+			}
+
+			pci_free_consistent(ioc->pcidev, ioc->spi_data.sdp0length * 4,
+					    pData, cfg_dma_addr);
+		}
+		break;
+	}
+}
+
+#define is_digit(c)	((c) >=3D '0' && (c) <=3D '9')
+#define digit_to_bin(c)	((c) - '0')
+#define is_space(c)	((c) =3D ' ' || (c) =3D '\t')
+
+static int skip_spaces(char *ptr, int len)
+{
+	int cnt, c;
+
+	for (cnt =3D len; cnt > 0 && (c =3D *ptr++) && is_space(c); cnt --);
+
+	return (len - cnt);
+}
+
+static int get_int_arg(char *ptr, int len, ulong *pv)
+{
+	int cnt, c;
+	ulong	v;
+	for (v =3D  0, cnt =3D len; cnt > 0 && (c=3D*ptr++) && is_digit(c); cnt -=
-) {
+		v =3D (v * 10) + digit_to_bin(c);
+	}
+
+	if (pv)
+		*pv =3D v;
+
+	return (len - cnt);
+}
+
+
+static int is_keyword(char *ptr, int len, char *verb)
+{
+	int verb_len =3D strlen(verb);
+
+	if (len >=3D strlen(verb) && !memcmp(verb, ptr, verb_len))
+		return verb_len;
+	else
+		return 0;
+}
+
+#define SKIP_SPACES(min_spaces)						\
+	if ((arg_len =3D skip_spaces(ptr,len)) < (min_spaces))		\
+		return -EINVAL;						\
+	ptr +=3D arg_len;							\
+	len -=3D arg_len;
+
+#define GET_INT_ARG(v)							\
+	if (!(arg_len =3D get_int_arg(ptr,len, &(v))))			\
+		return -EINVAL;						\
+	ptr +=3D arg_len;							\
+	len -=3D arg_len;
+
+static int mptscsih_user_command(MPT_ADAPTER *ioc, char *buffer, int lengt=
h)
+{
+	char *ptr	=3D buffer;
+	struct mptscsih_usrcmd cmd, *uc =3D &cmd;
+	ulong		target;
+	int		arg_len;
+	int len		=3D length;
+
+	uc->target =3D uc->cmd =3D uc->lun =3D uc->data =3D 0;
+=09
+	if ((len > 0) && (ptr[len -1] =3D '\n'))
+		--len;
+
+	if ((arg_len =3D is_keyword(ptr, len, "getspeed")) !=3D 0)
+		uc->cmd =3D UC_GET_SPEED;
+	else
+		arg_len =3D 0;
+
+	dprintk(("user_command:  arg_len=3D%d, cmd=3D%ld\n", arg_len, uc->cmd));
+
+	if (!arg_len)
+		return -EINVAL;
+
+	ptr +=3D arg_len;
+	len -=3D arg_len;
+
+	switch(uc->cmd) {
+		case UC_GET_SPEED:
+			SKIP_SPACES(1);
+			GET_INT_ARG(target);
+			uc->target =3D target;
+			break;
+	}
+
+	dprintk(("user_command: target=3D%ld len=3D%d\n", uc->target, len));
+
+	if (len)
+		return -EINVAL;
+	else {
+		/* process this command ...
+		 */
+		mptscsih_exec_user_cmd(ioc, uc);
+	}
+	/* Not yet implemented */
+	return length;
+}
+
+/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
+/**
+ *	mptscsih_proc_info - Return information about MPT adapter
+ *
+ *	(linux Scsi_Host_Template.info routine)
+ *
+ * 	buffer: if write, user data; if read, buffer for user
+ * 	length: if write, return length;
+ * 	offset: if write, 0; if read, the current offset into the buffer from
+ * 		the previous read.
+ * 	hostno: scsi host number
+ *	func:   if write =3D 1; if read =3D 0
+ */
+int mptscsih_proc_info(char *buffer, char **start, off_t offset,
+			int length, int hostno, int func)
+{
+	MPT_ADAPTER	*ioc =3D NULL;
+	MPT_SCSI_HOST	*hd =3D NULL;
+	int size =3D 0;
+
+	dprintk(("Called mptscsih_proc_info: hostno=3D%d, func=3D%d\n", hostno, f=
unc));
+	dprintk(("buffer %p, start=3D%p (%p) offset=3D%ld length =3D %d\n",
+			buffer, start, *start, offset, length));
+
+	for (ioc =3D mpt_adapter_find_first(); ioc !=3D NULL; ioc =3D mpt_adapter=
_find_next(ioc)) {
+		if ((ioc->sh) && (ioc->sh->host_no =3D hostno)) {
+			hd =3D (MPT_SCSI_HOST *)ioc->sh->hostdata;
+			break;
+		}
+	}
+	if ((ioc =3D NULL) || (ioc->sh =3D NULL) || (hd =3D NULL))
+		return 0;
+
+	if (func) {
+		size =3D mptscsih_user_command(ioc, buffer, length);
+	} else {
+		if (start)
+			*start =3D buffer;
+
+		size =3D mptscsih_host_info(ioc, buffer, offset, length);
+	}
+
+	return size;
+}
+
+
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 	static int max_qd =3D 1;
 #if 0
@@ -1777,16 +2516,16 @@
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
  *	mptscsih_put_msgframe - Wrapper routine to post message frame to F/W.
- *	@context: Call back context (ScsiDoneCtx, ScsiScanDvCtx)=20
- *	@id: IOC id number=20
- *	@mf: Pointer to message frame=20
+ *	@context: Call back context (ScsiDoneCtx, ScsiScanDvCtx)
+ *	@id: IOC id number
+ *	@mf: Pointer to message frame
  *
- *	Handles the call to mptbase for posting request and queue depth=20
+ *	Handles the call to mptbase for posting request and queue depth
  *	tracking.
  *
  *	Returns none.
  */
-static void
+static inline void
 mptscsih_put_msgframe(int context, int id, MPT_FRAME_HDR *mf)
 {
 	/* Main banana... */
@@ -1973,12 +2712,11 @@
=20
 	/*
 	 *  Write SCSI CDB into the message
+	 *  Should write from cmd_len up to 16, but skip for performance reasons.
 	 */
 	cmd_len =3D SCpnt->cmd_len;
 	for (ii=3D0; ii < cmd_len; ii++)
 		pScsiReq->CDB[ii] =3D SCpnt->cmnd[ii];
-	for (ii=3Dcmd_len; ii < 16; ii++)
-		pScsiReq->CDB[ii] =3D 0;
=20
 	/* DataLength */
 	pScsiReq->DataLength =3D cpu_to_le32(datalen);
@@ -1993,7 +2731,7 @@
 	rc =3D SUCCESS;
 	if (datalen =3D 0) {
 		/* Add a NULL SGE */
-		mpt_add_sge((char *)&pScsiReq->SGL, MPT_SGE_FLAGS_SSIMPLE_READ | 0,
+		mptscsih_add_sge((char *)&pScsiReq->SGL, MPT_SGE_FLAGS_SSIMPLE_READ | 0,
 			(dma_addr_t) -1);
 	} else {
 		/* Add a 32 or 64 bit SGE */
@@ -2057,24 +2795,25 @@
 				}
=20
 #ifndef MPTSCSIH_DISABLE_DOMAIN_VALIDATION
-				if ((dvStatus & MPT_SCSICFG_NEED_DV) || hd->ioc->spi_data.forceDv) {
+				if ((dvStatus & MPT_SCSICFG_NEED_DV) ||
+					(hd->ioc->spi_data.forceDv & MPT_SCSICFG_NEED_DV)) {
 					unsigned long lflags;
 					/* Schedule DV if necessary */
 					spin_lock_irqsave(&dvtaskQ_lock, lflags);
 					if (!dvtaskQ_active) {
 						dvtaskQ_active =3D 1;
 						spin_unlock_irqrestore(&dvtaskQ_lock, lflags);
-						MPT_INIT_WORK(&mptscsih_dvTask, mptscsih_domainValidation, (void *) =
hd);=20
+						MPT_INIT_WORK(&mptscsih_dvTask, mptscsih_domainValidation, (void *) =
hd);
=20
 						SCHEDULE_TASK(&mptscsih_dvTask);
 					} else {
 						spin_unlock_irqrestore(&dvtaskQ_lock, lflags);
 					}
-					hd->ioc->spi_data.forceDv =3D 0;
+					hd->ioc->spi_data.forceDv &=3D ~MPT_SCSICFG_NEED_DV;
 				}
=20
 				/* Trying to do DV to this target, extend timeout.
-				 * Wait to issue intil flag is clear=20
+				 * Wait to issue intil flag is clear
 				 */
 				if (dvStatus & MPT_SCSICFG_DV_PENDING) {
 					mod_timer(&SCpnt->eh_timeout, jiffies + 40 * HZ);
@@ -2153,283 +2892,6 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
- *	mptscsih_AddSGE - Add a SGE (plus chain buffers) to the
- *	SCSIIORequest_t Message Frame.
- *	@hd: Pointer to MPT_SCSI_HOST structure
- *	@SCpnt: Pointer to Scsi_Cmnd structure
- *	@pReq: Pointer to SCSIIORequest_t structure
- *
- *	Returns ...
- */
-static int
-mptscsih_AddSGE(MPT_SCSI_HOST *hd, Scsi_Cmnd *SCpnt,
-				 SCSIIORequest_t *pReq, int req_idx)
-{
-	char 	*psge;
-	char	*chainSge;
-	struct scatterlist *sg;
-	int	 frm_sz;
-	int	 sges_left, sg_done;
-	int	 chain_idx =3D MPT_HOST_NO_CHAIN;
-	int	 sgeOffset;
-	int	 numSgeSlots, numSgeThisFrame;
-	u32	 sgflags, sgdir, thisxfer =3D 0;
-	int	 chain_dma_off =3D 0;
-	int	 newIndex;
-	int	 ii;
-	dma_addr_t v2;
-
-	sgdir =3D le32_to_cpu(pReq->Control) & MPI_SCSIIO_CONTROL_DATADIRECTION_M=
ASK;
-	if (sgdir =3D MPI_SCSIIO_CONTROL_WRITE)  {
-		sgdir =3D MPT_TRANSFER_HOST_TO_IOC;
-	} else {
-		sgdir =3D MPT_TRANSFER_IOC_TO_HOST;
-	}
-
-	psge =3D (char *) &pReq->SGL;
-	frm_sz =3D hd->ioc->req_sz;
-
-	/* Map the data portion, if any.
-	 * sges_left  =3D 0 if no data transfer.
-	 */
-	sges_left =3D SCpnt->use_sg;
-	if (SCpnt->use_sg) {
-		sges_left =3D pci_map_sg(hd->ioc->pcidev,
-			       (struct scatterlist *) SCpnt->request_buffer,
-			       SCpnt->use_sg,
-			       scsi_to_pci_dma_dir(SCpnt->sc_data_direction));
-	} else if (SCpnt->request_bufflen) {
-		dma_addr_t	 buf_dma_addr;
-		scPrivate	*my_priv;
-
-		buf_dma_addr =3D pci_map_single(hd->ioc->pcidev,
-				      SCpnt->request_buffer,
-				      SCpnt->request_bufflen,
-				      scsi_to_pci_dma_dir(SCpnt->sc_data_direction));
-
-		/* We hide it here for later unmap. */
-		my_priv =3D (scPrivate *) &SCpnt->SCp;
-		my_priv->p1 =3D (void *)(ulong) buf_dma_addr;
-
-		dsgprintk((MYIOC_s_INFO_FMT "SG: non-SG for %p, len=3D%d\n",
-				hd->ioc->name, SCpnt, SCpnt->request_bufflen));
-
-		mpt_add_sge((char *) &pReq->SGL,
-			0xD1000000|MPT_SGE_FLAGS_ADDRESSING|sgdir|SCpnt->request_bufflen,
-			buf_dma_addr);
-
-		return SUCCESS;
-	}
-
-	/* Handle the SG case.
-	 */
-	sg =3D (struct scatterlist *) SCpnt->request_buffer;
-	sg_done  =3D 0;
-	sgeOffset =3D sizeof(SCSIIORequest_t) - sizeof(SGE_IO_UNION);
-	chainSge =3D NULL;
-
-	/* Prior to entering this loop - the following must be set
-	 * current MF:  sgeOffset (bytes)
-	 *              chainSge (Null if original MF is not a chain buffer)
-	 *              sg_done (num SGE done for this MF)
-	 */
-
-nextSGEset:
-	numSgeSlots =3D ((frm_sz - sgeOffset) / (sizeof(u32) + sizeof(dma_addr_t)=
) );
-	numSgeThisFrame =3D (sges_left < numSgeSlots) ? sges_left : numSgeSlots;
-
-	sgflags =3D MPT_SGE_FLAGS_SIMPLE_ELEMENT | MPT_SGE_FLAGS_ADDRESSING | sgd=
ir;
-
-	/* Get first (num - 1) SG elements
-	 * Skip any SG entries with a length of 0
-	 * NOTE: at finish, sg and psge pointed to NEXT data/location positions
-	 */
-	for (ii=3D0; ii < (numSgeThisFrame-1); ii++) {
-		thisxfer =3D sg_dma_len(sg);
-		if (thisxfer =3D 0) {
-			sg ++; /* Get next SG element from the OS */
-			sg_done++;
-			continue;
-		}
-
-		v2 =3D sg_dma_address(sg);
-		mpt_add_sge(psge, sgflags | thisxfer, v2);
-
-		sg++;		/* Get next SG element from the OS */
-		psge +=3D (sizeof(u32) + sizeof(dma_addr_t));
-		sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
-		sg_done++;
-	}
-
-	if (numSgeThisFrame =3D sges_left) {
-		/* Add last element, end of buffer and end of list flags.
-		 */
-		sgflags |=3D MPT_SGE_FLAGS_LAST_ELEMENT |
-				MPT_SGE_FLAGS_END_OF_BUFFER |
-				MPT_SGE_FLAGS_END_OF_LIST;
-
-		/* Add last SGE and set termination flags.
-		 * Note: Last SGE may have a length of 0 - which should be ok.
-		 */
-		thisxfer =3D sg_dma_len(sg);
-
-		v2 =3D sg_dma_address(sg);
-		mpt_add_sge(psge, sgflags | thisxfer, v2);
-		/*
-		sg++;
-		psge +=3D (sizeof(u32) + sizeof(dma_addr_t));
-		*/
-		sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
-		sg_done++;
-
-		if (chainSge) {
-			/* The current buffer is a chain buffer,
-			 * but there is not another one.
-			 * Update the chain element
-			 * Offset and Length fields.
-			 */
-			mpt_add_chain((char *)chainSge, 0, sgeOffset, hd->ChainBufferDMA + chai=
n_dma_off);
-		} else {
-			/* The current buffer is the original MF
-			 * and there is no Chain buffer.
-			 */
-			pReq->ChainOffset =3D 0;
-		}
-	} else {
-		/* At least one chain buffer is needed.
-		 * Complete the first MF
-		 *  - last SGE element, set the LastElement bit
-		 *  - set ChainOffset (words) for orig MF
-		 *             (OR finish previous MF chain buffer)
-		 *  - update MFStructPtr ChainIndex
-		 *  - Populate chain element
-		 * Also
-		 * Loop until done.
-		 */
-
-		dsgprintk((MYIOC_s_INFO_FMT "SG: Chain Required! sg done %d\n",
-				hd->ioc->name, sg_done));
-
-		/* Set LAST_ELEMENT flag for last non-chain element
-		 * in the buffer. Since psge points at the NEXT
-		 * SGE element, go back one SGE element, update the flags
-		 * and reset the pointer. (Note: sgflags & thisxfer are already
-		 * set properly).
-		 */
-		if (sg_done) {
-			u32 *ptmp =3D (u32 *) (psge - (sizeof(u32) + sizeof(dma_addr_t)));
-			sgflags =3D le32_to_cpu(*ptmp);
-			sgflags |=3D MPT_SGE_FLAGS_LAST_ELEMENT;
-			*ptmp =3D cpu_to_le32(sgflags);
-		}
-
-		if (chainSge) {
-			/* The current buffer is a chain buffer.
-			 * chainSge points to the previous Chain Element.
-			 * Update its chain element Offset and Length (must
-			 * include chain element size) fields.
-			 * Old chain element is now complete.
-			 */
-			u8 nextChain =3D (u8) (sgeOffset >> 2);
-			sgeOffset +=3D (sizeof(u32) + sizeof(dma_addr_t));
-			mpt_add_chain((char *)chainSge, nextChain, sgeOffset, hd->ChainBufferDM=
A + chain_dma_off);
-		} else {
-			/* The original MF buffer requires a chain buffer -
-			 * set the offset.
-			 * Last element in this MF is a chain element.
-			 */
-			pReq->ChainOffset =3D (u8) (sgeOffset >> 2);
-		}
-
-		sges_left -=3D sg_done;
-
-
-		/* NOTE: psge points to the beginning of the chain element
-		 * in current buffer. Get a chain buffer.
-		 */
-		if ((mptscsih_getFreeChainBuffer(hd, &newIndex)) =3D FAILED)
-			return FAILED;
-
-		/* Update the tracking arrays.
-		 * If chainSge =3D NULL, update ReqToChain, else ChainToChain
-		 */
-		if (chainSge) {
-			hd->ChainToChain[chain_idx] =3D newIndex;
-		} else {
-			hd->ReqToChain[req_idx] =3D newIndex;
-		}
-		chain_idx =3D newIndex;
-		chain_dma_off =3D hd->ioc->req_sz * chain_idx;
-
-		/* Populate the chainSGE for the current buffer.
-		 * - Set chain buffer pointer to psge and fill
-		 *   out the Address and Flags fields.
-		 */
-		chainSge =3D (char *) psge;
-		dsgprintk((KERN_INFO "  Current buff @ %p (index 0x%x)",
-				psge, req_idx));
-
-		/* Start the SGE for the next buffer
-		 */
-		psge =3D (char *) (hd->ChainBuffer + chain_dma_off);
-		sgeOffset =3D 0;
-		sg_done =3D 0;
-
-		dsgprintk((KERN_INFO "  Chain buff @ %p (index 0x%x)\n",
-				psge, chain_idx));
-
-		/* Start the SGE for the next buffer
-		 */
-
-		goto nextSGEset;
-	}
-
-	return SUCCESS;
-}
-
-/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
-/*
- *	mptscsih_getFreeChainBuffes - Function to get a free chain
- *	from the MPT_SCSI_HOST FreeChainQ.
- *	@hd: Pointer to the MPT_SCSI_HOST instance
- *	@req_idx: Index of the SCSI IO request frame. (output)
- *
- *	return SUCCESS or FAILED
- */
-static int
-mptscsih_getFreeChainBuffer(MPT_SCSI_HOST *hd, int *retIndex)
-{
-	MPT_FRAME_HDR *chainBuf =3D NULL;
-	unsigned long flags;
-	int rc =3D FAILED;
-	int chain_idx =3D MPT_HOST_NO_CHAIN;
-
-	//spin_lock_irqsave(&hd->FreeChainQlock, flags);
-	spin_lock_irqsave(&hd->ioc->FreeQlock, flags);
-	if (!Q_IS_EMPTY(&hd->FreeChainQ)) {
-
-		int offset;
-
-		chainBuf =3D hd->FreeChainQ.head;
-		Q_DEL_ITEM(&chainBuf->u.frame.linkage);
-		offset =3D (u8 *)chainBuf - (u8 *)hd->ChainBuffer;
-		chain_idx =3D offset / hd->ioc->req_sz;
-		rc =3D SUCCESS;
-	}
-	//spin_unlock_irqrestore(&hd->FreeChainQlock, flags);
-	spin_unlock_irqrestore(&hd->ioc->FreeQlock, flags);
-
-
-	*retIndex =3D chain_idx;
-
-	dsgprintk((MYIOC_s_INFO_FMT "getFreeChainBuffer (index %d), got buf=3D%p\=
n",
-			hd->ioc->name, *retIndex, chainBuf));
-
-	return rc;
-}
-
-/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
-/*
  *	mptscsih_freeChainBuffers - Function to free chain buffers associated
  *	with a SCSI IO request
  *	@hd: Pointer to the MPT_SCSI_HOST instance
@@ -2547,8 +3009,8 @@
=20
 #ifdef MPT_DEBUG_RESET
 	if ((ioc_raw_state & MPI_IOC_STATE_MASK) !=3D MPI_IOC_STATE_OPERATIONAL) {
-		printk(MYIOC_s_WARN_FMT=20
-			"TM Handler: IOC Not operational! state 0x%x Calling HardResetHandler\n=
",=20
+		printk(MYIOC_s_WARN_FMT
+			"TM Handler: IOC Not operational! state 0x%x Calling HardResetHandler\n=
",
 			hd->ioc->name, ioc_raw_state);
 	}
 #endif
@@ -2765,7 +3227,7 @@
=20
 	hd->abortSCpnt =3D SCpnt;
 	if (mptscsih_TMHandler(hd, MPI_SCSITASKMGMT_TASKTYPE_ABORT_TASK,
-	                       SCpnt->target, SCpnt->lun, ctx2abort, NO_SLEEP)=20
+	                       SCpnt->target, SCpnt->lun, ctx2abort, NO_SLEEP)
 		< 0) {
=20
 		/* The TM request failed and the subsequent FW-reload failed!
@@ -2830,7 +3292,7 @@
 	}
=20
 	if (mptscsih_TMHandler(hd, MPI_SCSITASKMGMT_TASKTYPE_TARGET_RESET,
-	                       SCpnt->target, 0, 0, NO_SLEEP)=20
+	                       SCpnt->target, 0, 0, NO_SLEEP)
 		< 0){
 		/* The TM request failed and the subsequent FW-reload failed!
 		 * Fatal error case.
@@ -2889,13 +3351,13 @@
=20
 	/* We are now ready to execute the task management request. */
 	if (mptscsih_TMHandler(hd, MPI_SCSITASKMGMT_TASKTYPE_RESET_BUS,
-	                       0, 0, 0, NO_SLEEP)=20
+	                       0, 0, 0, NO_SLEEP)
 	    < 0){
=20
 		/* The TM request failed and the subsequent FW-reload failed!
 		 * Fatal error case.
 		 */
-		printk(MYIOC_s_WARN_FMT=20
+		printk(MYIOC_s_WARN_FMT
 		       "Error processing TaskMgmt request (sc=3D%p)\n",
 		       hd->ioc->name, SCpnt);
 		hd->tmPending =3D 0;
@@ -2941,8 +3403,8 @@
 	if (mpt_HardResetHandler(hd->ioc, NO_SLEEP) < 0){
 		status =3D FAILED;
 	} else {
-		/*  Make sure TM pending is cleared and TM state is set to=20
-		 *  NONE.=20
+		/*  Make sure TM pending is cleared and TM state is set to
+		 *  NONE.
 		 */
 		hd->tmPending =3D 0;
 		hd->tmState =3D TM_STATE_NONE;
@@ -2958,7 +3420,7 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /**
- *	mptscsih_tm_pending_wait - wait for pending task management request to =

+ *	mptscsih_tm_pending_wait - wait for pending task management request to
  *		complete.
  *	@hd: Pointer to MPT host structure.
  *
@@ -3114,7 +3576,7 @@
 		 *  (bottom/unused portion of) MPT request frame.
 		 */
 		ptaskfoo =3D (struct mpt_work_struct *) &mptscsih_ptaskfoo;
-		MPT_INIT_WORK(&mptscsih_ptaskfoo, mptscsih_taskmgmt_bh, (void *) SCpnt);=
=20
+		MPT_INIT_WORK(&mptscsih_ptaskfoo, mptscsih_taskmgmt_bh, (void *) SCpnt);
=20
 		SCHEDULE_TASK(ptaskfoo);
 	} else  {
@@ -3245,7 +3707,7 @@
 		 *  (bottom/unused portion of) MPT request frame.
 		 */
 		ptaskfoo =3D (struct mpt_work_struct *) &mptscsih_ptaskfoo;
-		MPT_INIT_WORK(&mptscsih_ptaskfoo, mptscsih_taskmgmt_bh, (void *) SCpnt);=
=20
+		MPT_INIT_WORK(&mptscsih_ptaskfoo, mptscsih_taskmgmt_bh, (void *) SCpnt);
=20
 		SCHEDULE_TASK(ptaskfoo);
 	} else  {
@@ -3599,7 +4061,7 @@
  *	Called once per device the bus scan. Use it to force the queue_depth
  *	member to 1 if a device does not support Q tags.
  */
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,44)
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52)
 int
 mptscsih_slave_configure(Scsi_Device *device)
 {
@@ -3614,15 +4076,21 @@
 			if (!device->tagged_supported ||
 			    !(pTarget->tflags & MPT_TARGET_FLAGS_Q_YES)) {
 				scsi_adjust_queue_depth(device, 0, 1);
+
+			} else if ((pTarget->tflags & MPT_TARGET_FLAGS_VALID_INQUIRY)
+				   && (pTarget->inq_data[0] & 0x1f) =3D 0x00
+				   && (pTarget->minSyncFactor <=3D MPT_ULTRA160 || !hd->is_spi)) {
+				scsi_adjust_queue_depth(device, MSG_SIMPLE_TAG,
+							MPT_SCSI_CMD_PER_DEV_HIGH);
 			} else {
-				scsi_adjust_queue_depth(device, MSG_SIMPLE_TAG,=20
-							device->host->can_queue >> 1);
+				scsi_adjust_queue_depth(device, MSG_SIMPLE_TAG,
+							MPT_SCSI_CMD_PER_DEV_LOW);
 			}
 		}
 	}
 	return 0;
 }
-#else /* LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,44) */
+#else /* LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52) */
 void
 mptscsih_select_queue_depths(struct Scsi_Host *sh, Scsi_Device *sdList)
 {
@@ -3648,113 +4116,32 @@
=20
 			for (ii=3D0; ii < max; ii++) {
 				pTarget =3D hd->Targets[ii];
-				if (pTarget && !(pTarget->tflags & MPT_TARGET_FLAGS_Q_YES)) {
+				if (pTarget =3D NULL) {
+					continue;
+				}
+				if (!(pTarget->tflags & MPT_TARGET_FLAGS_Q_YES)) {
 					device->queue_depth =3D 1;
+				} else if ((pTarget->tflags & MPT_TARGET_FLAGS_VALID_INQUIRY)
+					   && (pTarget->inq_data[0] & 0x1f) =3D 0x00
+					   && (pTarget->minSyncFactor <=3D MPT_ULTRA160 || !hd->is_spi)) {
+					device->queue_depth =3D MPT_SCSI_CMD_PER_DEV_HIGH;
+				} else {
+					device->queue_depth =3D MPT_SCSI_CMD_PER_DEV_LOW;
 				}
+				dprintk((MYIOC_s_INFO_FMT
+					 "target =3D %d, sync factor =3D %#x, queue depth =3D %d\n",
+					 hd->ioc->name, pTarget->target_id,
+					 pTarget->minSyncFactor, device->queue_depth));
 			}
 		}
 	}
 }
-#endif /* LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,44) */
+#endif /* LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52) */
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
  *  Private routines...
  */
-/*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
-/* 19991030 -sralston
- *  Return absolute SCSI data direction:
- *     1 =3D _DATA_OUT
- *     0 =3D _DIR_NONE
- *    -1 =3D _DATA_IN
- *
- * Changed: 3-20-2002 pdelaney to use the default data
- * direction and the defines set up in the
- * 2.4 kernel series
- *     1 =3D _DATA_OUT	changed to SCSI_DATA_WRITE (1)
- *     0 =3D _DIR_NONE	changed to SCSI_DATA_NONE (3)
- *    -1 =3D _DATA_IN	changed to SCSI_DATA_READ (2)
- * If the direction is unknown, fall through to original code.
- *
- * Mid-layer bug fix(): sg interface generates the wrong data=20
- * direction in some cases. Set the direction the hard way for=20
- * the most common commands.
- */
-static int
-mptscsih_io_direction(Scsi_Cmnd *cmd)
-{
-	switch (cmd->cmnd[0]) {
-	case WRITE_6:	=09
-	case WRITE_10:	=09
-		return SCSI_DATA_WRITE;
-		break;
-	case READ_6:	=09
-	case READ_10:	=09
-		return SCSI_DATA_READ;
-		break;
-	}
-
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,4,0)
-	if (cmd->sc_data_direction !=3D SCSI_DATA_UNKNOWN)
-		return cmd->sc_data_direction;
-#endif
-	switch (cmd->cmnd[0]) {
-	/*  _DATA_OUT commands	*/
-	case WRITE_6:		case WRITE_10:		case WRITE_12:
-	case WRITE_LONG:	case WRITE_SAME:	case WRITE_BUFFER:
-	case WRITE_VERIFY:	case WRITE_VERIFY_12:
-	case COMPARE:		case COPY:		case COPY_VERIFY:
-	case SEARCH_EQUAL:	case SEARCH_HIGH:	case SEARCH_LOW:
-	case SEARCH_EQUAL_12:	case SEARCH_HIGH_12:	case SEARCH_LOW_12:
-	case MODE_SELECT:	case MODE_SELECT_10:	case LOG_SELECT:
-	case SEND_DIAGNOSTIC:	case CHANGE_DEFINITION: case UPDATE_BLOCK:
-	case SET_WINDOW:	case MEDIUM_SCAN:	case SEND_VOLUME_TAG:
-	case REASSIGN_BLOCKS:
-	case PERSISTENT_RESERVE_OUT:
-	case 0xea:
-	case 0xa3:
-		return SCSI_DATA_WRITE;
-
-	/*  No data transfer commands  */
-	case SEEK_6:		case SEEK_10:
-	case RESERVE:		case RELEASE:
-	case TEST_UNIT_READY:
-	case START_STOP:
-	case ALLOW_MEDIUM_REMOVAL:
-		return SCSI_DATA_NONE;
-
-	/*  Conditional data transfer commands	*/
-	case FORMAT_UNIT:
-		if (cmd->cmnd[1] & 0x10)	/* FmtData (data out phase)? */
-			return SCSI_DATA_WRITE;
-		else
-			return SCSI_DATA_NONE;
-
-	case VERIFY:
-		if (cmd->cmnd[1] & 0x02)	/* VERIFY:BYTCHK (data out phase)? */
-			return SCSI_DATA_WRITE;
-		else
-			return SCSI_DATA_NONE;
-
-	case RESERVE_10:
-		if (cmd->cmnd[1] & 0x03)	/* RESERVE:{LongID|Extent} (data out phase)? */
-			return SCSI_DATA_WRITE;
-		else
-			return SCSI_DATA_NONE;
-
-#if 0
-	case REZERO_UNIT:	/* (or REWIND) */
-	case SPACE:
-	case ERASE:		case ERASE_10:
-	case SYNCHRONIZE_CACHE:
-	case LOCK_UNLOCK_CACHE:
-#endif
-
-	/*  Must be data _IN!  */
-	default:
-		return SCSI_DATA_READ;
-	}
-}
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /* Utility function to copy sense data from the scsi_cmnd buffer
@@ -3803,7 +4190,7 @@
=20
 #ifdef ABORT_FIX
 			if (sz >=3D SCSI_STD_SENSE_BYTES) {
-				if ((sense_data[02] =3D ABORTED_COMMAND) &&=20
+				if ((sense_data[02] =3D ABORTED_COMMAND) &&
 					(sense_data[12] =3D 0x47) && (sense_data[13] =3D 0x00)){
 					target->numAborts++;
 					if ((target->raidVolume =3D 0) && (target->numAborts > 5)) {
@@ -3896,7 +4283,7 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /* Search the pendingQ for a command with specific index.
- * If found, delete and return mf pointer =20
+ * If found, delete and return mf pointer
  * If not found, return NULL
  */
 static MPT_FRAME_HDR *
@@ -4126,6 +4513,13 @@
=20
 		dtmprintk((MYIOC_s_WARN_FMT "Post-Reset handling complete.\n",
 			ioc->name));
+
+
+		/* 8. Set flag to force DV and re-read IOC Page 3
+		 */
+		ioc->spi_data.forceDv =3D MPT_SCSICFG_NEED_DV | MPT_SCSICFG_RELOAD_IOC_P=
G3;
+		ddvtprintk(("Set reload IOC Pg3 Flag\n"));
+
 	}
=20
 	return 1;		/* currently means nothing really */
@@ -4172,7 +4566,7 @@
=20
 	case MPI_EVENT_INTEGRATED_RAID:			/* 0B */
 #ifndef MPTSCSIH_DISABLE_DOMAIN_VALIDATION
-		/* negoNvram set to 0 if DV enabled and to USE_NVRAM if=20
+		/* negoNvram set to 0 if DV enabled and to USE_NVRAM if
 		 * if DV disabled. Need to check for target mode.
 		 */
 		hd =3D NULL;
@@ -4188,11 +4582,12 @@
 		=09
 			reason =3D (le32_to_cpu(pEvReply->Data[0]) & 0x00FF0000) >> 16;
 			if (reason =3D MPI_EVENT_RAID_RC_DOMAIN_VAL_NEEDED) {
-				/* New or replaced disk.=20
+				/* New or replaced disk.
 				 * Set DV flag and schedule DV.
 				 */
 				pSpi =3D &ioc->spi_data;
 				physDiskNum =3D (le32_to_cpu(pEvReply->Data[0]) & 0xFF000000) >> 24;
+				ddvtprintk(("DV requested for phys disk id %d\n", physDiskNum));
 				if (pSpi->pIocPg3) {
 					pPDisk =3D  pSpi->pIocPg3->PhysDisk;
 					numPDisk =3DpSpi->pIocPg3->NumPhysDisks;
@@ -4207,6 +4602,16 @@
 						pPDisk++;
 						numPDisk--;
 					}
+
+					if (numPDisk =3D 0) {
+						/* The physical disk that needs DV was not found
+						 * in the stored IOC Page 3. The driver must reload
+						 * this page. DV routine will set the NEED_DV flag for
+						 * all phys disks that have DV_NOT_DONE set.
+						 */
+						pSpi->forceDv =3D MPT_SCSICFG_NEED_DV | MPT_SCSICFG_RELOAD_IOC_PG3;
+						ddvtprintk(("phys disk %d not found. Setting reload IOC Pg3 Flag\n",=
 physDiskNum));
+					}
 				}
 			}
 		}
@@ -4670,7 +5075,7 @@
 		if (ioop->cdbPtr =3D NULL) {
 			return 0;
 		} else if ((ioop->cdbPtr[0] =3D CMD_TestUnitReady) ||
-			(ioop->cdbPtr[0] =3D CMD_ReadCapacity) ||=20
+			(ioop->cdbPtr[0] =3D CMD_ReadCapacity) ||
 			(ioop->cdbPtr[0] =3D 0x43)) {
 			return 0;
 		}
@@ -4794,7 +5199,7 @@
 	}
=20
 	if (vdev && data) {
-		if ((!(vdev->tflags & MPT_TARGET_FLAGS_VALID_INQUIRY)) ||=20
+		if ((!(vdev->tflags & MPT_TARGET_FLAGS_VALID_INQUIRY)) ||
 		((dlen > 56) && (!(vdev->tflags & MPT_TARGET_FLAGS_VALID_56)))) {
=20
 			/* Copy the inquiry data  - if we haven't yet.
@@ -4877,7 +5282,7 @@
 					factor =3D MPT_ULTRA320;
=20
 				/* If RAID, never disable QAS
-				 * else if non RAID, do not disable=20
+				 * else if non RAID, do not disable
 				 *   QAS if bit 1 is set
 				 * bit 1 QAS support, non-raid only
 				 * bit 0 IU support
@@ -5000,8 +5405,8 @@
 #endif
=20
 /* If DV disabled (negoNvram set to USE_NVARM) or if not LUN 0, return.
- * Else set the NEED_DV flag after Read Capacity Issued (disks)=20
- * or Mode Sense (cdroms).=20
+ * Else set the NEED_DV flag after Read Capacity Issued (disks)
+ * or Mode Sense (cdroms).
  *
  * Tapes, initTarget will set this flag on completion of Inquiry command.
  * Called only if DV_NOT_DONE flag is set
@@ -5037,7 +5442,7 @@
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
- * If no Target, bus reset on 1st I/O. Set the flag to=20
+ * If no Target, bus reset on 1st I/O. Set the flag to
  * prevent any future negotiations to this device.
  */
 static void mptscsih_no_negotiate(MPT_SCSI_HOST *hd, int target_id)
@@ -5286,9 +5691,9 @@
 		pData->Reserved =3D 0;
 		pData->Configuration =3D cpu_to_le32(configuration);
=20
-		dprintk((MYIOC_s_INFO_FMT=20
+		dprintk((MYIOC_s_INFO_FMT
 			"write SDP1: id %d pgaddr 0x%x req 0x%x config 0x%x\n",
-				ioc->name, id, (id | (bus<<8)),=20
+				ioc->name, id, (id | (bus<<8)),
 				requested, configuration));
=20
 		mptscsih_put_msgframe(ScsiDoneCtx, ioc->id, mf);
@@ -5327,8 +5732,8 @@
 		/* Because we have reset the IOC, no TM requests can be
 		 * pending.  So let's make sure the tmPending flag is reset.
 		 */
-		nehprintk((KERN_WARNING MYNAM=20
-			   ": %s: mptscsih_taskmgmt_timeout\n",=20
+		nehprintk((KERN_WARNING MYNAM
+			   ": %s: mptscsih_taskmgmt_timeout\n",
 			   hd->ioc->name));
 		hd->tmPending =3D 0;
 	}
@@ -5566,7 +5971,7 @@
 			if (hd->tmPending) {
 				spin_unlock_irqrestore(&hd->ioc->FreeQlock, flags);
 				return;
-			} else=20
+			} else
 				hd->tmPending =3D 1;
 			spin_unlock_irqrestore(&hd->ioc->FreeQlock, flags);
=20
@@ -5645,7 +6050,7 @@
 	pReq->ActionDataWord =3D 0; /* Reserved for this action */
 	//pReq->ActionDataSGE =3D 0;
=20
-	mpt_add_sge((char *)&pReq->ActionDataSGE,=20
+	mpt_add_sge((char *)&pReq->ActionDataSGE,
 		MPT_SGE_FLAGS_SSIMPLE_READ | 0, (dma_addr_t) -1);
=20
 	ddvprintk((MYIOC_s_INFO_FMT "RAID Volume action %x id %d\n",
@@ -5974,7 +6379,7 @@
 	if (id =3D hostId)
 		id++;
=20
-	/* Write SDP1 for all SCSI devices=20
+	/* Write SDP1 for all SCSI devices
 	 * Alloc memory and set up config buffer
 	 */
 	if (hd->is_spi) {
@@ -6097,7 +6502,7 @@
 	spin_unlock_irqrestore(&dvtaskQ_lock, flags);
=20
 	/* For this ioc, loop through all devices and do dv to each device.
-	 * When complete with this ioc, search through the ioc list, and=20
+	 * When complete with this ioc, search through the ioc list, and
 	 * for each scsi ioc found, do dv for all devices. Exit when no
 	 * device needs dv.
 	 */
@@ -6128,6 +6533,23 @@
 			if (hd =3D NULL)
 				continue;
=20
+			if ((ioc->spi_data.forceDv & MPT_SCSICFG_RELOAD_IOC_PG3) !=3D 0) {
+				mpt_read_ioc_pg_3(ioc);
+				if (ioc->spi_data.pIocPg3) {
+					Ioc3PhysDisk_t *pPDisk =3D ioc->spi_data.pIocPg3->PhysDisk;
+					int		numPDisk =3D ioc->spi_data.pIocPg3->NumPhysDisks;
+
+					while (numPDisk) {
+						if (ioc->spi_data.dvStatus[pPDisk->PhysDiskID] & MPT_SCSICFG_DV_NOT_=
DONE)
+							ioc->spi_data.dvStatus[pPDisk->PhysDiskID] |=3D MPT_SCSICFG_NEED_DV;
+
+						pPDisk++;
+						numPDisk--;
+					}
+				}
+				ioc->spi_data.forceDv &=3D ~MPT_SCSICFG_RELOAD_IOC_PG3;
+			}
+
 			maxid =3D MIN (ioc->sh->max_id, MPT_MAX_SCSI_DEVICES);
=20
 			for (id =3D 0; id < maxid; id++) {
@@ -6318,7 +6740,7 @@
=20
 	lun =3D 0;
 	bus =3D 0;
-	ddvtprintk((MYIOC_s_NOTE_FMT=20
+	ddvtprintk((MYIOC_s_NOTE_FMT
 			"DV started: numIOs %d bus=3D%d, id %d dv @ %p\n",
 			ioc->name, atomic_read(&queue_depth), bus, id, &dv));
=20
@@ -6423,7 +6845,7 @@
 	/* Skip this ID? Set cfg.hdr to force config page write
 	 */
 	if ((ioc->spi_data.nvram[id] !=3D MPT_HOST_NVRAM_INVALID) &&
-			(!(ioc->spi_data.nvram[id] & MPT_NVRAM_ID_SCAN_ENABLE))) {=20
+			(!(ioc->spi_data.nvram[id] & MPT_NVRAM_ID_SCAN_ENABLE))) {
=20
 		ddvprintk((MYIOC_s_NOTE_FMT "DV Skipped: bus, id, lun (%d, %d, %d)\n",
 			ioc->name, bus, id, lun));
@@ -6495,11 +6917,11 @@
=20
 		/* Wide - narrow - wide workaround case
 		 */
-		if ((rc =3D MPT_SCANDV_ISSUE_SENSE) && dv.max.width) {=20
+		if ((rc =3D MPT_SCANDV_ISSUE_SENSE) && dv.max.width) {
 			/* Send an untagged command to reset disk Qs corrupted
 			 * when a parity error occurs on a Request Sense.
 			 */
-			if ((hd->ioc->facts.FWVersion.Word >=3D 0x01000600) ||=20
+			if ((hd->ioc->facts.FWVersion.Word >=3D 0x01000600) ||
 				((hd->ioc->facts.FWVersion.Word >=3D 0x01010000) &&
 				(hd->ioc->facts.FWVersion.Word < 0x01010B00)) ) {
=20
@@ -6535,7 +6957,11 @@
 			rc =3D hd->pLocal->completion;
 			if (rc =3D MPT_SCANDV_GOOD) {
 				if (hd->pLocal->scsiStatus =3D STS_BUSY) {
-					retcode =3D 1;
+					if ((iocmd.flags & MPT_ICFLAG_TAGGED_CMD) =3D 0)
+						retcode =3D 1;
+					else
+						retcode =3D 0;
+
 					goto target_done;
 				}
 			} else if  (rc =3D MPT_SCANDV_SENSE) {
@@ -6607,7 +7033,7 @@
 					 * Fujitsu: PPR U320 -> Msg Reject and Ultra2 and wide
 					 * Resetart with a request for U160.
 					 */
-					if ((dv.now.factor =3D MPT_ULTRA320) && (sdp0_nego =3D MPT_ULTRA2)) {=
=20
+					if ((dv.now.factor =3D MPT_ULTRA320) && (sdp0_nego =3D MPT_ULTRA2)) {
 							doFallback =3D 1;
 					} else {
 						dv.cmd =3D MPT_UPDATE_MAX;
@@ -6631,7 +7057,7 @@
 				}
=20
=20
-			} else if (rc =3D MPT_SCANDV_ISSUE_SENSE)=20
+			} else if (rc =3D MPT_SCANDV_ISSUE_SENSE)
 				doFallback =3D 1;	/* set fallback flag */
 			else if ((rc =3D MPT_SCANDV_DID_RESET) || (rc =3D MPT_SCANDV_SENSE))
 				doFallback =3D 1;	/* set fallback flag */
@@ -6871,7 +7297,7 @@
 						mdelay (2000);
 						notDone++;
 					} else {
-						ddvprintk((MYIOC_s_INFO_FMT=20
+						ddvprintk((MYIOC_s_INFO_FMT
 							"DV: Reserved Failed.", ioc->name));
 						goto target_done;
 					}
@@ -6935,7 +7361,7 @@
 							patt =3D -1;
 							continue;
 						}
-					}=20
+					}
 					goto target_done;
 				}
 				else
@@ -7048,7 +7474,7 @@
 			if (hd->pLocal->completion =3D MPT_SCANDV_GOOD)
 				iocmd.flags &=3D ~MPT_ICFLAG_RESERVED;
 		} else {
-			printk(MYIOC_s_INFO_FMT "DV: Release failed. id %d",=20
+			printk(MYIOC_s_INFO_FMT "DV: Release failed. id %d",
 						ioc->name, id);
 		}
 	}
@@ -7066,7 +7492,7 @@
 		mptscsih_dv_parms(hd, &dv, (void *)pcfg1Data);
=20
 #if 0=09
-	/* Double writes to SDP1 can cause problems,=20
+	/* Double writes to SDP1 can cause problems,
 	 * skip here since unnecessary
 	 */
 		/* Save the final negotiated settings to
@@ -7222,7 +7648,7 @@
 	case MPT_SET_MIN:
 		ddvprintk((MYIOC_s_NOTE_FMT "Setting Min: ",
 								hd->ioc->name));
-		/* Set page to asynchronous and narrow=20
+		/* Set page to asynchronous and narrow
 		 * Do not update now, breaks fallback routine. */
 		width =3D MPT_NARROW;
 		offset =3D 0;
@@ -7244,7 +7670,7 @@
 	case MPT_FALLBACK:
 		ddvprintk((MYIOC_s_NOTE_FMT
 			"Fallback: Start: offset %d, factor %x, width %d \n",
-				hd->ioc->name, dv->now.offset,=20
+				hd->ioc->name, dv->now.offset,
 				dv->now.factor, dv->now.width));
 		width =3D dv->now.width;
 		offset =3D dv->now.offset;
diff -Nru a/drivers/message/fusion/mptscsih.h b/drivers/message/fusion/mpts=
csih.h
--- a/drivers/message/fusion/mptscsih.h	Thu Jan  2 15:40:31 2003
+++ b/drivers/message/fusion/mptscsih.h	Thu Jan  2 15:40:31 2003
@@ -20,7 +20,7 @@
  *  (mailto:netscape.net)
  *  (mailto:Pam.Delaney@lsil.com)
  *
- *  $Id: mptscsih.h,v 1.20 2002/10/17 20:16:00 pdelaney Exp $
+ *  $Id: mptscsih.h,v 1.21 2002/12/03 21:26:35 pdelaney Exp $
  */
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -73,9 +73,16 @@
  *	Try to keep these at 2^N-1
  */
 #define MPT_FC_CAN_QUEUE	63
-//#define MPT_SCSI_CAN_QUEUE	31
-#define MPT_SCSI_CAN_QUEUE	MPT_FC_CAN_QUEUE
-#define MPT_SCSI_CMD_PER_LUN	 7
+#if defined MPT_SCSI_USE_NEW_EH
+	#define MPT_SCSI_CAN_QUEUE	127
+#else
+	#define MPT_SCSI_CAN_QUEUE	63
+#endif
+
+#define MPT_SCSI_CMD_PER_DEV_HIGH	31
+#define MPT_SCSI_CMD_PER_DEV_LOW	7
+
+#define MPT_SCSI_CMD_PER_LUN		7
=20
 #define MPT_SCSI_MAX_SECTORS    8192
=20
@@ -206,11 +213,16 @@
 #define x_scsi_dev_reset	mptscsih_dev_reset
 #define x_scsi_host_reset	mptscsih_host_reset
 #define x_scsi_bios_param	mptscsih_bios_param
-#define x_scsi_slave_configure	mptscsih_slave_configure
=20
 #define x_scsi_taskmgmt_bh	mptscsih_taskmgmt_bh
 #define x_scsi_old_abort	mptscsih_old_abort
 #define x_scsi_old_reset	mptscsih_old_reset
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52)
+#define x_scsi_slave_configure	mptscsih_slave_configure
+#else
+#define x_scsi_select_queue_depths	mptscsih_select_queue_depths
+#endif
+#define x_scsi_proc_info	mptscsih_proc_info
=20
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
 /*
@@ -237,8 +249,14 @@
 #else
 extern	int		 x_scsi_bios_param(Disk *, kdev_t, int *);
 #endif
-extern	int		 x_scsi_slave_configure(Scsi_Device *);
 extern	void		 x_scsi_taskmgmt_bh(void *);
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52)
+extern	int		 x_scsi_slave_configure(Scsi_Device *);
+#else
+extern	void		 x_scsi_select_queue_depths(struct Scsi_Host *, Scsi_Device *=
);
+#endif
+
+extern	int		 x_scsi_proc_info(char *, char **, off_t, int, int, int);
=20
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,0)
 #define PROC_SCSI_DECL
@@ -248,14 +266,19 @@
=20
 #ifdef MPT_SCSI_USE_NEW_EH
=20
-#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,44)
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,5,52)
=20
 #define MPT_SCSIHOST {						\
 	PROC_SCSI_DECL						\
+	.proc_info			=3D x_scsi_proc_info,	\
 	.name				=3D "MPT SCSI Host",	\
 	.detect				=3D x_scsi_detect,	\
 	.release			=3D x_scsi_release,	\
 	.info				=3D x_scsi_info,		\
+	.command			=3D NULL,			\
+	.queuecommand			=3D x_scsi_queuecommand,	\
+	.slave_configure		=3D x_scsi_slave_configure,	\
+	.eh_strategy_handler		=3D NULL,			\
 	.eh_abort_handler		=3D x_scsi_abort,		\
 	.eh_device_reset_handler	=3D x_scsi_dev_reset,	\
 	.eh_bus_reset_handler		=3D x_scsi_bus_reset,	\
@@ -275,6 +298,7 @@
 #define MPT_SCSIHOST {						\
 	.next				=3D NULL,			\
 	PROC_SCSI_DECL						\
+	.proc_info			=3D x_scsi_proc_info,	\
 	.name				=3D "MPT SCSI Host",	\
 	.detect				=3D x_scsi_detect,	\
 	.release			=3D x_scsi_release,	\

