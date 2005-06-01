From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 01 Jun 2005 05:36:34 +0000
Subject: Another compilation warning gone...
Message-Id: <17053.18786.214006.350415@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This gets rid of an unused variable `error' in
sys_ia32.c:sys32_epoll_wait()

Getting rid of this one makes parsing the output of the kernecomp
autobuild easier --- searching for `Error' to find a problem kept
hitting this one, even though it's only a warning.


Index: linux-2.6-import/arch/ia64/ia32/sys_ia32.c
=================================--- linux-2.6-import.orig/arch/ia64/ia32/sys_ia32.c	2005-06-01 15:23:36.080332477 +1000
+++ linux-2.6-import/arch/ia64/ia32/sys_ia32.c	2005-06-01 15:26:12.358393256 +1000
@@ -2427,7 +2427,7 @@
 {
 	struct epoll_event *events64 = NULL;
 	mm_segment_t old_fs = get_fs();
-	int error, numevents, size;
+	int numevents, size;
 	int evt_idx;
 	int do_free_pages = 0;
 
