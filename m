From: Andreas Schwab <schwab@suse.de>
Date: Thu, 08 May 2003 14:16:13 +0000
Subject: [Linux-ia64] High fpu register corruption
Message-Id: <marc-linux-ia64-105590723705679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When a process clears the psr.mfh bit after using the high fpu registers
and then starts using them again it can corrupt the fpu state of another
process.  In order for this to happen there must be some context switches
inbetween (thanks to Chris Mason for tracking this down):

Processes start with psr.dfh=3D1, IA64_THREAD_FPH_VALID not set

proc A                               proc B
------                               ------
use fph reg
-> trap, mfh=3D1, dfh=3D0
-> fpu_owner =3D proc A
clear mfh (rum)

context switch
-> no registers saved
-> IA64_THREAD_FPH_VALID not set

                                     start running
                                     use fph reg
                                     -> trap, mfh=3D1, dfh=3D0
                                     -> fpu_owner =3D proc B

                                     context switch
                                     -> save registers, mfh=3D0
                                     -> set IA64_THREAD_FPH_VALID

continue running
-> IA64_THREAD_FPH_VALID not set
-> dfh not modified

modify fph reg
-> no trap
-> fpu_owner still proc B
clear mfh (rum)

context switch

                                     continue running
                                     -> fpu_owner still proc B
                                     -> dfh=3D0, mfh=3D0

At this point proc B uses the fph registers that were modified by proc A.
The problem is that dfh was not set for proc A although
IA64_THREAD_FPH_VALID wasn't set and proc A is not the fpu owner.  This
patch fixes the problem:

--- linux-2.4/include/asm-ia64/system.h.~1~	2003-05-07 15:44:44.000000000 +=
0200
+++ linux-2.4/include/asm-ia64/system.h	2003-05-07 15:31:47.000000000 +0200
@@ -281,7 +281,8 @@ extern void ia64_load_extra (struct task
 		} else {						\
 			ia64_psr(ia64_task_regs(next))->dfh =3D 1;	\
 		}							\
-	}								\
+	} else if (ia64_get_fpu_owner() !=3D next)			\
+		ia64_psr(ia64_task_regs(next))->dfh =3D 1;		\
 	__switch_to(prev,next,last);					\
   } while (0)
 #else


Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

