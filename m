From: Tim Schmielau <tim@physik3.uni-rostock.de>
Date: Sun, 22 Sep 2002 11:45:51 +0000
Subject: [Linux-ia64] [patch] fix compares of jiffies
Message-Id: <marc-linux-ia64-105590701906045@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Linux kernel code maintainer,

on rechecking the current stable kernel code, I found some places where jiffies
were compared in a way that seems to break when they wrap. For these,
I made up patches to use the macros "time_before()" or "time_after()"
that are supposed to handle wraparound correctly.

For a small part of the patches, I believe you to be the relevant kernel code
maintainer. Appended to this email you will find some lines explaining
why I decided to mail or cc: you on this (an extract of the copyright notice
or the MAINTAINERS file), followed by the patch itself. If I mailed you
in error, please drop me a short note.

I kindly ask you to approve the correctness of the patch, and pass it on to
the relevant people for inclusion into the mainline kernel.

Thanks,
Tim Schmielau (tim@physik3.uni-rostock.de)



IA64 (Itanium) PLATFORM
P:	David Mosberger-Tang
M:	davidm@hpl.hp.com
L:	linux-ia64@linuxia64.org
W:	http://www.linuxia64.org/
S:	Maintained



--- linux-2.4.20-pre6/include/asm-ia64/sn/bte_copy.h	Sat Aug  3 02:39:45 2002
+++ linux-2.4.20-pre6-jfix/include/asm-ia64/sn/bte_copy.h	Wed Sep 11 11:59:32 2002
@@ -250,7 +250,7 @@
 			 * status register into the notification area.
 			 * This fakes the shub performing the copy.
 			 */
-			if (jiffies > bte->idealTransferTimeout) {
+			if (time_after(jiffies, bte->idealTransferTimeout)) {
 				bte->notify = HUB_L(bte->bte_base_addr);
 				bte->idealTransferTimeoutReached++;
 				bte->idealTransferTimeout = jiffies +

