From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jun 2002 19:42:07 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905726@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jun 2002 19:30:48 +0200 (DFT), Xavier Bru  <Xavier.Bru@bull.net> said:

  Xavier> It seems that null pointers passed as argument to syscalls
  Xavier> by wrong user code now generate a Oops, and enter kdb if
  Xavier> enabled.

I haven't seen a fix from Ken yet, so the patch below comes live from OLS...
Please test heavily and let me know how it goes.

Thanks,

	--david

--- lia64-2.4/arch/ia64/kernel/traps.c~	Thu Jun 20 18:56:08 2002
+++ lia64-2.4/arch/ia64/kernel/traps.c	Fri Jun 28 12:15:58 2002
@@ -497,7 +497,8 @@
 			siginfo.si_isr = isr;
 			force_sig_info(sig, &siginfo, current);
 			return;
-		}
+		} else if (done_with_exception(regs))
+			return;
 		sprintf(buf, "NaT consumption");
 		break;
 

