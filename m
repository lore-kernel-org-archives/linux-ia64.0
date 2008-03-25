From: Paul Mackerras <paulus@samba.org>
Date: Tue, 25 Mar 2008 21:27:08 +0000
Subject: Re: larger default page sizes...
Message-Id: <18409.28204.539283.566893@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<87wsnrgg9q.fsf@basil.nowhere.org>
In-Reply-To: <87wsnrgg9q.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

Andi Kleen writes:

> Paul Mackerras <paulus@samba.org> writes:
> > 
> > 4kB pages:	444.051s user + 34.406s system time
> > 64kB pages:	419.963s user + 16.869s system time
> > 
> > That's nearly 10% faster with 64kB pages -- on a kernel compile.
> 
> Do you have some idea where the improvement mainly comes from?
> Is it TLB misses or reduced in kernel overhead? Ok I assume both
> play together but which part of the equation is more important?

I think that to a first approximation, the improvement in user time
(24 seconds) is due to the increased TLB reach and reduced TLB misses,
and the improvement in system time (18 seconds) is due to the reduced
number of page faults and reductions in other kernel overheads.

As Dave Hansen points out, I can separate the two effects by having
the kernel use 64k pages at the VM level but 4k pages in the hardware
page table, which is easy since we have support for 64k base page size
on machines that don't have hardware 64k page support.  I'll do that
today.

Paul.
