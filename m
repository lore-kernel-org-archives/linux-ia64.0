From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Oct 2003 22:16:59 +0000
Subject: RE: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106703405120029@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Tony> This patch was accepted into 2.5.55, attributed to "davej@uk".
>   Tony> This code will prefetch from beyond the end of the page table
>   Tony> being cleared ... which is clearly a bad thing if the page
>   Tony> table in question is allocated from the last page of memory
>   Tony> (or precedes a hole on a discontig mem system).
> 
> Different arches behave differently, though.  In the case of ia64,
> it'a always safe to prefetch (even with lfetch.fault).

Not quite always ... this was how I found the efi trim.bottom bug, since
Linux had allocated a pgd at 0xa00000-16k, and the lfetch that reached
out beyond the end of the page to the uncacheable address 0xa00000 took
an MCA.

A pgd in the last page of a granule that is followed by an uncacheable
address would do the same with lfetch.fault, wouldn't it?

-Tony
