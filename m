From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 04:35:47 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
Message-Id: <marc-linux-ia64-105590723706069@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706053@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706053@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 28 May 2003 1:17 am, Keith Owens wrote:
> arch/ia64/kernel/unwind.c:
>   Only call get_scratch_regs() when pt is really needed.  The premature
>   calls to get_scratch_regs() would pick up the wrong address for pt if
>   the register was in switch_stack and pt_regs had not been reached
>   yet, e.g. unw_access_ar(&info, UNW_AR_BSPSTORE,...) before pt_regs
>   had been reached.
> 
>   Correct debugging code that had the wrong the number of parameters
>   and referred to non-existent variables.  Only shows up with
>     CFLAGS_unwind.o += -DUNW_DEBUG=<number>.

It looks like these changes should be applicable to 2.5 as well.
I'd like to avoid gratuitous differences with 2.5, so can you
get David to apply them there first?  (I'm not implying that your
fixes are gratuitous, just that since David is "Mr. Unwind", he
may make minor changes when applying your patch, and I
might as well get those at the same time. :-)

Bjorn


