From: Hugh Dickins <hugh@veritas.com>
Date: Wed, 01 Sep 2004 11:30:07 +0000
Subject: Re: Bad interaction between virtual memmap and rmap changes?
Message-Id: <Pine.LNX.4.44.0409011218210.5398-100000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040901055933.GC21873@cse.unsw.EDU.AU>
In-Reply-To: <20040901055933.GC21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 1 Sep 2004, Ian Wienand wrote:
> 
> With 2.6.9-rc1 on IA64 I have this problem when I boot on an rx2600
> (with both SMP and uniprocessor builds) :
> 
> Bad page state at free_hot_cold_page (in process 'swapper', page e0000000049bcd08)
> flags:0x00000000 mapping:0000000000000000 mapcount:1 count:0
> Backtrace:
> [-- no backtrace is printed, unfortunately, and the machine stops dead --]
> 
> But I also noticed that virtual mem map was right at around the same
> place :
> 
> Virtual mem_map starts at 0xe000000004928000
> 
> So I turned that off in the config, and it appears to work OK.  I
> noticed there were a lot of rmap changes with respect to locking just
> recently put in, and I suspect they are the culprit.

But they went in just _after_ 2.6.9-rc1, so however evil
they may be, I doubt they're guilty of this particular sin!

Previous cases of bad page state mapcount:1 (which tends to be
followed later by the BUG_ON(!page->mapcount) from page_remove_rmap,
since the bad page state gets forced to "good") have been resolved
by unrelated code freeing a page which didn't (any longer) belong
to it; but no instance of that in 2.6.9-rc1 springs to my mind.

I'm afraid I don't know much about IA64 and virtual mem_maps,
so I'd better leave you in more capable hands.

Hugh

