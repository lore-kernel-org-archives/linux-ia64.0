From: Eric Piel <Eric.Piel@Bull.Net>
Date: Wed, 14 May 2003 13:31:08 +0000
Subject: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------77706E40989B99B46ED5484E"
Message-Id: <marc-linux-ia64-105590723705787@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------77706E40989B99B46ED5484E
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,
There is a compile error if not compiling for SMP:

  gcc -Wp,-MD,arch/ia64/kernel/.mca.o.d -D__KERNEL__ -Iinclude -Wall
-Wstrict-prototypes -Wno-trigraphs -g -O2 -fno-strict-aliasing
-fno-common -pipe  -ffixed-r13 -mfixed-range=f10-f15,f32-f127
-falign-functions=32 -fomit-frame-pointer -nostdinc -iwithprefix include
-mconstant-gp   -DKBUILD_BASENAME=mca -DKBUILD_MODNAME=mca -c -o
arch/ia64/kernel/mca.o arch/ia64/kernel/mca.c
arch/ia64/kernel/mca.c: In function `init_handler_platform':
arch/ia64/kernel/mca.c:347: structure has no member named `write_lock'
arch/ia64/kernel/mca.c:359: structure has no member named `write_lock'
make[1]: *** [arch/ia64/kernel/mca.o] Error 1
make: *** [arch/ia64/kernel] Error 2

It's a bit obvious, in UP tasklist_lock doesn't contain any member :-(
The attached patch let the compilation go. However I don't think it
looks good, there is probably a cleaner way to solve this problem but my
knowledge about the locks is really too little...

Eric
--------------77706E40989B99B46ED5484E
Content-Type: text/plain; charset=us-ascii;
 name="UP-fix-2.5.69-030514.patch"
Content-Disposition: inline;
 filename="UP-fix-2.5.69-030514.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.5.69-ia64-perfmon/arch/ia64/kernel/mca.c	2003-05-12 13:21:54.000000000 +0200
+++ linux-2.5.69-ia64-030509.orig/arch/ia64/kernel/mca.c	2003-05-14 14:16:48.000000000 +0200
@@ -344,7 +344,9 @@
 	unw_init_from_interruption(&info, current, pt, sw);
 	ia64_do_show_stack(&info, NULL);
 
+#ifdef CONFIG_SMP
 	if (!tasklist_lock.write_lock)
+#endif
 		read_lock(&tasklist_lock);
 	{
 		struct task_struct *g, *t;
@@ -356,7 +358,9 @@
 			show_stack(t);
 		} while_each_thread (g, t);
 	}
+#ifdef CONFIG_SMP
 	if (!tasklist_lock.write_lock)
+#endif
 		read_unlock(&tasklist_lock);
 
 	printk("\nINIT dump complete.  Please reboot now.\n");

--------------77706E40989B99B46ED5484E--


