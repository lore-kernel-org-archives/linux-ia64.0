From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 18 Aug 2004 04:25:58 +0000
Subject: What is MMU_TRACE for?
Message-Id: <20040818042558.GC1170@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="+B+y8wtTXqdUj1xM"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--+B+y8wtTXqdUj1xM
Content-Type: multipart/mixed; boundary="/e2eDi0V/xtL+Mc8"
Content-Disposition: inline


--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The change @ http://tinyurl.com/4g5dz introduced MMU_TRACE, but left
the structure to keep the traces in as extern with no corresponding
definition.  Is maybe some of the patch missing?  What was its
original intention?

I actaully wanted to use something like this, so just exported it out
to a proc entry (attached just for the archives).

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mmu_debug.patch"
Content-Transfer-Encoding: quoted-printable

Index: linux-dev-tree/include/asm-ia64/mmu_context.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-dev-tree.orig/include/asm-ia64/mmu_context.h	2004-08-17 16:31:48.=
000000000 +1000
+++ linux-dev-tree/include/asm-ia64/mmu_context.h	2004-08-18 13:56:16.34032=
7806 +1000
@@ -28,24 +28,25 @@
=20
 #include <asm/processor.h>
=20
-#define MMU_CONTEXT_DEBUG	0
-
-#if MMU_CONTEXT_DEBUG
+#ifdef CONFIG_IA64_DEBUG_MMU_CONTEXT
=20
 #include <ia64intrin.h>
=20
-extern struct mmu_trace_entry {
+#define MMU_DEBUG_CONTEXT_ENTRIES 512
+
+struct mmu_trace_entry {
 	char op;
 	u8 cpu;
 	u32 context;
 	void *mm;
-} mmu_tbuf[1024];
+};
=20
+extern struct mmu_trace_entry mmu_tbuf[MMU_DEBUG_CONTEXT_ENTRIES];
 extern volatile int mmu_tbuf_index;
=20
 # define MMU_TRACE(_op,_cpu,_mm,_ctx)							\
 do {											\
-	int i =3D __sync_fetch_and_add(&mmu_tbuf_index, 1) % ARRAY_SIZE(mmu_tbuf)=
;	\
+	int i =3D __sync_fetch_and_add(&mmu_tbuf_index, 1) % MMU_DEBUG_CONTEXT_EN=
TRIES;	\
 	struct mmu_trace_entry e;							\
 	e.op =3D (_op);									\
 	e.cpu =3D (_cpu);									\
@@ -180,10 +181,16 @@
 	} while (unlikely(context !=3D mm->context));
 }
=20
-#define deactivate_mm(tsk,mm)					\
-do {								\
-	MMU_TRACE('d', smp_processor_id(), mm, mm->context);	\
+#ifdef CONFIG_IA64_DEBUG_MMU_CONTEXT
+#define deactivate_mm(tsk,mm)							\
+do {										\
+	/* Kernel threads may not have an mm */					\
+	if (mm)									\
+		MMU_TRACE('d', smp_processor_id(), mm, mm->context);		\
 } while (0)
+#else
+#define deactivate_mm(tsk,mm) do {} while (0)
+#endif
=20
 /*
  * Switch from address space PREV to address space NEXT.
Index: linux-dev-tree/arch/ia64/mm/debug_mmu_context.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-dev-tree/arch/ia64/mm/debug_mmu_context.c	2004-08-18 14:12:40.398=
909502 +1000
@@ -0,0 +1,75 @@
+/*
+ * MMU context switching debugging=20
+ *
+ * Copyright (C) 2004 Gelato@UNSW
+ *	Ian Wienand <ianw@gelato.unsw.edu.au>
+ */
+=20
+#include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/types.h>
+#include <linux/module.h>
+=20
+#include <asm/mmu_context.h>
+
+#ifdef CONFIG_IA64_DEBUG_MMU_CONTEXT
+
+MODULE_AUTHOR("Ian Wienand <ianw@gelato.unsw.edu.au>");
+MODULE_DESCRIPTION("/proc interface to MMU context switch debugging");
+MODULE_LICENSE("GPL");
+
+/* The main structure holding all the trace entries */
+struct mmu_trace_entry mmu_tbuf[MMU_DEBUG_CONTEXT_ENTRIES];
+volatile int mmu_tbuf_index;
+
+static struct proc_dir_entry *mmu_context_debug_file;
+
+static int proc_read_mmu_context_debug(char *buf, char **start,
+                             off_t fpos, int length,
+                             int *eof, void *data)
+{
+	int i =3D 0;
+	int len =3D 0, printed =3D 0;
+
+	while (i < MMU_DEBUG_CONTEXT_ENTRIES)
+	{
+		struct mmu_trace_entry *p =3D &mmu_tbuf[i];
+		if (p->op)
+			len +=3D sprintf(buf+len, "%4d|%c|%2d|%5d%s",=20
+				       i, p->op, p->cpu,=20
+				       p->context,=20
+				       (++printed % 5) ? " * ":"\n");=20
+		i++;
+	}
+	len +=3D sprintf(buf+len, "\n");
+
+        if (fpos >=3Dlen){
+                *start =3D buf;
+                *eof =3D 1;
+                return 0;
+        }
+        *start =3D buf + fpos;
+        if ((len -=3D fpos) > length)
+                return length;
+        *eof =3D 1;
+        return len;
+}
+
+static int __init init_mmu_context_debug_init(void)
+{
+	int rv =3D 0;
+
+	mmu_context_debug_file =3D create_proc_read_entry("mmu_context_debug",
+                                              0444, &proc_root,
+                                              proc_read_mmu_context_debug,
+                                              NULL);
+        if(mmu_context_debug_file =3D=3D NULL) {
+                rv  =3D -ENOMEM;
+        }
+
+	return rv;
+}
+
+module_init(init_mmu_context_debug_init);
+
+#endif /* CONFIG_IA64_DEBUG_MMU_CONTEXT */
Index: linux-dev-tree/arch/ia64/mm/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-dev-tree.orig/arch/ia64/mm/Makefile	2004-08-17 16:31:35.000000000=
 +1000
+++ linux-dev-tree/arch/ia64/mm/Makefile	2004-08-18 13:56:16.340327806 +1000
@@ -7,6 +7,7 @@
 obj-$(CONFIG_HUGETLB_PAGE) +=3D hugetlbpage.o
 obj-$(CONFIG_NUMA)	   +=3D numa.o
 obj-$(CONFIG_DISCONTIGMEM) +=3D discontig.o
+obj-$(CONFIG_IA64_DEBUG_MMU_CONTEXT) +=3D debug_mmu_context.o
 ifndef CONFIG_DISCONTIGMEM
 obj-y +=3D contig.o
 endif
Index: linux-dev-tree/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-dev-tree.orig/arch/ia64/Kconfig	2004-08-16 15:00:10.000000000 +10=
00
+++ linux-dev-tree/arch/ia64/Kconfig	2004-08-18 13:56:16.341304369 +1000
@@ -471,6 +471,13 @@
 	  and restore instructions.  It's useful for tracking down spinlock
 	  problems, but slow!  If you're unsure, select N.
=20
+config IA64_DEBUG_MMU_CONTEXT
+	bool "Trace MMU on context switches"
+	depends on DEBUG_KERNEL
+	help
+	  Selecting this option turns on /proc/debug_mmu where you can see what
+	  the kernel has been up to when it is doing context switches.
+	 =20
 config DEBUG_INFO
 	bool "Compile the kernel with debug info"
 	depends on DEBUG_KERNEL

--/e2eDi0V/xtL+Mc8--

--+B+y8wtTXqdUj1xM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBItpWWDlSU/gp6ecRAvTaAKCdhNh4+T0xcipx6gF87gEbEvIHJACfYbrm
XjvBYM1NaK/6rTnL/aVIPg8=
=aU1+
-----END PGP SIGNATURE-----

--+B+y8wtTXqdUj1xM--
