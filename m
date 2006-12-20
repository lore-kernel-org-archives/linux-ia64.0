From: Kirill Korotaev <dev@openvz.org>
Date: Wed, 20 Dec 2006 10:57:51 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <4589172F.3010007@openvz.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes,

> Well you suggested a patch which just hides the problem. I suggest you
> change it to have the BUG_ON().
IMHO you are wrong.
the suggested patch *fixes* one particular place, which can be triggered on
mainstream IA64 by a standard user and is actually a *SECURITY* bug which
can be potentially exploited (when OOM killer is enabled).
It doesn't hide anything, It just doesn't help to catch other places.

>>>Which callers did you see cause this? If it was a common problem I would
>>>expect a lot of data corruption or crashes on ia64 systems which I
>>>haven't heard of.
>>
>>from the patch:
>>pte_alloc_one() calls pgtable_quicklist_alloc() which can return NULL in
>>case of allocation failure.
>>
>>It was hit on OpenVZ where kernel memory is accounted and limited on
>>per-container basis (it is possible to DoS using page tables allocations).
>>In mainstream the bug can be hit if OOM killer
>>kills the process and __get_free_page() returns NULL which is rare, but still possible.
> 
> 
> I see, since you have it tracked down, it would be good to fix it
> and push a patch upstream. Unless of course Andrew or Linus thinks this
> is the wrong approach.
Maybe the fact that I came without an exploit to crash IA64
makes you think it should not be commited, ok, you can leave it as is then.
NOTE: I don't mind against the debug you proposed. It is quite a good idea.

Thanks,
Kirill

