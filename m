From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 05 Jan 2002 01:03:35 +0000
Subject: [Linux-ia64] [PATCH]  Support for alternative kernel profiler in a module
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C19584.CD119DB0"
Message-Id: <marc-linux-ia64-105590698805742@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C19584.CD119DB0
Content-Type: text/plain;
	charset="iso-8859-1"

To allow an alternative kernel profiler using the ia64
perfomance counters to be loaded as a module, a couple
of small changes are needed.

1) Define a new 'irqflags' bit (SA_PERCPU_IRQ) to allow a module
to request a per-cpu irq.

2) Export init_tasks[] so that the module can adjust the state
of psr.pp in the idle tasks for all CPUs.

I've attached the patch rather than inlining it in the hope that
outlook won't sabotage it by folding long lines or playing with
tabs and spaces.

-Tony Luck


------_=_NextPart_000_01C19584.CD119DB0
Content-Type: application/octet-stream;
	name="DIFF"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="DIFF"

diff -ru ../../REF/2.4.17-ia64-011226/arch/ia64/kernel/irq.c =
linux/arch/ia64/kernel/irq.c=0A=
--- ../../REF/2.4.17-ia64-011226/arch/ia64/kernel/irq.c	Mon Dec 31 =
09:02:35 2001=0A=
+++ linux/arch/ia64/kernel/irq.c	Fri Jan  4 16:17:35 2002=0A=
@@ -1010,6 +1010,11 @@=0A=
 		rand_initialize_irq(irq);=0A=
 	}=0A=
 =0A=
+	if (new->flags & SA_PERCPU_IRQ) {=0A=
+		desc->status |=3D IRQ_PER_CPU;=0A=
+		desc->handler =3D &irq_type_ia64_lsapic;=0A=
+	}=0A=
+=0A=
 	/*=0A=
 	 * The following block of code has to be executed atomically=0A=
 	 */=0A=
diff -ru ../../REF/2.4.17-ia64-011226/include/asm-ia64/signal.h =
linux/include/asm-ia64/signal.h=0A=
--- ../../REF/2.4.17-ia64-011226/include/asm-ia64/signal.h	Wed Oct  3 =
11:32:32 2001=0A=
+++ linux/include/asm-ia64/signal.h	Fri Jan  4 16:23:52 2002=0A=
@@ -111,10 +111,12 @@=0A=
  *=0A=
  * SA_INTERRUPT is also used by the irq handling routines.=0A=
  * SA_SHIRQ is for shared interrupt support on PCI and EISA.=0A=
+ * SA_PERCPU_IRQ is for processor internal interrupts=0A=
  */=0A=
 #define SA_PROBE		SA_ONESHOT=0A=
 #define SA_SAMPLE_RANDOM	SA_RESTART=0A=
 #define SA_SHIRQ		0x04000000=0A=
+#define SA_PERCPU_IRQ		0x02000000=0A=
 =0A=
 #endif /* __KERNEL__ */=0A=
 =0A=
diff -ru ../../REF/2.4.17-ia64-011226/kernel/ksyms.c =
linux/kernel/ksyms.c=0A=
--- ../../REF/2.4.17-ia64-011226/kernel/ksyms.c	Mon Dec 31 09:02:39 =
2001=0A=
+++ linux/kernel/ksyms.c	Fri Jan  4 16:22:11 2002=0A=
@@ -556,6 +556,7 @@=0A=
 /* init task, for moving kthread roots - ought to export a function ?? =
*/=0A=
 =0A=
 EXPORT_SYMBOL(init_task_union);=0A=
+EXPORT_SYMBOL(init_tasks);=0A=
 =0A=
 EXPORT_SYMBOL(tasklist_lock);=0A=
 EXPORT_SYMBOL(pidhash);=0A=

------_=_NextPart_000_01C19584.CD119DB0--

