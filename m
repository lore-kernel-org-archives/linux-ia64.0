From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 14 Dec 2004 19:30:20 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <Pine.SGI.4.61.0412141319100.22462@kzerza.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
 <9250000.1103050790@flay>
In-Reply-To: <9250000.1103050790@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de

On Tue, 14 Dec 2004, Martin J. Bligh wrote:

> Yup, makes a lot of sense to me to stripe these, for the caches that
> are global (ie inodes, dentries, etc).  Only question I'd have is 
> didn't Manfred or someone (Andi?) do this before? Or did that never
> get accepted? I know we talked about it a while back.

Are you thinking of the 2006-06-05 patch from Andi about using
the NUMA policy API for boot time allocation?

If so, that patch was accepted, but affects neither allocations
performed via alloc_bootmem nor __get_free_pages, which are
currently used to allocate these hashes.  vmalloc, however, does
behave as desired with Andi's patch.

Which is why vmalloc was chosen to solve this problem.  There were
other more complicated possible solutions (e.g. multi-level hash tables,
with the bottommost/largest level being allocated across all nodes),
however those would have been so intrusive as to be unpalatable.
So the vmalloc solution seemed reasonable, as long as it is used
only on architectures with plentiful vmalloc space.

Thanks,
Brent

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
