From: Keith Owens <kaos@sgi.com>
Date: Sun, 29 Feb 2004 03:44:30 +0000
Subject: Re: Oops in pdflush
Message-Id: <7172.1078026270@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 28 Feb 2004 02:23:23 -0800, 
Andrew Morton <akpm@osdl.org> wrote:
>We should use the new kthread infrastructure rather than open-coding it. 
>It delegates thread startup to keventd and should thus avoid the stack
>windup.

Convert pdflush to kthread to avoid stack windup.

Index: 4-rc1.1/mm/pdflush.c
--- 4-rc1.1/mm/pdflush.c Thu, 18 Dec 2003 16:46:13 +1100 kaos (linux-2.6/20_pdflush.c 1.1 644)
+++ 4-rc1.1(w)/mm/pdflush.c Sun, 29 Feb 2004 14:28:02 +1100 kaos (linux-2.6/20_pdflush.c 1.1 644)
@@ -5,6 +5,9 @@
  *
  * 09Apr2002	akpm@zip.com.au
  *		Initial version
+ * 29Feb2004	kaos@sgi.com
+ *		Move worker thread creation to kthread to avoid chewing
+ *		up stack space with nested calls to kernel_thread.
  */
 
 #include <linux/sched.h>
@@ -17,6 +20,7 @@
 #include <linux/suspend.h>
 #include <linux/fs.h>		// Needed by writeback.h
 #include <linux/writeback.h>	// Prototypes pdflush_operation()
+#include <linux/kthread.h>
 
 
 /*
@@ -207,7 +211,7 @@ int pdflush_operation(void (*fn)(unsigne
 
 static void start_one_pdflush_thread(void)
 {
-	kernel_thread(pdflush, NULL, CLONE_KERNEL);
+	kthread_run(pdflush, NULL, "pdflush");
 }
 
 static int __init pdflush_init(void)


Rusty, does pdflush() still need to call daemonize() or does kthread
make that redundant?


pdflush backtrace using kthread, without ia64 kernel_thread_helper.
This has got worse.  2.6.3 using kernel_thread used 560 bytes of stack
and 744 bytes of rbs, 2.6.4-rc1 with kthread uses 1120 stack and 1312
rbs.

See http://marc.theaimsgroup.com/?l=linux-ia64&m7796262112591&w=2
for 2.6.3 backtraces.

0xa000000100083650 schedule+0xf30
        sp 0xe00000003dabfba0 bsp 0xe00000003dab9440 cfm 0x0000000000000f26
0xa0000001000dc730 __pdflush+0x230
0xa0000001000dcac0 pdflush+0x20
0xa0000001000c0720 kthread+0x200
0xa000000100016bc0 kernel_thread+0x100
0xa0000001000c0770 keventd_create_kthread+0x30
0xa0000001000b7b10 worker_thread+0x450
0xa0000001000c0720 kthread+0x200
0xa000000100016bc0 kernel_thread+0x100
0xa0000001000c0770 keventd_create_kthread+0x30
0xa0000001000c0a00 kthread_create+0x200
0xa0000001000b80c0 create_workqueue_thread+0x100
0xa0000001000b82e0 create_workqueue+0x1a0
0xa0000001000b89a0 init_workqueues+0x20
0xa000000100645290 do_basic_setup+0x50
0xa000000100009300 init+0xe0
0xa000000100016bc0 kernel_thread+0x100
0xa000000100009090 rest_init+0x30
0xa000000100644fc0 start_kernel+0x4a0
0xa0000001000085a0 _start+0x280
        sp 0xe00000003dabfe30 bsp 0xe00000003dab8f20 cfm 0x0000000000000794

pdflush backtrace using kthread, with ia64 kernel_thread_helper.  This
has also got worse.  2.6.3 using kernel_thread and helper used 554
bytes of stack and 272 bytes of rbs, 2.6.4-rc1 with kthread and helper
uses 640 stack and 376 rbs.

0xa0000001000837f0 schedule+0xf30
        sp 0xe00000003dabfd80 bsp 0xe00000003dab9098 cfm 0x0000000000000f26
0xa0000001000dc8d0 __pdflush+0x230
0xa0000001000dcc60 pdflush+0x20
0xa0000001000c08c0 kthread+0x200
0xa000000100016d70 kernel_thread_helper+0xd0
0xa000000100009040 ia64_invoke_kernel_thread_helper+0x20
        sp 0xe00000003dabfe30 bsp 0xe00000003dab8f20 cfm 0x0000000000000002

This says two things - every architecture should have a kernel_thread
helper and using kthread adds some stack overhead, even with a helper.
The latter is acceptable if it makes the code more reliable.

