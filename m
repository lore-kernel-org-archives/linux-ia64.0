From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 03 Mar 2004 23:06:16 +0000
Subject: Re: ia32 sigwait patch
Message-Id: <200403031606.16257.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 23 February 2004 11:52 am, you wrote:
> ia32 rt_sigtimewait() fails when some of the arguments are NULL. The
> fix is attached.

Sorry for the delay in responding; I've been out of the office for
a while.  I applied the patch (with the addition of a few spaces
in the ternary operator).

It looks to me like current 2.4 on x86_64 suffers from the same
problem with uts (sys_rt_sigtimedwait() gets a pointer to
uninitialized "t" when uts is NULL).

--- linux-2.4.21-4.EL/arch/ia64/ia32/ia32_signal.c.ori	2003-11-17 13:42:01.000000000 +0800
+++ linux-2.4.21-4.EL/arch/ia64/ia32/ia32_signal.c	2003-11-17 13:44:14.000000000 +0800
@@ -614,7 +614,7 @@
 			return -EFAULT;
 	}
 	set_fs(KERNEL_DS);
-	ret = sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
+	ret = sys_rt_sigtimedwait(&s, uinfo? &info :NULL, uts? &t :NULL, sigsetsize);
 	set_fs(old_fs);
 	if (ret >= 0 && uinfo) {
 		if (copy_siginfo_to_user32(uinfo, &info))

