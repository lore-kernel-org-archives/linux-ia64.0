From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 26 Feb 2008 21:14:21 +0000
Subject: Re: [PATCH 4/8] ia64/pv_ops: paravirtualize arch/ia64/kernel/switch_leave.S
Message-Id: <4471.1204060461@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <12040343393726-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12040343393726-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata (on Tue, 26 Feb 2008 22:58:55 +0900) wrote:
> /*
>  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
>@@ -153,7 +165,8 @@ END(__ia64_switch_to)
>  *	      ar.csd: cleared
>  *	      ar.ssd: cleared
>  */
>-GLOBAL_ENTRY(__ia64_leave_syscall)
>+GLOBAL_ENTRY(__paravirt_leave_syscall)
>+	BR_IF_NATIVE(__ia64_leave_syscall, r22, p7)
> 	PT_REGS_UNWIND_INFO(0)

Move BR_IF_NATIVE after PT_REGS_UNWIND_INFO.  PT_REGS_UNWIND_INFO must
define the unwind state at slot 0 of this function to get correct
unwind state.  When virtualized, BR_IF_NATIVE will generate extra code
and move the unwind data past slot 0, breaking the backtrace.

>-GLOBAL_ENTRY(__ia64_leave_kernel)
>+GLOBAL_ENTRY(__paravirt_leave_kernel)
>+	BR_IF_NATIVE(__ia64_leave_kernel, r22, p7)
> 	PT_REGS_UNWIND_INFO(0)

Ditto.

