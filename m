From: Andreas Schwab <schwab@suse.de>
Date: Mon, 10 Jan 2005 13:13:30 +0000
Subject: Fix PTRACE_GETEVENTMSG ia32 emulation
Message-Id: <jevfa5bf5x.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch fixes PTRACE_GETEVENTMSG for the ia32 emulation.  The parameter
is a pointer, thus needs to be converted.

Signed-off-by: Andreas Schwab <schwab@suse.de>

--- linux-2.6.10.orig/arch/ia64/ia32/sys_ia32.c	2004-12-24 22:35:00.0000000=
00 +0100
+++ linux-2.6.10/arch/ia64/ia32/sys_ia32.c	2005-01-10 14:03:37.219046133 +0=
100
@@ -1894,6 +1894,10 @@ sys32_ptrace (int request, pid_t pid, un
 					    compat_ptr(data));
 		break;
=20
+	      case PTRACE_GETEVENTMSG:  =20
+		ret =3D put_user(child->ptrace_message, (unsigned int __user *) A(data));
+		break;
+
 	      case PTRACE_SYSCALL:	/* continue, stop after next syscall */
 	      case PTRACE_CONT:		/* restart after signal. */
 	      case PTRACE_KILL:

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
