From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 21:52:03 +0000
Subject: Re: [PATCH] linux-2.6.3_ia64-cyclone_A2.patch
Message-Id: <1077141122.985.122.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077136393.985.111.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077136393.985.111.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-02-18 at 13:41, David Mosberger wrote:
> Out of curiosity: what's the latency behavior for Cyclone?  Do all
> nodes access a single (shared) counter or is the counter replicated on
> each node and driven by a common clock?  My understanding that for
> SGI's platform it's the latter.

Unfortunately there is no replicated clock on this hardware, so all
nodes access the first counter on the first node. Not great, but correct
and slow is better then fast and wrong. 

thanks
-john

