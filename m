From: Andreas Schwab <schwab@suse.de>
Date: Sat, 15 May 2004 20:57:58 +0000
Subject: Error handling bug in fsys_rt_sigprocmask
Message-Id: <jeekplxvah.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When sigprocmask is called with an invalid first argument it still
modifies the signal mask of the process.

Andreas.

--- linux-2.6.5/arch/ia64/kernel/fsys.S.~1~	2004-04-04 05:38:28.000000000 +=
0200
+++ linux-2.6.5/arch/ia64/kernel/fsys.S	2004-05-14 15:43:11.456175248 +0200
@@ -444,6 +444,9 @@ EX(.fail_efault, ld8 r14=3D[r33])			// r14
 (p7)	cmp.ne.or.andcm p6,p7=3Dr18,r0		// p6/p7 <- signal pending
 	mov r19=3D0					// i must not leak kernel bits...
 (p6)	br.cond.dpnt.many .sig_pending
+
+	cmp.ne p9,p0=3Dr8,r0			// check for bad HOW value
+(p9)	br.cond.spnt.few 2f
 	;;
=20
 1:	ld4 r17=3D[r9]				// r17 <- current->thread_info->flags
@@ -458,11 +461,11 @@ EX(.fail_efault, ld8 r14=3D[r33])			// r14
 	cmp.ne p6,p0=3Dr17,r14			// update failed?
 (p6)	br.cond.spnt.few 1b			// yes -> retry
=20
+2:
 #ifdef CONFIG_SMP
 	st4.rel [r31]=3Dr0			// release the lock
 #endif
 	ssm psr.i
-	cmp.ne p9,p0=3Dr8,r0			// check for bad HOW value
 	;;
=20
 	srlz.d					// ensure psr.i is set again

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
