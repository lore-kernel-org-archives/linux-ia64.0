From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 21 Jan 2005 03:32:48 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <200501210332.j0L3Wmg24796@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 15:22:59 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:
>
>   Rohit> We are also thinking of reseting the mfh bit on every syscall
>   Rohit> entry as an optimization.
>
>   Rohit> Comments?

David Mosberger wrote on Thursday, January 20, 2005 3:51 PM
> Sounds OK with me.  We should delete this comment from process.c then,
> ....
> and change:
>
> #define THREAD_FLAGS_TO_CLEAR (IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID \
>                                | IA64_THREAD_PM_VALID)
>
> to:
>
> #define THREAD_FLAGS_TO_CLEAR (IA64_THREAD_DBG_VALID | IA64_THREAD_PM_VALID)

We would rather not to change THREAD_FLAGS_TO_CLEAR definition.  mfh bit in child
pt_regs is cleared right above where the comment is.  I think it is better as is
so that child thread fph partition stays invalidated.

- Ken


