From: Keith Owens <kaos@sgi.com>
Date: Sat, 28 Feb 2004 09:45:38 +0000
Subject: Re: Oops in pdflush
Message-Id: <15420.1077961538@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Feb 2004 22:52:46 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sat, 28 Feb 2004 00:58:20 +1100, Keith Owens <kaos@sgi.com> said:
>  Keith> Ouch.  rbs and stack have collided, kernel stack overflow.  rbs shows
>  Keith> a normal start, then it loops with the same data over and over again
>
>So if I'm reading this right, we get a case that looks like unbounded
>recursion:
>
>	pdflush -> start_one_pdflush_thread -> kernel_thread -> pdflush ...
>
>Except, I don't think this is real recursion.  Instead, we effectively
>get a (potentially unbounded) sequence of one kernel thread creating
>another thread.  Each new kernel thread gets nested one deeper,
>eventually leading to a stack overflow...
>
>Hmmh, I think perhaps the right way to fix this is to use a separate
>continuation function, which will then take care of doing the
>child-specific actions.  Let me see if I can come up with something.

Separate the pdflush thread creation and move it to a single master
thread.  This restricts the maximum stack depth already in use when
starting a worker pdflush thread.

--- 2.6.3-pristine/mm/pdflush.c	Thu Dec 18 14:00:02 2003
+++ 2.6.3-pdflush/mm/pdflush.c	Sat Feb 28 20:42:04 2004
@@ -5,6 +5,9 @@
  *
  * 09Apr2002	akpm@zip.com.au
  *		Initial version
+ * 28Feb2004	kaos@sgi.com
+ *		Move worker thread creation to a master thread to avoid chewing
+ *		up stack space with nested calls to kernel_thread.
  */
 
 #include <linux/sched.h>
@@ -18,6 +21,7 @@
 #include <linux/fs.h>		// Needed by writeback.h
 #include <linux/writeback.h>	// Prototypes pdflush_operation()
 
+#include <asm/semaphore.h>
 
 /*
  * Minimum and maximum number of pdflush instances
@@ -58,6 +62,11 @@ int nr_pdflush_threads = 0;
 static unsigned long last_empty_jifs;
 
 /*
+ * up() this to start a new pdflush thread.
+ */
+static struct semaphore new_pdflush;
+
+/*
  * The pdflush thread.
  *
  * Thread pool management algorithm:
@@ -207,13 +216,31 @@ int pdflush_operation(void (*fn)(unsigne
 
 static void start_one_pdflush_thread(void)
 {
-	kernel_thread(pdflush, NULL, CLONE_KERNEL);
+	up(&new_pdflush);
+}
+
+/*
+ * Create all pdflush worker threads from a single master thread.  Creating
+ * worker threads from inside worker threads chews up kernel stack space and
+ * eventually overflows the kernel stack.
+ */
+static int pdflush_master(void *dummy)
+{
+	daemonize("pdflush_master");
+	while (1) {
+		if (down_interruptible(&new_pdflush))
+			continue;
+		kernel_thread(pdflush, NULL, CLONE_KERNEL);
+	}
+	return 0;
 }
 
 static int __init pdflush_init(void)
 {
 	int i;
 
+	kernel_thread(pdflush_master, NULL, CLONE_KERNEL);
+
 	for (i = 0; i < MIN_PDFLUSH_THREADS; i++)
 		start_one_pdflush_thread();
 	return 0;

===========================

This is what the ia64 stack for a pdflush worker thread looks like now.
It has used 560 bytes of stack from creation to sleep.

0xe00000003db08000       16        1  0    2   S  0xe00000003db08570  pdflush
0xa0000001000830f0 schedule+0xf30
0xa0000001000dab70 __pdflush+0x230
0xa0000001000daf00 pdflush+0x20
0xa000000100016bc0 kernel_thread+0x100
0xa0000001000db250 pdflush_master+0xb0
0xa000000100016bc0 kernel_thread+0x100
0xa000000100650670 pdflush_init+0x30
0xa000000100641100 do_initcalls+0xc0
0xa000000100009300 init+0xe0
0xa000000100016bc0 kernel_thread+0x100
0xa000000100009090 rest_init+0x30
0xa000000100640f80 start_kernel+0x460
0xa0000001000085a0 _start+0x280

It would be nice if kernel_thread reset the stack every time it was
called, but that requires arch specific helper code.  Until that is
available for every arch, avoid recursive calls to kernel_thread.

