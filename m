From: Russ Anderson <rja@sgi.com>
Date: Wed, 14 Jan 2004 23:32:01 +0000
Subject: Re: Yet another MCA handler
Message-Id: <200401142332.i0ENW26d024056@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40051D1B.7912DB91@nospam.org>
In-Reply-To: <40051D1B.7912DB91@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote:
> 
> I was to write the code for the recovery for poisoned memory, too,
> but I've got no way to provoke this kind of error
> ( I do not really know what it like is :-) )

If you get that far, take the Intel Itanium 2 Processor 
Specification Update (December 2003) errata 78 into account

78. L2 cache line with poison data results in unexpected fatal MCA

http://www.intel.com/design/itanium2/specupdt/251141.htm

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
