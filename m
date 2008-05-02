From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 02 May 2008 22:53:10 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC013F7F33@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This surely is a bug. I bet this was introduced by Hidetoshi's latest
> commit:
>
> commit 38477ad75188b2a7370fef7145f956e6c446928b
> Author: Hidetoshi Seto
> Date:   Mon Apr 21 14:34:39 2008 -0700
>
>    [IA64] disable interrupts on exit of ia64_trace_syscall

Can you try reverting this patch and re-running the
same stress tests?

-Tony
