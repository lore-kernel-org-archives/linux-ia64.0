From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 11 Jan 2005 21:58:56 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <200501112158.j0BLwvAN087091@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ben Woodard wrote:
> 
> So does anyone with "normal world" experience have any suggestions on
> how I should take into account the various perspectives? 
> 
> Do other people consider the isolated SBE a problem? 
> 
> Do other people consider 1SBE/hr on a DIMM a real problem that needs to
> be fixed?

Why would anyone consider a recovered error a problem?  ECC corrected
the data so life is good.

The real question is whether the corrected error is an indication that
something bad - a crash due to and uncorrected error - is going to happen.
That is the bad thing we want to avoid.

The answer to the question of whether single bits turn into double bits
is - it depends.  There are a number of underlying causes for SBEs and
different ways in which the SBE could degrade into a MBE.  The DRAM
technology plays a big part.  From experience, some DIMMs have SBEs that
never turn into MBEs.  Other DIMMs get MBEs without preceeding SBEs.

You really have to analyze the specific DIMMs, look at the failure 
characteristics of the technology, to get any specific data to base 
a logical conclusion.  And even then slight changes in the manufacturing 
process can skew those numbers.

What linux really needs is better SBE logging infrastructure, to 
keep track of specific DIMMs and the SBEs within the DIMMs, to
collect real data on which to draw meaningful conclusion.

The one solid answer I can give you is that the overall failure 
rate that causes system crashes remains constant over time.
That's because if a specific memory technology makes the memory
subsystem more reliable, people will just buy more memory until
they reach the same noticeable error rate.  ECC memory did not
eliminate memory errors, it allowed much larger memories with
the same overall memory failure rate.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
