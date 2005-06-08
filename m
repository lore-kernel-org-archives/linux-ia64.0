From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Jun 2005 16:13:29 +0000
Subject: RE: Fix floating-point preemption problem
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03A587A9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506080915.j589FXFm013110@mail08.syd.optusnet.com.au>
In-Reply-To: <200506080915.j589FXFm013110@mail08.syd.optusnet.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>	The only places where the FPU state is touched are in ptrace,  
>in switch_to(), and where handling a floating-point exception. In
>switch_to() preemption is off.  So it's only in trap.c and ptrace.c
>that we need to prevent preemption.

What about restore_sigcontext()?  It looks like we touch FPU state there
too, and it further appears that preemption is enabled.  Don't you
also need (Caution: Outlook may line-wrap this patch):

arch/ia64/kernel/signal.c: needs update
Index: arch/ia64/kernel/signal.c
=================================--- 49f908df283332371b74c4686dd2f0109db2bc61/arch/ia64/kernel/signal.c  (mode:100644)
+++ uncommitted/arch/ia64/kernel/signal.c  (mode:100644)
@@ -141,6 +141,7 @@
 		struct ia64_psr *psr = ia64_psr(&scr->pt);
 
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
+		preempt_disable();
 		psr->mfh = 0;	/* drop signal handler's fph contents... */
 		if (psr->dfh)
 			ia64_drop_fpu(current);
@@ -149,6 +150,7 @@
 			__ia64_load_fpu(current->thread.fph);
 			ia64_set_local_fpu_owner(current);
 		}
+		preempt_enable();
 	}
 	return err;
 }


-Tony
