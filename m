From: Andreas Schwab <schwab@suse.de>
Date: Tue, 18 Mar 2003 14:33:42 +0000
Subject: [Linux-ia64] Idenitfier clash in read_[un]lock
Message-Id: <marc-linux-ia64-105590709806152@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The read_lock and read_unlock macros should not use such innocent variable
names like tmp because they have a high probability to clash with (part
of) the argument.

Andreas.

--- include/asm-ia64/spinlock.h.~1~	2002-08-03 02:39:45.000000000 +0200
+++ include/asm-ia64/spinlock.h	2003-03-18 10:10:19.000000000 +0100
@@ -112,7 +112,7 @@ typedef struct {
=20
 #define read_lock(rw)								\
 do {										\
-	int tmp =3D 0;								\
+	int __read_lock_tmp =3D 0;						\
 	__asm__ __volatile__ ("1:\tfetchadd4.acq %0 =3D [%1], 1\n"		\
 			      ";;\n"						\
 			      "tbit.nz p6,p0 =3D %0, 31\n"			\
@@ -127,15 +127,15 @@ do {										\
 			      "br.cond.sptk.few 1b\n"				\
 			      ";;\n"						\
 			      ".previous\n"					\
-			      : "=3D&r" (tmp)					\
+			      : "=3D&r" (__read_lock_tmp)				\
 			      : "r" (rw) : "p6", "memory");			\
 } while(0)
=20
 #define read_unlock(rw)								\
 do {										\
-	int tmp =3D 0;								\
+	int __read_unlock_tmp =3D 0;						\
 	__asm__ __volatile__ ("fetchadd4.rel %0 =3D [%1], -1\n"			\
-			      : "=3Dr" (tmp)					\
+			      : "=3Dr" (__read_unlock_tmp)			\
 			      : "r" (rw)					\
 			      : "memory");					\
 } while(0)

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

