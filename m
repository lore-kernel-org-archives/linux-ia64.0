From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Jul 2005 08:16:22 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050728081622.GA22025@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050728074118.GA20581@elte.hu> <10613.1122538148@kao2.melbourne.sgi.com>
In-Reply-To: <10613.1122538148@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@ocs.com.au>
Cc: David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Keith Owens <kaos@ocs.com.au> wrote:

> >yeah. I'd too suggest to call it prefetch_stack(), and not make it a
> >macro & hook but something defined on all arches, with for now only ia64
> >having any real code in the inline function.
> >
> >i'm wondering, is the switch_stack at the same/similar place as
> >next->thread_info? If yes then we could simply do a
> >prefetch(next->thread_info).
> 
> No, they can be up to 30K apart.  See include/asm-ia64/ptrace.h. 
> thread_info is at ~0xda0, depending on the config.  The switch_stack 
> can be as high as 0x7bd0 in the kernel stack, depending on why the 
> task is sleeping.

is the switch_stack the same thing as the kernel stack? If yes then we 
want to have something like:

	prefetch(kernel_stack(next));

to make it more generic. By default kernel_stack(next) could be
next->thread_info (to make sure we prefetch something real). On e.g.
x86/x64, kernel_stack(next) should be something like next->thread.esp.

	Ingo
