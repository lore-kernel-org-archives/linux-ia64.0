From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 26 Oct 2006 00:21:34 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <453FFF8E.7040600@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> I reworked that routine to look at all the valid cache target identifiers
> and use the one with the lowest cache level.  
> 
> I've opened a Quad issue to get clarification from Intel as to 
> which target identifier triggered the MCA if there are multiple
> cache checks with valid target identifiers.  
> 
> This patch also leaves mca.c unchanged.  I'll treat that as a seperate
> patch if needed.

Looks good.

But I have one more question (for intel possibly):
- If identifiers in cache_check and bus_check are different,
   the cache's always takes priority and the bus's will be ignored.
   Are there any opposite case, such as a case of error log that have
   corrected cache_checks with ignorable identifiers and an uncorrected
   bus_check with significant identifier?

I guess if both are significant it would be separated double MCA,
or should be reset by SAL/platform.


Thanks,
H.Seto

