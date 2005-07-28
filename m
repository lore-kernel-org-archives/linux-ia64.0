From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Jul 2005 07:41:18 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050728074118.GA20581@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com> <20050727161316.0593d762.akpm@osdl.org> <ed5aea4305072716233491f7f8@mail.gmail.com>
In-Reply-To: <ed5aea4305072716233491f7f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David.Mosberger@acm.org
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* david mosberger <dmosberger@gmail.com> wrote:

> Also, should this be called prefetch_stack() or perhaps even just 
> prefetch_task()?  Not every architecture defines a switch_stack 
> structure.

yeah. I'd too suggest to call it prefetch_stack(), and not make it a 
macro & hook but something defined on all arches, with for now only ia64 
having any real code in the inline function.

i'm wondering, is the switch_stack at the same/similar place as 
next->thread_info? If yes then we could simply do a 
prefetch(next->thread_info).

	Ingo
