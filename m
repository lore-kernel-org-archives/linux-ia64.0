From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 15 Dec 2004 23:37:10 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <Pine.SGI.4.61.0412151725040.24052@kzerza.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com>
 <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de>
 <20041215144730.GC24000@krispykreme.ozlabs.ibm.com>
In-Reply-To: <20041215144730.GC24000@krispykreme.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anton Blanchard <anton@samba.org>
Cc: Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, jrsantos@austin.ibm.com

On Thu, 16 Dec 2004, Anton Blanchard wrote:

> Id like to see a benchmark that has a large footprint in the hash. A few
> connection netperf run isnt going to stress the hash is it?

Not as well as I'd like, I'll admit.  I really couldn't find any
standard benchmark that would push the TCP hashes hard.

> Also what page size were the runs done with? On x86-64 and ppc64 the 4kB page
> size may make a difference to Brents runs.

16K pages on IA64.  As the patch currently stands x86-64 and ppc64
would not be a concern, as we still use the old behavior by default
for those architectures.  Only IA64 NUMA kernel configurations will
have this on by default.  Additionally, this only affects NUMA machines,
and I'm not aware of any x86-64 architectures of that nature (please
educate me if I'm mistaken).

> specSFS (an NFS server benchmarmk) has been very sensitive to TLB issues
> for us, it uses all the memory as pagecache and you end up with 10
> million+ dentries. Something similar that pounds on the dcache would be
> interesting.

I'll look into running that, but have my doubts as to whether I
can scare up appropriate quantities/types of hardware.

Brent

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
