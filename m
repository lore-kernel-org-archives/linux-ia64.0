From: Keith Owens <kaos@sgi.com>
Date: Fri, 28 Jan 2005 03:04:35 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <13236.1106881475@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Jan 2005 18:08:18 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Thu, 20 Jan 2005 21:26:18 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> Unwinding across firmware is not an issue here, we have two
>  Keith> views of the MCA/INIT context.  One view is "how to return to
>  Keith> SAL?", that data is stored outside the stack.  The other view
>  Keith> is "what was the cpu doing when the event occurred?".  It is
>  Keith> the latter that I am working on.
>
>How is this different from the "unw_init_from_interruption" call that
>we're doing in mca.c:init_handler_platform()?

That only works for the INIT call which uses the current bspstore, MCA
uses its own bspstore.  The kernel unwinder is not set up to switch
bspstore between two kernel stacks, only between kernel and user space.
The INIT call will change to its own bspstore once we use the separate
INIT and MCA stacks for each cpu.

