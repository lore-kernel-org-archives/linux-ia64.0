From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Tue, 14 Dec 2004 20:10:57 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <19950000.1103055057@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com><9250000.1103050790@flay> <Pine.SGI.4.61.0412141319100.22462@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.61.0412141319100.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de

>> Yup, makes a lot of sense to me to stripe these, for the caches that
>> are global (ie inodes, dentries, etc).  Only question I'd have is 
>> didn't Manfred or someone (Andi?) do this before? Or did that never
>> get accepted? I know we talked about it a while back.
> 
> Are you thinking of the 2006-06-05 patch from Andi about using
> the NUMA policy API for boot time allocation?
> 
> If so, that patch was accepted, but affects neither allocations
> performed via alloc_bootmem nor __get_free_pages, which are
> currently used to allocate these hashes.  vmalloc, however, does
> behave as desired with Andi's patch.

Nope, was for the hashes, but I think maybe it was all vapourware.
 
> Which is why vmalloc was chosen to solve this problem.  There were
> other more complicated possible solutions (e.g. multi-level hash tables,
> with the bottommost/largest level being allocated across all nodes),
> however those would have been so intrusive as to be unpalatable.
> So the vmalloc solution seemed reasonable, as long as it is used
> only on architectures with plentiful vmalloc space.

Yup, seems like a reasonable approach.

M.

