From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 11 Jan 2005 21:22:17 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <200501112122.j0BLMHZQ086482@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> Yes.  While individual single-bit errors aren't terribly interesting,
> periodic summaries almost certainly would be.  If only so you know
> when to order replacement DIMMs... ;-)

The only reason customers care about single bits (a recovered error)
is out of fear that they will soon lead to a multi-bit error (that
is not recoverable) that crashes the system.  If the system recovers 
from multi-bits without crashing, either by killing the app
that hit the multi-bit or (better) by backing up to the last 
checkpoint (losing processing time, but not data), then the 
customer won't even care about single bits.

Then the answer is you order the replacement DIMMs after they fail.  :-)

Or maybe not even then.  Hard drives have flaw tables that indicate
the parts of the disks to avoid.  If memory DIMMs had flaw tables,
and the equivilent of badblocks, why would you replace a DIMM?

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
