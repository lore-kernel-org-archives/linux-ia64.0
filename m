From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 26 Feb 2004 23:40:33 +0000
Subject: Re: [Lse-tech] Re: fix zonelist ordering for NUMA
Message-Id: <1077838833.2131.362.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <100070000.1077834062@flay>
In-Reply-To: <100070000.1077834062@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-02-26 at 14:21, Martin J. Bligh wrote:
> Also, I seem to recall those build_zonelists functions are used for both
> NUMA and UMA ... now they're getting complex enough that it's probably
> worth making a specific non-NUMA version, if only for the sanity of
> 99% of the poor souls trying to work out how a UMA machine lays it out ;-)
> 
> It looks like it won't change ordering for existing boxes with single
> layer flat NUMA topologies (round-robin), but we probably ought to check
> that carefully ;-)

More ifdefs just make the code messier.  How about adding a nice comment
explaining that UMA will fall right through the loop, and giving the
poor souls a temporary reprieve?

-- dave

