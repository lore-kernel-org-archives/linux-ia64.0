From: Andreas Schwab <schwab@suse.de>
Date: Mon, 27 Nov 2000 15:51:01 +0000
Subject: [Linux-ia64] __NR_sys_pivot_root -> __NR_pivot_root
Message-Id: <marc-linux-ia64-105590678205774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes a typo in <linux/unistd.h> in the 2.4.0-test10-ia64-001115
kernel.

--- include/asm-ia64/unistd.h
+++ include/asm-ia64/unistd.h	2000/11/27 15:46:40
@@ -196,7 +196,7 @@
 #define __NR_getsockopt			1204
 #define __NR_sendmsg			1205
 #define __NR_recvmsg			1206
-#define __NR_sys_pivot_root		1207
+#define __NR_pivot_root			1207
 #define __NR_mincore			1208
 #define __NR_madvise			1209
 #define __NR_stat			1210

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

