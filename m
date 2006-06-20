From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 20 Jun 2006 06:22:52 +0000
Subject: Re: [PATCH 1/2] ia64,kexec: refactor some mmu-related marcors to allow them to be reused by kexec
Message-Id: <20060620062252.GB18805@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060619082353.GA15635@verge.net.au>
In-Reply-To: <20060619082353.GA15635@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 20, 2006 at 02:47:57PM +0900, Horms wrote:
> Sure, could you give me a quick heads-up on what I should do to make
> that happen.

Well, personally, I'd like to see the whole thing pulled out in
something like

http://www.gelato.unsw.edu.au/archives/linux-ia64/0511/15890.html

(ignore the bug I missed in ivt.S)

I guess it should be sufficient to just do something like

#ifdef CONFIG_PGTABLE_3
#define MAPPED_SPACE_BITS   (3*(PAGE_SHIFT - PTE_BITS) + PAGE_SHIFT)
#elif CONFIG_PGTABLE_4
#define MAPPED_SPACE_BITS   (4*(PAGE_SHIFT - PTE_BITS) + PAGE_SHIFT)
#endif

(but then VMALLOC_END is still "wrong", you still can't easily change
the PTE size...)

This is really tangential to your change however, so probably doesn't
belong in the same changeset.  Maybe I could revive that old patch if
anyone has any comments.

-i
