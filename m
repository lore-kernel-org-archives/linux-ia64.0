From: Andreas Schwab <schwab@suse.de>
Date: Fri, 10 Oct 2003 15:06:16 +0000
Subject: Misnamed syscalls
Message-Id: <marc-linux-ia64-106579856912123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes a misnomer of some syscalls in 2.6.0-test[567].  Glibc wants
them without the sys_ infix.

Andreas.

--- linux-2.6.0-test7/include/asm-ia64/unistd.h.~1~	2003-10-08 21:24:02.000=
000000 +0200
+++ linux-2.6.0-test7/include/asm-ia64/unistd.h	2003-10-10 16:57:46.0000000=
00 +0200
@@ -237,17 +237,17 @@
 #define __NR_epoll_wait			1245
 #define __NR_restart_syscall		1246
 #define __NR_semtimedop			1247
-#define __NR_sys_timer_create		1248
-#define __NR_sys_timer_settime		1249
-#define __NR_sys_timer_gettime		1250
-#define __NR_sys_timer_getoverrun	1251
-#define __NR_sys_timer_delete		1252
-#define __NR_sys_clock_settime		1253
-#define __NR_sys_clock_gettime		1254
-#define __NR_sys_clock_getres		1255
-#define __NR_sys_clock_nanosleep	1256
-#define __NR_sys_fstatfs64		1257
-#define __NR_sys_statfs64		1258
+#define __NR_timer_create		1248
+#define __NR_timer_settime		1249
+#define __NR_timer_gettime		1250
+#define __NR_timer_getoverrun		1251
+#define __NR_timer_delete		1252
+#define __NR_clock_settime		1253
+#define __NR_clock_gettime		1254
+#define __NR_clock_getres		1255
+#define __NR_clock_nanosleep		1256
+#define __NR_fstatfs64			1257
+#define __NR_statfs64			1258
=20
 #ifdef __KERNEL__
=20

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
