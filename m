From: Andreas Schwab <schwab@suse.de>
Date: Tue, 02 Oct 2001 14:06:37 +0000
Subject: Re: [Linux-ia64] [patch] quick combo patch relative to 2.4.10+010924 ia64 patch
Message-Id: <marc-linux-ia64-105590698805289@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is another patch for the ia32 subsystem: the case SHMAT falls
through in sys32_ipc, but there is nothing that returns err to the caller.

--- linux/arch/ia64/ia32/sys_ia32.c.~1~	Tue Oct  2 11:08:44 2001
+++ linux/arch/ia64/ia32/sys_ia32.c	Tue Oct  2 11:15:49 2001
@@ -2575,8 +2575,7 @@
 		return msgctl32(first, second, (void *)AA(ptr));
=20
 	      case SHMAT:
-		err =3D shmat32(first, second, third, version, (void *)AA(ptr));
-		break;
+		return shmat32(first, second, third, version, (void *)AA(ptr));
 	      case SHMDT:
 		return sys_shmdt((char *)AA(ptr));
 	      case SHMGET:

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

