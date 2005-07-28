From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 28 Jul 2005 08:09:08 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <10613.1122538148@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Thu, 28 Jul 2005 09:41:18 +0200."
             <20050728074118.GA20581@elte.hu>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 28 Jul 2005 09:41:18 +0200,
Ingo Molnar <mingo@elte.hu> wrote:
>
>* david mosberger <dmosberger@gmail.com> wrote:
>
>> Also, should this be called prefetch_stack() or perhaps even just
>> prefetch_task()?  Not every architecture defines a switch_stack
>> structure.
>
>yeah. I'd too suggest to call it prefetch_stack(), and not make it a
>macro & hook but something defined on all arches, with for now only ia64
>having any real code in the inline function.
>
>i'm wondering, is the switch_stack at the same/similar place as
>next->thread_info? If yes then we could simply do a
>prefetch(next->thread_info).

No, they can be up to 30K apart.  See include/asm-ia64/ptrace.h.
thread_info is at ~0xda0, depending on the config.  The switch_stack
can be as high as 0x7bd0 in the kernel stack, depending on why the task
is sleeping.

