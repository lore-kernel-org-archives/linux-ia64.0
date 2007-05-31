From: Prarit Bhargava <prarit@redhat.com>
Date: Thu, 31 May 2007 15:58:14 +0000
Subject: [PATCH]: -mm tree remove __exit from loop_exit
Message-Id: <20070531155814.21159.454.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I sent this to lkml (and a large # of cc's).  Tony, please do not pick this
up in your tree.  I'm posting this here just so SGI users have this info ...

P.



Andrew, please patch ASAP as compile on SGI ia64 is broken.  Please note this
patch does not address why modpost did not pick up this error.

ie) ./scripts/mod/modpost drivers/block/built-in.o yields no information about
the section mismatch.  AFAIK, it should spit out a loud WARNING.

Patch against 2.6.22-rc3-mm1.

Current mm tree does not build with sn2_defconfig.  Build results in error:

`.exit.text' referenced in section `.init.text' of drivers/built-in.o: defined in discarded section `.exit.text' of drivers/built-in.o
make: *** [.tmp_vmlinux1] Error 1

__exit loop_exit is now being called from __init loop_init which causes this error.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

--- linux/drivers/block/loop.c.orig	2007-05-31 11:15:21.000000000 -0400
+++ linux/drivers/block/loop.c	2007-05-31 11:11:05.000000000 -0400
@@ -1456,7 +1456,7 @@ static struct kobject *loop_probe(dev_t 
 	return kobj;
 }
 
-static void __exit loop_exit(void)
+static void loop_exit(void)
 {
 	unsigned long range;
 	struct loop_device *lo, *next;
