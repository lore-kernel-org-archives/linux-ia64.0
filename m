From: Andrew Morton <akpm@osdl.org>
Date: Sun, 14 Mar 2004 09:02:39 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory
Message-Id: <20040314010239.1d105f1c.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>
	<20040313034840.GF4638@wotan.suse.de>
	<20040313184547.6e127b51.akpm@osdl.org>
	<40541A09.3050600@sgi.com>
	<20040314005737.7f57b8ad.akpm@osdl.org>
In-Reply-To: <20040314005737.7f57b8ad.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: raybry@sgi.com, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Well that's just a dumb implementation.  hugetlb_prefault() doesn't need
>  page_table_lock while it is zeroing the page: just drop it, test for
>  -EEXIST returned from add_to_page_cache().
> 
>  In fact we need to do that anyway: the current code is buggy if some other
>  process with a different mm gets in there and instantiates the page in the
>  pagecache before this process does: hugetlb_prefault() will return -EEXIST
>  instead of simply accepting the race and using the page which someone else
>  put there.
> 
>  After we have the page in pagecache we need to retake page_table_lock and
>  check that the target pte is still pte_none().  If it is not, you know that
>  some other thread has already instantiated a pte there so the new ref to
>  the pagecache page can simply be dropped.  See how do_no_page() handles it.
>  Of course, this only applies if mmap_sem is no longer held in there.

But before implementing any of this we should move hugetlb_prefault() and
any other generic-looking functions into mm/hugetlbpage.c.  We're getting
too much duplication in there.

