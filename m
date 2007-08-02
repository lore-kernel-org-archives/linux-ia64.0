From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 02 Aug 2007 22:07:15 +0000
Subject: Re: ia64 mmu_gather question
Message-Id: <ed5aea430708021507r3cecc068nc40067c17c207f51@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do keep in mind that there is a hardware walker, too! ;-)

  --david

On 8/2/07, Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> On Thu, 2007-08-02 at 14:56 -0700, Luck, Tony wrote:
> > > So I suspect at this stage that the race isn't affecting you. However,
> > > it looks to me that you put the burden on the fairly hot TLB miss path
> > > rather than on the much less hot invalidation path itself...
> >
> > Suggestions on how to do move the burden gratefully received.  I don't
> > think that it is all that bad though.  The re-read of the PGD>PUD>PMD>PTE
> > should all hit in the L1-D cache, which has single cycle latency.
>
> Allright. I'll look into it. Other archs have a similar issues and don't
> currently fix it. The easy fix for archs that have IPIs for TLB flushes
> is to batch the freeing of page tables pages. That's made a bit harder
> by the quicklist but I may just end up adding support for those to the
> mmu_gather.
>
> Ben.
>
>
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
