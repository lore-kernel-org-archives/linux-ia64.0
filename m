From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 19 Dec 2005 21:07:50 +0000
Subject: Re: ip_contrack refuses to load if built UP as a module on IA64
Message-Id: <20051219210750.GA15849@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A5FA@scsmsx401.amr.corp.intel.com> <ed5aea430508301229386fc596@mail.gmail.com> <17172.54563.329758.846131@wombat.chubb.wattle.id.au> <17174.35525.283392.703723@berry.gelato.unsw.EDU.AU> <1127426700.25159.63.camel@krebs.dannf>
In-Reply-To: <1127426700.25159.63.camel@krebs.dannf>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dann frazier <dannf@hp.com>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org, dmosberger@gmail.com, linux-kernel@vger.kernel.org

On Thu, Sep 22, 2005 at 04:04:59PM -0600, dann frazier wrote:
> On Thu, 2005-09-01 at 14:59 +1000, Peter Chubb wrote:
> >=20
> > This patch makes UP and SMP do the same thing as far as module per-cpu
> > data go.
> >=20
> > Unfortunately it affects core code.
>=20
> It causes 2.6.13/x86 to fail to link:
> kernel/built-in.o: In function `load_module':
> : undefined reference to `percpu_modcopy'
> make: *** [.tmp_vmlinux1] Error 1
>=20
> fyi, this is a problem we're seeing in the Debian UP packages:
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug25070

Another possible solution is to make ia64 more like other
architectures and make per-cpu variables just turn into
ordinary variables on UP.  There are some pros and cons to
this:

+) Being more like other architectures makes it less likely that
   we'll be burned by changes in generic code/tools that depend
   on implementation details

-) We probably get worse code to access per-cpu variables from
   C-compiled code, and definitely get worse code in a couple of
   critical paths in assembler (where an "addl" becomes a "movl")

Here's the patch ... lightly tested (just booted and checked that
I could load the ip_conntrack module).

-Tony


diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 0741b06..c678224 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -766,7 +766,11 @@ ENTRY(ia64_leave_syscall)
 	ld8.fill r15=3D[r3]			// M0|1 restore r15
 	mov b6=3Dr18				// I0   restore b6
=20
+#ifdef CONFIG_SMP
 	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0 // A
+#else
+	movl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8)
+#endif
 	mov f9=F0					// F    clear f9
 (pKStk) br.cond.dpnt.many skip_rbs_switch		// B
=20
@@ -952,7 +956,11 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=3Dar.bsp		// get existing backing store pointer
+#ifdef CONFIG_SMP
 	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
+#else
+	movl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8)
+#endif
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
 (pKStk)	br.cond.dpnt skip_rbs_switch
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index bfe65b2..4414970 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -980,7 +980,11 @@ END(ia64_delay_loop)
  * intermediate precision so that we can produce a full 64-bit result.
  */
 GLOBAL_ENTRY(sched_clock)
+#ifdef CONFIG_SMP
 	addl r8=3DTHIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET,r0
+#else
+	movl r8=3DTHIS_CPU(cpu_info) + IA64_CPUINFO_NSEC_PER_CYC_OFFSET
+#endif
 	mov.m r9=3Dar.itc		// fetch cycle-counter				(35 cyc)
 	;;
 	ldf8 f8=3D[r8]
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 355af15..b6391c9 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1474,12 +1474,14 @@ ia64_mca_cpu_init(void *cpu_data)
 	 */
 	__get_cpu_var(ia64_mca_data) =3D __per_cpu_mca[smp_processor_id()];
=20
+#ifdef CONFIG_SMP
 	/*
 	 * Stash away a copy of the PTE needed to map the per-CPU page.
 	 * We may need it during MCA recovery.
 	 */
 	__get_cpu_var(ia64_mca_per_cpu_pte)  		pte_val(mk_pte_phys(__pa(cpu_data)=
, PAGE_KERNEL));
+#endif
=20
 	/*
 	 * Also, stash away a copy of the PAL address and the PTE
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index db32fc1..45d8b30 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -102,6 +102,7 @@ ia64_do_tlb_purge:
 	;;
 	srlz.d
 	;;
+#ifdef	CONFIG_SMP
 	// 2. Purge DTR for PERCPU data.
 	movl r16=3DPERCPU_ADDR
 	mov r18=3DPERCPU_PAGE_SHIFT<<2
@@ -110,6 +111,7 @@ ia64_do_tlb_purge:
 	;;
 	srlz.d
 	;;
+#endif
 	// 3. Purge ITR for PAL code.
 	GET_THIS_PADDR(r2, ia64_mca_pal_base)
 	;;
@@ -197,6 +199,7 @@ ia64_reload_tr:
 	srlz.i
 	srlz.d
 	;;
+#ifdef	CONFIG_SMP
 	// 2. Reload DTR register for PERCPU data.
 	GET_THIS_PADDR(r2, ia64_mca_per_cpu_pte)
 	;;
@@ -213,6 +216,7 @@ ia64_reload_tr:
 	;;
 	srlz.d
 	;;
+#endif
 	// 3. Reload ITR for PAL code.
 	GET_THIS_PADDR(r2, ia64_mca_pal_pte)
 	;;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 5add0bc..ef2dc6c 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -752,6 +752,7 @@ cpu_init (void)
 	struct cpuinfo_ia64 *cpu_info;
 	void *cpu_data;
=20
+#ifdef CONFIG_SMP
 	cpu_data =3D per_cpu_init();
=20
 	/*
@@ -761,9 +762,11 @@ cpu_init (void)
 	 */
 	ia64_set_kr(IA64_KR_PER_CPU_DATA,
 		    ia64_tpa(cpu_data) - (long) __per_cpu_start);
+#endif
=20
 	get_max_cacheline_size();
=20
+#ifdef CONFIG_SMP
 	/*
 	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't ca=
lled
 	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because =
it
@@ -771,6 +774,11 @@ cpu_init (void)
 	 * accessing cpu_data() through the canonical per-CPU address.
 	 */
 	cpu_info =3D cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_c=
pu_start);
+	cpu_data =3D ia64_imva(cpu_data);
+#else
+	cpu_info =3D &per_cpu(cpu_info, 0);
+	cpu_data =3D 0;
+#endif
 	identify_cpu(cpu_info);
=20
 #ifdef CONFIG_MCKINLEY
@@ -817,8 +825,8 @@ cpu_init (void)
 	if (current->mm)
 		BUG();
=20
-	ia64_mmu_init(ia64_imva(cpu_data));
-	ia64_mca_cpu_init(ia64_imva(cpu_data));
+	ia64_mmu_init(cpu_data);
+	ia64_mca_cpu_init(cpu_data);
=20
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_cpu_init();
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 30d8564..2b3fa83 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -19,7 +19,9 @@ ENTRY(phys_start)
 jiffies =3D jiffies_64;
 PHDRS {
   code   PT_LOAD;
+#ifdef CONFIG_SMP
   percpu PT_LOAD;
+#endif
   data   PT_LOAD;
 }
 SECTIONS
@@ -180,6 +182,7 @@ SECTIONS
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
         { *(.data.cacheline_aligned) }
=20
+#ifdef CONFIG_SMP
   /* Per-cpu data: */
   percpu : { } :percpu
   . =3D ALIGN(PERCPU_PAGE_SIZE);
@@ -191,6 +194,7 @@ SECTIONS
 		__per_cpu_end =3D .;
 	}
   . =3D __phys_per_cpu_start + PERCPU_PAGE_SIZE;	/* ensure percpu data fit=
s into percpu page size */
+#endif
=20
   data : { } :data
   .data : AT(ADDR(.data) - LOAD_OFFSET)
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index e3215ba..5def017 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -332,7 +332,7 @@ setup_gate (void)
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
-	unsigned long psr, pta, impl_va_bits;
+	unsigned long pta, impl_va_bits;
 	extern void __devinit tlb_init (void);
=20
 #ifdef CONFIG_DISABLE_VHPT
@@ -341,6 +341,10 @@ ia64_mmu_init (void *my_cpu_data)
 #	define VHPT_ENABLE_BIT	1
 #endif
=20
+#ifdef	CONFIG_SMP
+{
+	unsigned long psr;
+
 	/* Pin mapping for percpu area into TLB */
 	psr =3D ia64_clear_ic();
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
@@ -349,6 +353,8 @@ ia64_mmu_init (void *my_cpu_data)
=20
 	ia64_set_psr(psr);
 	ia64_srlz_i();
+}
+#endif
=20
 	/*
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with =
a mapped
diff --git a/include/asm-ia64/mca_asm.h b/include/asm-ia64/mca_asm.h
index 27c9203..26d8710 100644
--- a/include/asm-ia64/mca_asm.h
+++ b/include/asm-ia64/mca_asm.h
@@ -48,9 +48,14 @@
 	mov	temp	=3D 0x7	;;							\
 	dep	addr	=3D temp, addr, 61, 3
=20
+#ifdef	CONFIG_SMP
 #define GET_THIS_PADDR(reg, var)		\
 	mov	reg =3D IA64_KR(PER_CPU_DATA);;	\
         addl	reg =3D THIS_CPU(var), reg
+#else
+#define GET_THIS_PADDR(reg, var)		\
+	LOAD_PHYSICAL(p0, reg, per_cpu__##var)
+#endif
=20
 /*
  * This macro jumps to the instruction at the given virtual address
diff --git a/include/asm-ia64/percpu.h b/include/asm-ia64/percpu.h
index 2b14dee..9248d17 100644
--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -16,7 +16,7 @@
=20
 #include <linux/threads.h>
=20
-#ifdef HAVE_MODEL_SMALL_ATTRIBUTE
+#if defined(HAVE_MODEL_SMALL_ATTRIBUTE) && defined(CONFIG_SMP)
 # define __SMALL_ADDR_AREA	__attribute__((__model__ (__small__)))
 #else
 # define __SMALL_ADDR_AREA
@@ -25,6 +25,7 @@
 #define DECLARE_PER_CPU(type, name)				\
 	extern __SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
=20
+#ifdef CONFIG_SMP
 /* Separate out the type, so (int[3], foo) works. */
 #define DEFINE_PER_CPU(type, name)				\
 	__attribute__((__section__(".data.percpu")))		\
@@ -34,7 +35,6 @@
  * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_=
modcopy() is an
  * external routine, to avoid include-hell.
  */
-#ifdef CONFIG_SMP
=20
 extern unsigned long __per_cpu_offset[NR_CPUS];
=20
@@ -50,6 +50,9 @@ extern void *per_cpu_init(void);
=20
 #else /* ! SMP */
=20
+#define DEFINE_PER_CPU(type, name) \
+    __typeof__(type) per_cpu__##name
+
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
 #define per_cpu_init()				(__phys_per_cpu_start)
