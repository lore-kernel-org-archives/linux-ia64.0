From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Oct 2004 15:45:26 +0000
Subject: yet another sparse-detected bug fix
Message-Id: <200410041545.i94FjQd0031552@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun,

copy_siginfo_from_user32() directly dereferences a user-pointer, which
is a no-no.  At that point, to->si_code already has been initialized
so I think we can just use to->si_code instead.  Compile-tested (only)
patch attached.

Signed-off-by: davidm@hpl.hp.com

=== arch/ia64/ia32/ia32_signal.c 1.30 vs edited ==--- 1.30/arch/ia64/ia32/ia32_signal.c	2004-09-21 12:36:02 -07:00
+++ edited/arch/ia64/ia32/ia32_signal.c	2004-10-04 07:38:03 -07:00
@@ -78,10 +78,10 @@
 	err |= __get_user(to->si_errno, &from->si_errno);
 	err |= __get_user(to->si_code, &from->si_code);
 
-	if (from->si_code < 0)
+	if (to->si_code < 0)
 		err |= __copy_from_user(&to->_sifields._pad, &from->_sifields._pad, SI_PAD_SIZE);
 	else {
-		switch (from->si_code >> 16) {
+		switch (to->si_code >> 16) {
 		      case __SI_CHLD >> 16:
 			err |= __get_user(to->si_utime, &from->si_utime);
 			err |= __get_user(to->si_stime, &from->si_stime);
