From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 10 Nov 2003 19:08:31 +0000
Subject: Re: discontig patch question
Message-Id: <marc-linux-ia64-106849134202103@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 10, 2003 at 12:34:47PM -0600, Van Maren, Kevin wrote:
> > Yeah, but 1UL<<MAX_ORDER will always be page aligned, right?
> 
> Only if MAX_ORDER >= PAGE_SHIFT.
> 
> But page alignment isn't the question: it is already aligned to
> the 16MB or 64MB granules.

Right.  Spaced out there for a minute...

> But you are saying that the address doesn't have to be as strict:
> even if allocating 2^MAX_ORDER _pages_, the start doesn't have to
> be aligned at a natural (PAGE_SIZE<<MAX_ORDER) boundary, and that
> we can change the ORDERROUNDDOWN to not be as aggressive.

Well, strictly speaking I don't think start _has_ to align on those
conditions, but the hugetlb stuff may that it does (I haven't looked).

> But then it also makes sense to have a smaller MAX_ORDER when not
> using 4GB hugepages?  I'm happy with <= 256MB hugepages with 16GB ram,
> so I guess I'd rather MAX_ORDER was normally smaller, and increased
> only with very large hugepage pages.

That makes sense to me.  It seems like FORCE_MAX_ZONEORDER should depend
on HUGETLB_PAGE_SIZE_* so that we don't apply unnecessary alignment
constraints.  Of course, there's probably something I'm missing, Rohit
might know more.

Jesse
