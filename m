From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 11 Dec 2002 12:48:15 +0000
Subject: [Linux-ia64] [patch] 2.4.20-ia64-021210 prevent loop on zero instruction
Message-Id: <marc-linux-ia64-105590709805543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 10 Dec 2002 21:44:12 -0700, 
Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:
>The latest ia64 kernel patch for Linux 2.4.20 is available here:
>
>    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.20-ia64-021210.diff.gz

Trivial backport of a fix from 2.5 ia64.  Prevents the kernel looping
on a zero instruction.

--- arch/ia64/kernel/traps.c.orig	Wed Dec 11 23:44:14 2002
+++ arch/ia64/kernel/traps.c	Wed Dec 11 23:45:47 2002
@@ -143,6 +143,7 @@
 
 	switch (break_num) {
 	      case 0: /* unknown error */
+		die_if_kernel("bad break", regs, break_num);
 		sig = SIGILL; code = ILL_ILLOPC;
 		break;
 


