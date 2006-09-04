From: Andreas Schwab <schwab@suse.de>
Date: Mon, 04 Sep 2006 19:56:09 +0000
Subject: [PATCH] Unwire set/get_robust_list
Message-Id: <jek64jflt2.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The syscalls set/get_robust_list must not be wired up until
futex_atomic_cmpxchg_inatomic is implemented.  Otherwise the kernel will
hang in handle_futex_death.

Signed-off-by: Andreas Schwab <schwab@suse.de>

Index: linux-2.6.18-rc6/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.18-rc6.orig/arch/ia64/kernel/entry.S	=
2006-09-04 20:58:32.000000000 +0200
+++ linux-2.6.18-rc6/arch/ia64/kernel/entry.S	2006-09-04 21:02:16.000000000=
 +0200
@@ -1605,8 +1605,8 @@ sys_call_table:
 	data8 sys_ni_syscall			// 1295 reserved for ppoll
 	data8 sys_unshare
 	data8 sys_splice
-	data8 sys_set_robust_list
-	data8 sys_get_robust_list
+	data8 sys_ni_syscall			// reserved for set_robust_list
+	data8 sys_ni_syscall			// reserved for get_robust_list
 	data8 sys_sync_file_range		// 1300
 	data8 sys_tee
 	data8 sys_vmsplice
Index: linux-2.6.18-rc6/include/asm-ia64/systbl.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.18-rc6.orig/include/asm-ia64/unistd.h=
	2006-09-04 20:59:21.000000000 +0200
+++ linux-2.6.18-rc6/include/asm-ia64/unistd.h	2006-09-04 21:01:02.00000000=
0 +0200
@@ -286,8 +286,7 @@
 /* 1294, 1295 reserved for pselect/ppoll */
 #define __NR_unshare			1296
 #define __NR_splice			1297
-#define __NR_set_robust_list		1298
-#define __NR_get_robust_list		1299
+/* 1298, 1299 reserved for set_robust_list/get_robust_list */
 #define __NR_sync_file_range		1300
 #define __NR_tee			1301
 #define __NR_vmsplice			1302

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
