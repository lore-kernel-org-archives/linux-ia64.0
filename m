From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 19 Aug 2004 04:55:34 +0000
Subject: Re: What is MMU_TRACE for?
Message-Id: <20040819045534.GA1831@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5QAgd0e35j3NYeGe"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040818042558.GC1170@cse.unsw.EDU.AU>
In-Reply-To: <20040818042558.GC1170@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--5QAgd0e35j3NYeGe
Content-Type: multipart/mixed; boundary="hQiwHBbRI9kgIhsi"
Content-Disposition: inline


--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 18, 2004 at 01:13:32AM -0700, David Mosberger wrote:
> It's just left-over debugging code.  We should remove it.=20

Here is a little patch to do that

-i

--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="remove_mmu_trace.patch"
Content-Transfer-Encoding: quoted-printable

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/19 14:25:49+10:00 ianw@baci.gelato=20
#   Remove extraneous MMU_TRACE debugging macros
#=20
# include/asm-ia64/tlbflush.h
#   2004/08/19 14:24:42+10:00 ianw@baci.gelato +2 -5
#   Remove extraneous debugging macros
#=20
# include/asm-ia64/mmu_context.h
#   2004/08/19 14:24:41+10:00 ianw@baci.gelato +1 -38
#   Remove extraneous debugging macros
#=20
diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	2004-08-19 14:27:07 +10:00
+++ b/include/asm-ia64/mmu_context.h	2004-08-19 14:27:07 +10:00
@@ -28,36 +28,6 @@
=20
 #include <asm/processor.h>
=20
-#define MMU_CONTEXT_DEBUG	0
-
-#if MMU_CONTEXT_DEBUG
-
-#include <ia64intrin.h>
-
-extern struct mmu_trace_entry {
-	char op;
-	u8 cpu;
-	u32 context;
-	void *mm;
-} mmu_tbuf[1024];
-
-extern volatile int mmu_tbuf_index;
-
-# define MMU_TRACE(_op,_cpu,_mm,_ctx)							\
-do {											\
-	int i =3D __sync_fetch_and_add(&mmu_tbuf_index, 1) % ARRAY_SIZE(mmu_tbuf)=
;	\
-	struct mmu_trace_entry e;							\
-	e.op =3D (_op);									\
-	e.cpu =3D (_cpu);									\
-	e.mm =3D (_mm);									\
-	e.context =3D (_ctx);								\
-	mmu_tbuf[i] =3D e;								\
-} while (0)
-
-#else
-# define MMU_TRACE(op,cpu,mm,ctx)	do { ; } while (0)
-#endif
-
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
@@ -123,7 +93,6 @@
 static inline int
 init_new_context (struct task_struct *p, struct mm_struct *mm)
 {
-	MMU_TRACE('N', smp_processor_id(), mm, 0);
 	mm->context =3D 0;
 	return 0;
 }
@@ -132,7 +101,6 @@
 destroy_context (struct mm_struct *mm)
 {
 	/* Nothing to do.  */
-	MMU_TRACE('D', smp_processor_id(), mm, mm->context);
 }
=20
 static inline void
@@ -171,19 +139,14 @@
=20
 	do {
 		context =3D get_mmu_context(mm);
-		MMU_TRACE('A', smp_processor_id(), mm, context);
 		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
 			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
 		reload_context(context);
-		MMU_TRACE('a', smp_processor_id(), mm, context);
 		/* in the unlikely event of a TLB-flush by another thread, redo the load=
: */
 	} while (unlikely(context !=3D mm->context));
 }
=20
-#define deactivate_mm(tsk,mm)					\
-do {								\
-	MMU_TRACE('d', smp_processor_id(), mm, mm->context);	\
-} while (0)
+#define deactivate_mm(tsk,mm)	do { } while (0)
=20
 /*
  * Switch from address space PREV to address space NEXT.
diff -Nru a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
--- a/include/asm-ia64/tlbflush.h	2004-08-19 14:27:07 +10:00
+++ b/include/asm-ia64/tlbflush.h	2004-08-19 14:27:07 +10:00
@@ -48,22 +48,19 @@
 static inline void
 flush_tlb_mm (struct mm_struct *mm)
 {
-	MMU_TRACE('F', smp_processor_id(), mm, mm->context);
 	if (!mm)
-		goto out;
+		return;
=20
 	mm->context =3D 0;
=20
 	if (atomic_read(&mm->mm_users) =3D=3D 0)
-		goto out;		/* happens as a result of exit_mmap() */
+		return;		/* happens as a result of exit_mmap() */
=20
 #ifdef CONFIG_SMP
 	smp_flush_tlb_mm(mm);
 #else
 	local_finish_flush_tlb_mm(mm);
 #endif
-  out:
-	MMU_TRACE('f', smp_processor_id(), mm, mm->context);
 }
=20
 extern void flush_tlb_range (struct vm_area_struct *vma, unsigned long sta=
rt, unsigned long end);

--hQiwHBbRI9kgIhsi--

--5QAgd0e35j3NYeGe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJDLGWDlSU/gp6ecRApd2AKDcYWwCmXnkRd6b1sOKXJeuE6Hz+wCfXZfQ
+W0XLkJ2Iq6Nv7cTpsrnD2E=
=WiLn
-----END PGP SIGNATURE-----

--5QAgd0e35j3NYeGe--
