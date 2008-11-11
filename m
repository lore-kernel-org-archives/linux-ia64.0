From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 11 Nov 2008 05:14:18 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081111112615.D5C5.E1E9C6FF@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com> <87d4h3pwhe.fsf@basil.nowhere.org>
In-Reply-To: <87d4h3pwhe.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

> Yasunori Goto <y-goto@jp.fujitsu.com> writes:
> >
> > However, I think this has the possibility of a finishing blow of OOM.
> > For example,
> >
> >   1) Page caches occupy normal zone, and DMA zone is free.
> >   2) A user's application requires a few GB memory and mlock it.
> >      All DMA zone is occupied by it.
> 
> The VM has special "lower zone protection" to protect against these
> kinds of deadlocks. They can be circumvented, but it takes effort.

I wrote documentation about lowmem_reserve_ratio, which is the current name of
lower_zone_protection, in Documantation/filesystem/proc.txt.
But, I really doubt there are many users who can understand how to estimate
there value.


> 
> >   3) A device which allows over 4GB is hot-added.
> >      But dma_alloc_coherent() try to allocate DMA zone.
> >      Then OOM occurs because there is no freeable pages.
> >
> > I heard there are some users who require a few GB mlock.
> 
> Normally mlock is limited to half the memory exactly to avoid
> such problems.

Half? I don't know which documentation desribes it. :-P
Probably, the most of users don't know it...

To be honest, I can understand kernel hacker hope there is NO user who 
uses mlock for some GB memory. However, the reality is relentless.
There were some real user who tried it. I remember the user who had 8GB memory
box and mlocked 5GB.
But, even if they mlocked only 4GB, OOM must occur.

(In addition, Fujitsu PrimeQuest reserves about 2GB area for maximum
 I/O equipment. Then, Zone DMA is only 2GB..... (Ueeeeeeeep!))


Anyway, I don't want to discuss about mlock's specification.
Because users can understand the side effect of mlock if OOM occurs.
But they can't understand why Zone DMA is used even if driver doesn't
require Zone DMA. It looks simply BUG from user's view point
when it was finishing blow of OOM. I have to explain why its BUG(?)
still remains. But I'm newbie around this area. So, I would like to know.


Thanks.

-- 
Yasunori Goto 


