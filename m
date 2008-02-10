From: Robin Holt <holt@sgi.com>
Date: Sun, 10 Feb 2008 14:06:06 +0000
Subject: Re: [PATH] Reduce per_cpu allocations to minimum needed for bootV3.
Message-Id: <20080210140606.GN3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080208225015.GK3875@sgi.com>
In-Reply-To: <20080208225015.GK3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

My laziness keeps making me want to just set it to 32 and call it good.

At the same time, I have a nagging feeling we should really rework this
considerably.  I don't see a compelling reason to pre-allocate anything
except the boot cpus per_cpu area.  The others, I would guess, could be
alloc_bootmem_node allocations on the cpu's node at per_cpu_init time.
We could maintain an array of pre-nulled per_cpu_data pointers, seed
with the reservation on node 0, and then alloc_bootmem_node and init
whenever per_cpu_init finds a NULL.

I have not looked at this too closely.  I would guess it is far too
invasive for this point in the release cycle anyway.  I don't think I
could have this done and tested within a week.

Would you mind putting in the patch as it was with 32?  If so, would you
want that as a #define?  We could come back to the alloc_bootmem_node
idea when we have more time to think it over.  Either way, I would not
think it is significantly worse than the extreme space wasting we see
as NR_CPUS increases.

Thanks,
Robin
