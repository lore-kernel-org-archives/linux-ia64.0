From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Tue, 14 Dec 2004 20:08:44 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <19030000.1103054924@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de>
In-Reply-To: <20041214191348.GA27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

--On Tuesday, December 14, 2004 20:13:48 +0100 Andi Kleen <ak@suse.de> wrote:

> On Tue, Dec 14, 2004 at 10:59:50AM -0800, Martin J. Bligh wrote:
>> > NUMA systems running current Linux kernels suffer from substantial
>> > inequities in the amount of memory allocated from each NUMA node
>> > during boot.  In particular, several large hashes are allocated
>> > using alloc_bootmem, and as such are allocated contiguously from
>> > a single node each.
>> 
>> Yup, makes a lot of sense to me to stripe these, for the caches that
> 
> I originally was a bit worried about the TLB usage, but it doesn't
> seem to be a too big issue (hopefully the benchmarks weren't too
> micro though)

Well, as long as we stripe on large page boundaries, it should be fine,
I'd think. On PPC64, it'll screw the SLB, but ... tough ;-) We can either
turn it off, or only do it on things larger than the segment size, and
just round-robin the rest, or allocate from node with most free.
 
>> didn't Manfred or someone (Andi?) do this before? Or did that never
>> get accepted? I know we talked about it a while back.
> 
> I talked about it, but never implemented it. I am not aware of any
> other implementation of this before Brent's.

Cool, must have been my imagination ;-)

M.

