From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 25 Apr 2003 21:02:20 +0000
Subject: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
MIME-Version: 1
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Message-Id: <marc-linux-ia64-105590723705611@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
To: linux-ia64@vger.kernel.org

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 17, 2003 at 04:05:29PM -0700, David Mosberger wrote:
> I don't have an issue with the particular patch, but I don't like to
> take new features incrementally.  At the moment, the normal ia64
> kernel doesn't support loading at arbitrary physical addresses.  If
> there is a complete patch to add such a feature, we should consider it
> for inclusion.

Chris Wedgwood reminded me that Tony posted one awhile back.  I wonder
what you think of his approach?  I've attached it for reference since
the linux-ia64 archive only had a mangled copy.  It's against 2.5.39.
If you have any other ideas about how we can address this, I'd like to
hear them.  Ideally, a generic kernel would work on all ia64 platforms
at the same virtual load address (which is one problem with Tony's old
patch IMO), regardless of physical load address.

Thanks a lot,
Jesse

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-config_ia64_vmap_kernel.diff"

diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/Config.help aegl/arch/ia64/Config.help
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/Config.help	Wed Oct  9 11:39:29 2002
+++ aegl/arch/ia64/Config.help	Mon Oct 14 10:23:04 2002
@@ -567,3 +567,9 @@
 
   Select "16MB" for a small granule size.
   Select "64MB" for a large granule size.  This is the current default.
+
+CONFIG_IA64_VMAP_KERNEL
+  If you say Y here, the kernel will be configured to map the kernel
+  to the top 4GB of the 64-bit virtual space.  This is needed for
+  certain ccNUMA machines that do not guarantee the presence of
+  memory at any particular physical address.
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/config.in aegl/arch/ia64/config.in
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/config.in	Wed Oct  9 11:39:29 2002
+++ aegl/arch/ia64/config.in	Mon Oct  7 10:46:30 2002
@@ -71,6 +71,8 @@
 	define_bool CONFIG_IOSAPIC y
 fi
 
+bool 'Virtual mapped kernel' CONFIG_IA64_VMAP_KERNEL
+
 if [ "$CONFIG_IA64_SGI_SN1" = "y" -o "$CONFIG_IA64_SGI_SN2" = "y" ]; then
 	define_bool CONFIG_IA64_SGI_SN y
 	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/efi_stub.S aegl/arch/ia64/kernel/efi_stub.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/efi_stub.S	Fri Sep 27 14:48:34 2002
+++ aegl/arch/ia64/kernel/efi_stub.S	Wed Oct  9 09:48:06 2002
@@ -62,7 +62,7 @@
 	mov b6=r2
 	;;
 	andcm r16=loc3,r16		// get psr with IT, DT, and RT bits cleared
-	br.call.sptk.many rp=ia64_switch_mode
+	br.call.sptk.many rp=ia64_switch_mode_phys
 .ret0:	mov out4=in5
 	mov out0=in1
 	mov out1=in2
@@ -73,7 +73,7 @@
 	br.call.sptk.many rp=b6		// call the EFI function
 .ret1:	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
 	mov r16=loc3
-	br.call.sptk.many rp=ia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
 .ret2:	mov ar.rsc=loc4			// restore RSE configuration
 	mov ar.pfs=loc1
 	mov rp=loc0
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/entry.S aegl/arch/ia64/kernel/entry.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/entry.S	Fri Sep 27 14:49:16 2002
+++ aegl/arch/ia64/kernel/entry.S	Wed Oct  9 16:23:58 2002
@@ -175,6 +175,14 @@
 	;;
 	st8 [r22]=sp			// save kernel stack pointer of old task
 	shr.u r26=r20,IA64_GRANULE_SHIFT
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
+	;;
+	/*
+	 * If we've already mapped this task's page, we can skip doing it again.
+	 */
+	cmp.eq p7,p6=r26,r27
+#else
 	shr.u r17=r20,KERNEL_TR_PAGE_SHIFT
 	;;
 	cmp.ne p6,p7=KERNEL_TR_PAGE_NUM,r17
@@ -184,6 +192,7 @@
 	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
 (p6)	cmp.eq p7,p6=r26,r27
+#endif
 (p6)	br.cond.dpnt .map
 	;;
 .done:
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/head.S aegl/arch/ia64/kernel/head.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/head.S	Fri Sep 27 14:50:22 2002
+++ aegl/arch/ia64/kernel/head.S	Thu Oct 10 10:47:22 2002
@@ -75,7 +75,16 @@
 	mov cr.itir=r18
 	mov cr.ifa=r17
 	mov r16=IA64_TR_KERNEL
+#ifdef	CONFIG_IA64_VMAP_KERNEL
+	mov r3=ip
+	movl r18=PAGE_KERNEL
+	;;
+	dep r2=0,r3,0,KERNEL_TR_PAGE_SHIFT
+	;;
+	or r18=r2,r18
+#else
 	movl r18=((1 << KERNEL_TR_PAGE_SHIFT) | PAGE_KERNEL)
+#endif
 	;;
 	srlz.i
 	;;
@@ -144,15 +153,43 @@
 	cmp.eq isBP,isAP=r0,r0
 #endif
 	;;
+#ifdef	CONFIG_IA64_VMAP_KERNEL
+	tpa r3=r2		// r3 == phys addr of task struct
+	// load mapping for stack (virtaddr in r2, physaddr in r3)
+	rsm psr.ic
+	movl r17=PAGE_KERNEL
+	;;
+	srlz.d
+	dep r18=0,r3,0,12
+	;;
+	or r18=r17,r18
+	dep r2=-1,r3,61,3	// IMVA of task
+	;;
+	mov r17=rr[r2]
+	shr.u r16=r3,IA64_GRANULE_SHIFT
+	;;
+	dep r17=0,r17,8,24
+	;;
+	mov cr.itir=r17
+	mov cr.ifa=r2
+
+	mov r19=IA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r19]=r18
+	;;
+	ssm psr.ic
+	srlz.d
+#else
 	extr r3=r2,0,61		// r3 == phys addr of task struct
 	mov r16=KERNEL_TR_PAGE_NUM
 	;;
+#endif
 
 	// load the "current" pointer (r13) and ar.k6 with the current task
 	mov r13=r2
 	mov IA64_KR(CURRENT)=r3		// Physical address
 
-	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
+	// initialize k4 to granulized page number of stack
 	mov IA64_KR(CURRENT_STACK)=r16
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel threads
@@ -668,14 +705,14 @@
 END(__ia64_init_fpu)
 
 /*
- * Switch execution mode from virtual to physical or vice versa.
+ * Switch execution mode from virtual to physical
  *
  * Inputs:
  *	r16 = new psr to establish
  *
  * Note: RSE must already be in enforced lazy mode
  */
-GLOBAL_ENTRY(ia64_switch_mode)
+GLOBAL_ENTRY(ia64_switch_mode_phys)
  {
 	alloc r2=ar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
@@ -685,35 +722,86 @@
  {
 	flushrs				// must be first insn in group
 	srlz.i
-	shr.u r19=r15,61		// r19 <- top 3 bits of current IP
  }
 	;;
 	mov cr.ipsr=r16			// set new PSR
-	add r3=1f-ia64_switch_mode,r15
-	xor r15=0x7,r19			// flip the region bits
+	add r3=1f-ia64_switch_mode_phys,r15
 
 	mov r17=ar.bsp
 	mov r14=rp			// get return address into a general register
+	;;
 
-	// switch RSE backing store:
+	// going to physical mode, use tpa to translate virt->phys
+	tpa r17=r17
+	tpa r3=r3
+	tpa sp=sp
+	tpa r14=r14
 	;;
-	dep r17=r15,r17,61,3		// make ar.bsp physical or virtual
+
 	mov r18=ar.rnat			// save ar.rnat
-	;;
 	mov ar.bspstore=r17		// this steps on ar.rnat
-	dep r3=r15,r3,61,3		// make rfi return address physical or virtual
+	mov cr.iip=r3
+	mov cr.ifs=r0
+	;;
+	mov ar.rnat=r18			// restore ar.rnat
+	rfi				// must be last insn in group
+	;;
+1:	mov rp=r14
+	br.ret.sptk.many rp
+END(ia64_switch_mode_phys)
+
+/*
+ * Switch execution mode from physical to virtual
+ *
+ * Inputs:
+ *	r16 = new psr to establish
+ *
+ * Note: RSE must already be in enforced lazy mode
+ */
+GLOBAL_ENTRY(ia64_switch_mode_virt)
+ {
+	alloc r2=ar.pfs,0,0,0,0
+	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
+	mov r15=ip
+ }
+	;;
+ {
+	flushrs				// must be first insn in group
+	srlz.i
+ }
+	;;
+	mov cr.ipsr=r16			// set new PSR
+	add r3=1f-ia64_switch_mode_virt,r15
+
+	mov r17=ar.bsp
+	mov r14=rp			// get return address into a general register
+	;;
+
+	// going to virtual
+	//   - for code addresses, set upper bits of addr to KERNEL_START
+	//   - for stack addresses, set upper 3 bits to 0xe.... Dont change any of the
+	//     lower bits since we want it to stay identity mapped
+	movl r18=KERNEL_START
+	dep r3=0,r3,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
+	dep r14=0,r14,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
+	dep r17=-1,r17,61,3 
+	dep sp=-1,sp,61,3 
+	;;
+	or r3=r3,r18
+	or r14=r14,r18
 	;;
+
+	mov r18=ar.rnat			// save ar.rnat
+	mov ar.bspstore=r17		// this steps on ar.rnat
 	mov cr.iip=r3
 	mov cr.ifs=r0
-	dep sp=r15,sp,61,3		// make stack pointer physical or virtual
 	;;
 	mov ar.rnat=r18			// restore ar.rnat
-	dep r14=r15,r14,61,3		// make function return address physical or virtual
 	rfi				// must be last insn in group
 	;;
 1:	mov rp=r14
 	br.ret.sptk.many rp
-END(ia64_switch_mode)
+END(ia64_switch_mode_virt)
 
 #ifdef CONFIG_IA64_BRL_EMU
 
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/ia64_ksyms.c aegl/arch/ia64/kernel/ia64_ksyms.c
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/ia64_ksyms.c	Fri Sep 27 14:49:53 2002
+++ aegl/arch/ia64/kernel/ia64_ksyms.c	Wed Oct  9 13:43:37 2002
@@ -143,3 +143,6 @@
 #endif
 EXPORT_SYMBOL(machvec_noop);
 
+#ifdef CONFIG_IA64_VMAP_KERNEL
+EXPORT_SYMBOL(zero_page_memmap_ptr);
+#endif
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/ivt.S aegl/arch/ia64/kernel/ivt.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/ivt.S	Fri Sep 27 14:49:08 2002
+++ aegl/arch/ia64/kernel/ivt.S	Wed Oct  9 10:17:58 2002
@@ -122,8 +122,18 @@
 	shr.u r18=r22,PGDIR_SHIFT		// get bits 33-63 of the faulting address
 	;;
 (p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	.global ia64_ivt_patch1
+ia64_ivt_patch1:
+{	.mlx // we patch this bundle to include physical address of swapper_pg_dir
+	srlz.d					// ensure "rsm psr.dt" has taken effect
+(p6)	movl r19=swapper_pg_dir			// region 5 is rooted at swapper_pg_dir
+}
+	.pred.rel "mutex", p6, p7
+#else
 	srlz.d					// ensure "rsm psr.dt" has taken effect
 (p6)	movl r19=__pa(swapper_pg_dir)		// region 5 is rooted at swapper_pg_dir
+#endif
 (p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
@@ -415,8 +425,18 @@
 	shr.u r18=r16,PGDIR_SHIFT		// get bits 33-63 of faulting address
 	;;
 (p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	.global ia64_ivt_patch2
+ia64_ivt_patch2:
+{	.mlx // we patch this bundle to include physical address of swapper_pg_dir
+	srlz.d					// ensure "rsm psr.dt" has taken effect
+(p6)	movl r19=swapper_pg_dir			// region 5 is rooted at swapper_pg_dir
+}
+#else
 	srlz.d
 (p6)	movl r19=__pa(swapper_pg_dir)		// region 5 is rooted at swapper_pg_dir
+#endif
+	.pred.rel "mutex", p6, p7
 (p6)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=r21,PGDIR_SHIFT+PAGE_SHIFT-3
 	;;
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/mca.c aegl/arch/ia64/kernel/mca.c
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/mca.c	Wed Oct  9 11:39:29 2002
+++ aegl/arch/ia64/kernel/mca.c	Wed Oct  9 10:26:19 2002
@@ -434,17 +434,17 @@
 
 	IA64_MCA_DEBUG("ia64_mca_init: registered mca rendezvous spinloop and wakeup mech.\n");
 
-	ia64_mc_info.imi_mca_handler        = __pa(mca_hldlr_ptr->fp);
+	ia64_mc_info.imi_mca_handler        = __tpa(mca_hldlr_ptr->fp);
 	/*
 	 * XXX - disable SAL checksum by setting size to 0; should be
-	 *	__pa(ia64_os_mca_dispatch_end) - __pa(ia64_os_mca_dispatch);
+	 *	__tpa(ia64_os_mca_dispatch_end) - __tpa(ia64_os_mca_dispatch);
 	 */
 	ia64_mc_info.imi_mca_handler_size	= 0;
 
 	/* Register the os mca handler with SAL */
 	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_MCA,
 				       ia64_mc_info.imi_mca_handler,
-				       mca_hldlr_ptr->gp,
+				       __tpa(mca_hldlr_ptr->gp),
 				       ia64_mc_info.imi_mca_handler_size,
 				       0, 0, 0)))
 	{
@@ -454,15 +454,15 @@
 	}
 
 	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%lx, gp = 0x%lx\n",
-		       ia64_mc_info.imi_mca_handler, mca_hldlr_ptr->gp);
+		       ia64_mc_info.imi_mca_handler, __tpa(mca_hldlr_ptr->gp));
 
 	/*
 	 * XXX - disable SAL checksum by setting size to 0, should be
 	 * IA64_INIT_HANDLER_SIZE
 	 */
-	ia64_mc_info.imi_monarch_init_handler		= __pa(mon_init_ptr->fp);
+	ia64_mc_info.imi_monarch_init_handler		= __tpa(mon_init_ptr->fp);
 	ia64_mc_info.imi_monarch_init_handler_size	= 0;
-	ia64_mc_info.imi_slave_init_handler		= __pa(slave_init_ptr->fp);
+	ia64_mc_info.imi_slave_init_handler		= __tpa(slave_init_ptr->fp);
 	ia64_mc_info.imi_slave_init_handler_size	= 0;
 
 	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
@@ -471,10 +471,10 @@
 	/* Register the os init handler with SAL */
 	if ((rc = ia64_sal_set_vectors(SAL_VECTOR_OS_INIT,
 				       ia64_mc_info.imi_monarch_init_handler,
-				       __pa(ia64_get_gp()),
+				       __tpa(ia64_get_gp()),
 				       ia64_mc_info.imi_monarch_init_handler_size,
 				       ia64_mc_info.imi_slave_init_handler,
-				       __pa(ia64_get_gp()),
+				       __tpa(ia64_get_gp()),
 				       ia64_mc_info.imi_slave_init_handler_size)))
 	{
 		printk("ia64_mca_init: Failed to register m/s init handlers with SAL. rc = %ld\n",
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/pal.S aegl/arch/ia64/kernel/pal.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/pal.S	Fri Sep 27 14:50:57 2002
+++ aegl/arch/ia64/kernel/pal.S	Wed Oct  9 10:38:14 2002
@@ -164,7 +164,11 @@
 	;; 
 	mov loc4=ar.rsc			// save RSE configuration
 	dep.z loc2=loc2,0,61		// convert pal entry point to physical
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	tpa r8=r8			// convert rp to physical
+#else
 	dep.z r8=r8,0,61		// convert rp to physical
+#endif
 	;;
 	mov b7 = loc2			// install target to branch reg
 	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
@@ -174,13 +178,13 @@
 	or loc3=loc3,r17		// add in psr the bits to set
 	;;
 	andcm r16=loc3,r16		// removes bits to clear from psr
-	br.call.sptk.many rp=ia64_switch_mode
+	br.call.sptk.many rp=ia64_switch_mode_phys
 .ret1:	mov rp = r8			// install return address (physical)
 	br.cond.sptk.many b7
 1:
 	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
 	mov r16=loc3			// r16= original psr
-	br.call.sptk.many rp=ia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
 .ret2:
 	mov psr.l = loc3		// restore init PSR
 
@@ -228,13 +232,13 @@
 	mov b7 = loc2			// install target to branch reg
 	;;
 	andcm r16=loc3,r16		// removes bits to clear from psr
-	br.call.sptk.many rp=ia64_switch_mode
+	br.call.sptk.many rp=ia64_switch_mode_phys
 .ret6:
 	br.call.sptk.many rp=b7		// now make the call
 .ret7:
 	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
 	mov r16=loc3			// r16= original psr
-	br.call.sptk.many rp=ia64_switch_mode	// return to virtual mode
+	br.call.sptk.many rp=ia64_switch_mode_virt	// return to virtual mode
 
 .ret8:	mov psr.l  = loc3		// restore init PSR
 	mov ar.pfs = loc1
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/setup.c aegl/arch/ia64/kernel/setup.c
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/setup.c	Fri Sep 27 14:49:06 2002
+++ aegl/arch/ia64/kernel/setup.c	Tue Oct 15 13:58:00 2002
@@ -231,8 +231,8 @@
 				+ strlen(__va(ia64_boot_param->command_line)) + 1);
 	n++;
 
-	rsvd_region[n].start = KERNEL_START;
-	rsvd_region[n].end   = KERNEL_END;
+	rsvd_region[n].start = __imva(KERNEL_START);
+	rsvd_region[n].end   = __imva(KERNEL_END);
 	n++;
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -282,6 +282,51 @@
 #endif
 }
 
+#ifdef CONFIG_IA64_VMAP_KERNEL
+/*
+ * There are two places in the performance critical path of
+ * the exception handling code where we need to know the physical
+ * address of the swapper_pg_dir structure.  This routine
+ * patches the "movl" instructions to load the value needed.
+ */
+static void __init
+patch_ivt_with_phys_swapper_pg_dir(void)
+{
+	extern char ia64_ivt_patch1[], ia64_ivt_patch2[];
+	unsigned long spd = __tpa(swapper_pg_dir);
+	unsigned long *p;
+
+	p = (unsigned long *)__imva(ia64_ivt_patch1);
+
+	*p = (*p & 0x3fffffffffffUL) |
+		((spd & 0x000000ffffc00000UL)<<24);
+	p++;
+	*p = (*p & 0xf000080fff800000UL) |
+		((spd & 0x8000000000000000UL) >> 4)  |
+		((spd & 0x7fffff0000000000UL) >> 40) |
+		((spd & 0x00000000001f0000UL) << 29) |
+		((spd & 0x0000000000200000UL) << 23) |
+		((spd & 0x000000000000ff80UL) << 43) |
+		((spd & 0x000000000000007fUL) << 36);
+
+	p = (unsigned long *)__imva(ia64_ivt_patch2);
+
+	*p = (*p & 0x3fffffffffffUL) |
+		((spd & 0x000000ffffc00000UL)<<24);
+	p++;
+	*p = (*p & 0xf000080fff800000UL) |
+		((spd & 0x8000000000000000UL) >> 4)  |
+		((spd & 0x7fffff0000000000UL) >> 40) |
+		((spd & 0x00000000001f0000UL) << 29) |
+		((spd & 0x0000000000200000UL) << 23) |
+		((spd & 0x000000000000ff80UL) << 43) |
+		((spd & 0x000000000000007fUL) << 36);
+}
+#define PATCH_IVT() patch_ivt_with_phys_swapper_pg_dir()
+#else
+#define PATCH_IVT()
+#endif
+
 void __init
 setup_arch (char **cmdline_p)
 {
@@ -290,6 +335,8 @@
 
 	unw_init();
 
+	PATCH_IVT();
+
 	*cmdline_p = __va(ia64_boot_param->command_line);
 	strncpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 	saved_command_line[COMMAND_LINE_SIZE-1] = '\0';		/* for safety */
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/smpboot.c aegl/arch/ia64/kernel/smpboot.c
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/kernel/smpboot.c	Fri Sep 27 14:49:16 2002
+++ aegl/arch/ia64/kernel/smpboot.c	Wed Oct  9 10:58:39 2002
@@ -522,7 +522,7 @@
 	/* Tell SAL where to drop the AP's.  */
 	ap_startup = (struct fptr *) start_ap;
 	sal_ret = ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
-				       __pa(ap_startup->fp), __pa(ap_startup->gp), 0, 0, 0, 0);
+				       __tpa(ap_startup->fp), __tpa(ap_startup->gp), 0, 0, 0, 0);
 	if (sal_ret < 0)
 		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n", ia64_sal_strerror(sal_ret));
 }
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/mm/init.c aegl/arch/ia64/mm/init.c
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/mm/init.c	Wed Oct  9 11:39:29 2002
+++ aegl/arch/ia64/mm/init.c	Tue Oct 15 13:59:05 2002
@@ -39,6 +39,10 @@
 
 static int pgt_cache_water[2] = { 25, 50 };
 
+#ifdef CONFIG_IA64_VMAP_KERNEL
+struct page *zero_page_memmap_ptr;		/* map entry for zero page */
+#endif
+
 void
 check_pgt_cache (void)
 {
@@ -104,14 +108,16 @@
 void
 free_initmem (void)
 {
-	unsigned long addr;
+	unsigned long addr, eaddr;
 
-	addr = (unsigned long) &__init_begin;
-	for (; addr < (unsigned long) &__init_end; addr += PAGE_SIZE) {
+	addr = (unsigned long)__imva(&__init_begin);
+	eaddr = (unsigned long)__imva(&__init_end);
+	while (addr < eaddr) {
 		ClearPageReserved(virt_to_page(addr));
 		set_page_count(virt_to_page(addr), 1);
 		free_page(addr);
 		++totalram_pages;
+		addr += PAGE_SIZE;
 	}
 	printk(KERN_INFO "Freeing unused kernel memory: %ldkB freed\n",
 	       (&__init_end - &__init_begin) >> 10);
@@ -286,7 +292,7 @@
 	ia64_srlz_d();
 
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
-		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)), PAGE_SHIFT);
+		 pte_val(pfn_pte(__tpa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)), PAGE_SHIFT);
 
 	ia64_set_psr(psr);
 	ia64_srlz_i();
@@ -364,6 +370,9 @@
 		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
 	}
 	free_area_init(zones_size);
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	zero_page_memmap_ptr = virt_to_page(__imva(empty_zero_page));
+#endif
 }
 
 static int
@@ -442,7 +451,7 @@
 		pgt_cache_water[1] = num_pgt_pages;
 
 	/* install the gate page in the global page table: */
-	put_gate_page(virt_to_page(__start_gate_section), GATE_ADDR);
+	put_gate_page(virt_to_page(__imva(__start_gate_section)), GATE_ADDR);
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_gdt_init();
diff -ru ../../REF/linux-2.5.39-ia64-020928/arch/ia64/vmlinux.lds.S aegl/arch/ia64/vmlinux.lds.S
--- ../../REF/linux-2.5.39-ia64-020928/arch/ia64/vmlinux.lds.S	Wed Oct  9 11:39:29 2002
+++ aegl/arch/ia64/vmlinux.lds.S	Mon Oct  7 17:12:16 2002
@@ -3,6 +3,12 @@
 #include <asm/cache.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
+#ifdef CONFIG_IA64_VMAP_KERNEL
+#include <asm/pgtable.h>
+#define	BASE_KVADDR	KERNEL_START + KERNEL_TR_PAGE_SIZE
+#else
+#define	BASE_KVADDR	PAGE_OFFSET
+#endif
 
 OUTPUT_FORMAT("elf64-ia64-little")
 OUTPUT_ARCH(ia64)
@@ -20,21 +26,21 @@
 	}
 
   v = PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
-  phys_start = _start - PAGE_OFFSET;
+  phys_start = _start - BASE_KVADDR;
 
   . = KERNEL_START;
 
   _text = .;
   _stext = .;
-  .text : AT(ADDR(.text) - PAGE_OFFSET)
+  .text : AT(ADDR(.text) - BASE_KVADDR)
     {
 	*(.text.ivt)
 	*(.text)
     }
-  .text2 : AT(ADDR(.text2) - PAGE_OFFSET)
+  .text2 : AT(ADDR(.text2) - BASE_KVADDR)
 	{ *(.text2) }
 #ifdef CONFIG_SMP
-  .text.lock : AT(ADDR(.text.lock) - PAGE_OFFSET)
+  .text.lock : AT(ADDR(.text.lock) - BASE_KVADDR)
 	{ *(.text.lock) }
 #endif
   _etext = .;
@@ -47,7 +53,7 @@
   /* Exception table */
   . = ALIGN(16);
   __start___ex_table = .;
-  __ex_table : AT(ADDR(__ex_table) - PAGE_OFFSET)
+  __ex_table : AT(ADDR(__ex_table) - BASE_KVADDR)
 	{ *(__ex_table) }
   __stop___ex_table = .;
 
@@ -55,48 +61,48 @@
   /* Machine Vector */
   . = ALIGN(16);
   machvec_start = .;
-  .machvec : AT(ADDR(.machvec) - PAGE_OFFSET)
+  .machvec : AT(ADDR(.machvec) - BASE_KVADDR)
 	{ *(.machvec) }
   machvec_end = .;
 #endif
 
   __start___ksymtab = .;	/* Kernel symbol table */
-  __ksymtab : AT(ADDR(__ksymtab) - PAGE_OFFSET)
+  __ksymtab : AT(ADDR(__ksymtab) - BASE_KVADDR)
 	{ *(__ksymtab) }
   __stop___ksymtab = .;
 
   /* Unwind info & table: */
   . = ALIGN(8);
-  .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
+  .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - BASE_KVADDR)
 	{ *(.IA_64.unwind_info*) }
   ia64_unw_start = .;
-  .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
+  .IA_64.unwind : AT(ADDR(.IA_64.unwind) - BASE_KVADDR)
 	{ *(.IA_64.unwind*) }
   ia64_unw_end = .;
 
-  .rodata : AT(ADDR(.rodata) - PAGE_OFFSET)
+  .rodata : AT(ADDR(.rodata) - BASE_KVADDR)
 	{ *(.rodata) *(.rodata.*) }
-  .kstrtab : AT(ADDR(.kstrtab) - PAGE_OFFSET)
+  .kstrtab : AT(ADDR(.kstrtab) - BASE_KVADDR)
 	{ *(.kstrtab) }
-  .opd : AT(ADDR(.opd) - PAGE_OFFSET)
+  .opd : AT(ADDR(.opd) - BASE_KVADDR)
 	{ *(.opd) }
 
   /* Initialization code and data: */
 
   . = ALIGN(PAGE_SIZE);
   __init_begin = .;
-  .text.init : AT(ADDR(.text.init) - PAGE_OFFSET)
+  .text.init : AT(ADDR(.text.init) - BASE_KVADDR)
 	{ *(.text.init) }
 
-  .data.init : AT(ADDR(.data.init) - PAGE_OFFSET)
+  .data.init : AT(ADDR(.data.init) - BASE_KVADDR)
 	{ *(.data.init) }
    . = ALIGN(16);
   __setup_start = .;
-  .setup.init : AT(ADDR(.setup.init) - PAGE_OFFSET)
+  .setup.init : AT(ADDR(.setup.init) - BASE_KVADDR)
         { *(.setup.init) }
   __setup_end = .;
   __initcall_start = .;
-  .initcall.init : AT(ADDR(.initcall.init) - PAGE_OFFSET)
+  .initcall.init : AT(ADDR(.initcall.init) - BASE_KVADDR)
 	{
 		*(.initcall1.init)
 		*(.initcall2.init)
@@ -111,10 +117,10 @@
   __init_end = .;
 
   /* The initial task and kernel stack */
-  .data.init_task : AT(ADDR(.data.init_task) - PAGE_OFFSET)
+  .data.init_task : AT(ADDR(.data.init_task) - BASE_KVADDR)
 	{ *(.data.init_task) }
 
-  .data.page_aligned : AT(ADDR(.data.page_aligned) - PAGE_OFFSET)
+  .data.page_aligned : AT(ADDR(.data.page_aligned) - BASE_KVADDR)
         { *(__special_page_section)
 	  __start_gate_section = .;
 	  *(.text.gate)
@@ -122,17 +128,17 @@
 	}
 
   . = ALIGN(SMP_CACHE_BYTES);
-  .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - PAGE_OFFSET)
+  .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - BASE_KVADDR)
         { *(.data.cacheline_aligned) }
 
   /* Kernel symbol names for modules: */
-  .kstrtab : AT(ADDR(.kstrtab) - PAGE_OFFSET)
+  .kstrtab : AT(ADDR(.kstrtab) - BASE_KVADDR)
 	{ *(.kstrtab) }
 
   /* Per-cpu data: */
   . = ALIGN(PAGE_SIZE);
   __phys_per_cpu_start = .;
-  .data.percpu PERCPU_ADDR : AT(__phys_per_cpu_start - PAGE_OFFSET)
+  .data.percpu PERCPU_ADDR : AT(__phys_per_cpu_start - BASE_KVADDR)
 	{
 		__per_cpu_start = .;
 		*(.data.percpu)
@@ -140,28 +146,28 @@
 	}
   . = __phys_per_cpu_start + 4096;	/* ensure percpu fits into smallest page size (4KB) */
 
-  .data : AT(ADDR(.data) - PAGE_OFFSET)
+  .data : AT(ADDR(.data) - BASE_KVADDR)
 	{ *(.data) *(.gnu.linkonce.d*) CONSTRUCTORS }
 
   . = ALIGN(16);
   __gp = . + 0x200000;	/* gp must be 16-byte aligned for exc. table */
 
-  .got : AT(ADDR(.got) - PAGE_OFFSET)
+  .got : AT(ADDR(.got) - BASE_KVADDR)
 	{ *(.got.plt) *(.got) }
   /* We want the small data sections together, so single-instruction offsets
      can access them all, and initialized data all before uninitialized, so
      we can shorten the on-disk segment size.  */
-  .sdata : AT(ADDR(.sdata) - PAGE_OFFSET)
+  .sdata : AT(ADDR(.sdata) - BASE_KVADDR)
 	{ *(.sdata) }
   _edata  =  .;
   _bss = .;
-  .sbss : AT(ADDR(.sbss) - PAGE_OFFSET)
+  .sbss : AT(ADDR(.sbss) - BASE_KVADDR)
 	{ *(.sbss) *(.scommon) }
-  .bss : AT(ADDR(.bss) - PAGE_OFFSET)
+  .bss : AT(ADDR(.bss) - BASE_KVADDR)
 	{ *(.bss) *(COMMON) }
 
   /* XXX Must this come last to avoid shifting other symbols?  --davidm */
-  __kallsyms : AT(ADDR(__kallsyms) - PAGE_OFFSET)
+  __kallsyms : AT(ADDR(__kallsyms) - BASE_KVADDR)
 	{
 	  __start___kallsyms = .;	/* All kernel symbols */
 	  *(__kallsyms)
diff -ru ../../REF/linux-2.5.39-ia64-020928/fs/proc/kcore.c aegl/fs/proc/kcore.c
--- ../../REF/linux-2.5.39-ia64-020928/fs/proc/kcore.c	Fri Sep 27 14:48:35 2002
+++ aegl/fs/proc/kcore.c	Tue Oct 15 13:03:44 2002
@@ -99,6 +99,12 @@
 }
 #else /* CONFIG_KCORE_AOUT */
 
+#if VMALLOC_START < PAGE_OFFSET
+#define	KCORE_BASE	VMALLOC_START
+#else
+#define	KCORE_BASE	PAGE_OFFSET
+#endif
+
 #define roundup(x, y)  ((((x)+((y)-1))/(y))*(y))
 
 /* An ELF note in memory */
@@ -111,6 +117,12 @@
 };
 
 extern char saved_command_line[];
+#ifdef CONFIG_IA64_VMAP_KERNEL
+extern char _stext[], _end[];
+#define NPHDR	3
+#else
+#define NPHDR	2
+#endif
 
 static size_t get_kcore_size(int *num_vma, size_t *elf_buflen)
 {
@@ -118,7 +130,11 @@
 	struct vm_struct *m;
 
 	*num_vma = 0;
-	size = ((size_t)high_memory - PAGE_OFFSET + PAGE_SIZE);
+	size = ((size_t)high_memory - KCORE_BASE + PAGE_SIZE);
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	if ((size_t)_end > KCORE_BASE + size)
+		size = (size_t)_end - KCORE_BASE;
+#endif
 	if (!vmlist) {
 		*elf_buflen = PAGE_SIZE;
 		return (size);
@@ -126,15 +142,15 @@
 
 	for (m=vmlist; m; m=m->next) {
 		try = (size_t)m->addr + m->size;
-		if (try > size)
-			size = try;
+		if (try > KCORE_BASE + size)
+			size = try - KCORE_BASE;
 		*num_vma = *num_vma + 1;
 	}
 	*elf_buflen =	sizeof(struct elfhdr) + 
-			(*num_vma + 2)*sizeof(struct elf_phdr) + 
+			(*num_vma + NPHDR)*sizeof(struct elf_phdr) + 
 			3 * sizeof(struct memelfnote);
 	*elf_buflen = PAGE_ALIGN(*elf_buflen);
-	return (size - PAGE_OFFSET + *elf_buflen);
+	return size + *elf_buflen;
 }
 
 
@@ -237,12 +253,26 @@
 	offset += sizeof(struct elf_phdr);
 	phdr->p_type	= PT_LOAD;
 	phdr->p_flags	= PF_R|PF_W|PF_X;
-	phdr->p_offset	= dataoff;
+	phdr->p_offset	= PAGE_OFFSET - KCORE_BASE + dataoff;
 	phdr->p_vaddr	= PAGE_OFFSET;
 	phdr->p_paddr	= __pa(PAGE_OFFSET);
 	phdr->p_filesz	= phdr->p_memsz = ((unsigned long)high_memory - PAGE_OFFSET);
 	phdr->p_align	= PAGE_SIZE;
 
+#ifdef CONFIG_IA64_VMAP_KERNEL
+	/* setup ELF PT_LOAD program header for kernel */
+	phdr = (struct elf_phdr *) bufp;
+	bufp += sizeof(struct elf_phdr);
+	offset += sizeof(struct elf_phdr);
+	phdr->p_type	= PT_LOAD;
+	phdr->p_flags	= PF_R|PF_W|PF_X;
+	phdr->p_offset	= (unsigned long)_stext - KCORE_BASE + dataoff;
+	phdr->p_vaddr	= (unsigned long)_stext;
+	phdr->p_paddr	= __tpa(_stext);
+	phdr->p_filesz	= phdr->p_memsz = _end - _stext;
+	phdr->p_align	= PAGE_SIZE;
+#endif
+
 	/* setup ELF PT_LOAD program header for every vmalloc'd area */
 	for (m=vmlist; m; m=m->next) {
 		if (m->flags & VM_IOREMAP) /* don't dump ioremap'd stuff! (TA) */
@@ -254,7 +284,7 @@
 
 		phdr->p_type	= PT_LOAD;
 		phdr->p_flags	= PF_R|PF_W|PF_X;
-		phdr->p_offset	= (size_t)m->addr - PAGE_OFFSET + dataoff;
+		phdr->p_offset	= (size_t)m->addr - KCORE_BASE + dataoff;
 		phdr->p_vaddr	= (size_t)m->addr;
 		phdr->p_paddr	= __pa(m->addr);
 		phdr->p_filesz	= phdr->p_memsz	= m->size;
@@ -385,9 +415,9 @@
 	/*
 	 * Fill the remainder of the buffer from kernel VM space.
 	 * We said in the ELF header that the data which starts
-	 * at 'elf_buflen' is virtual address PAGE_OFFSET. --rmk
+	 * at 'elf_buflen' is virtual address KCORE_BASE. --rmk
 	 */
-	start = PAGE_OFFSET + (*fpos - elf_buflen);
+	start = KCORE_BASE + (*fpos - elf_buflen);
 	if ((tsz = (PAGE_SIZE - (start & ~PAGE_MASK))) > buflen)
 		tsz = buflen;
 		
@@ -446,6 +476,17 @@
 				if (clear_user(buffer, tsz))
 					return -EFAULT;
 			}
+#ifdef CONFIG_IA64_VMAP_KERNEL
+		} else if ((start > (unsigned long)_stext) && (start < 
+						(unsigned long)_end)) {
+			if (kern_addr_valid(start)) {
+				if (copy_to_user(buffer, (char *)start, tsz))
+					return -EFAULT;
+			} else {
+				if (clear_user(buffer, tsz))
+					return -EFAULT;
+			}
+#endif
 		} else {
 			if (clear_user(buffer, tsz))
 				return -EFAULT;
diff -ru ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/page.h aegl/include/asm-ia64/page.h
--- ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/page.h	Fri Sep 27 14:49:06 2002
+++ aegl/include/asm-ia64/page.h	Tue Oct  8 17:49:48 2002
@@ -106,6 +106,13 @@
  */
 #define __pa(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg = 0; _v.l;})
 #define __va(x)		({ia64_va _v; _v.l = (long) (x); _v.f.reg = -1; _v.p;})
+#ifdef CONFIG_IA64_VMAP_KERNEL
+#define __tpa(x)	({ia64_va _v; asm("tpa %0=%1" : "=r"(_v.l) : "r"(x)); _v.l;})
+#define __imva(x)	((long)__va(__tpa(x)))
+#else
+#define __tpa(x)	__pa(x)
+#define __imva(x)	(x)
+#endif
 
 #define REGION_NUMBER(x)	({ia64_va _v; _v.l = (long) (x); _v.f.reg;})
 #define REGION_OFFSET(x)	({ia64_va _v; _v.l = (long) (x); _v.f.off;})
diff -ru ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/pgtable.h aegl/include/asm-ia64/pgtable.h
--- ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/pgtable.h	Fri Sep 27 14:49:40 2002
+++ aegl/include/asm-ia64/pgtable.h	Wed Oct  9 13:53:42 2002
@@ -415,7 +415,12 @@
  * for zero-mapped memory areas etc..
  */
 extern unsigned long empty_zero_page[PAGE_SIZE/sizeof(unsigned long)];
+#ifdef CONFIG_IA64_VMAP_KERNEL
+extern struct page *zero_page_memmap_ptr;
+#define ZERO_PAGE(vaddr) (zero_page_memmap_ptr)
+#else
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
+#endif
 
 /* We provide our own get_unmapped_area to cope with VA holes for userland */
 #define HAVE_ARCH_UNMAPPED_AREA
@@ -440,7 +445,9 @@
  */
 #define KERNEL_TR_PAGE_SHIFT	_PAGE_SIZE_64M
 #define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
+#ifndef CONFIG_IA64_VMAP_KERNEL
 #define KERNEL_TR_PAGE_NUM	((KERNEL_START - PAGE_OFFSET) / KERNEL_TR_PAGE_SIZE)
+#endif
 
 /*
  * No page table caches to initialise
diff -ru ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/system.h aegl/include/asm-ia64/system.h
--- ../../REF/linux-2.5.39-ia64-020928/include/asm-ia64/system.h	Fri Sep 27 14:49:49 2002
+++ aegl/include/asm-ia64/system.h	Mon Oct  7 10:59:03 2002
@@ -18,7 +18,11 @@
 #include <asm/page.h>
 #include <asm/pal.h>
 
+#ifdef	CONFIG_IA64_VMAP_KERNEL
+#define KERNEL_START		(0xffffffff00000000)
+#else
 #define KERNEL_START		(PAGE_OFFSET + 68*1024*1024)
+#endif
 
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
 #define PERCPU_ADDR		(0xa000000000000000 + 2*PAGE_SIZE)


--C7zPtVaVf+AK4Oqc--

