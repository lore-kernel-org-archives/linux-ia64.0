From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 29 Jun 2002 20:02:17 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I wasn't on the mailing list so this came to my attention a bit late.  Prior
to nat page, a fault like this would route to the associated exception
handler via page fault handler since there is no mapping of virtual address
0.  Now with nat page, there is a mapping of address 0, but non-speculative
read/write is not allowed on that page.  Since fault routing is not there, a
segfault would occur.  The fix that David provided would fix the problem as
I already tested out.  Thanks.

- Ken


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Friday, June 28, 2002 12:42 PM
To: Xavier Bru
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.18)


>>>>> On Wed, 26 Jun 2002 19:30:48 +0200 (DFT), Xavier Bru
<Xavier.Bru@bull.net> said:

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
 

