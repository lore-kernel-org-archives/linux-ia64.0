From: Chase Venters <chase.venters@clientec.com>
Date: Fri, 16 Jun 2006 21:19:20 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <Pine.LNX.4.64.0606161615450.23743@turbotaz.ourhouse>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161656.40930.ak@suse.de>
 <20060616102516.A91827@pkunk.americas.sgi.com> <200606161740.18611.ak@suse.de>
In-Reply-To: <200606161740.18611.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Brent Casavant <bcasavan@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

(Sorry for the empty reply! Pine over a laggy SSH connection is annoying 
sometimes)

On Fri, 16 Jun 2006, Andi Kleen wrote:

>
>> To this last point, it might be more reasonable to map in a page that
>> contained a new structure with a stable ABI, which mirrored some of
>> the task_struct information, and likely other useful information as
>> needs are identified in the future.  In any case, it would be hard
>> to beat a single memory read for performance.
>
> That would mean making the context switch and possibly other
> things slower.

Well, if every process had a page of its own, what would the context 
switch overhead be?

But, I'm not advocating exporting anything. Though I sort of like the 
vgetcpu() idea because I was working on a user-space slab allocator 
recently and magazines could use vgetcpu() instead of pthread keys.
(Also means if threads > cpus I'd get better results).

Thanks,
Chase
