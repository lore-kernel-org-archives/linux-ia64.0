From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 12 Mar 2003 18:24:50 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 12, 2003 at 10:07:30AM -0800, David Mosberger wrote:
> Anything that's hurt significantly by TLB pressure will gain
> signifcantly.  Even apps that stream through memory (e.g., STREAMS)
> can see significant gains.  Other advantages are more reproducible
> results (since you're effectively getting some page coloring for
> "free") and much larger user virtual address space.

Yeah, that's what I figured, it's just that the gains haven't been
very notable with some of the apps we've tried.  Anyway, it seems like
apps that should see large gains from avoiding TLB misses should be
using hugetlb anyway (of course, that's not always an option).

> However, the part that really surprised me is how little ordinary apps
> seem to suffer from the higher page-fault latency and increased
> internal fragmentation.  I don't recall the exact numbers, but even a
> kernel compile ran almost as fast with 64KB page size as with 16KB
> page size.
> 
> If you know of a real-world application that suffers significantly
> from 64KB page size, I'd like to hear about it.

Haven't done any measurements to see which apps might suffer.

Thanks,
Jesse

