From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 21:41:12 +0000
Subject: Re: [PATCH] linux-2.6.3_ia64-cyclone_A2.patch
Message-Id: <16435.56312.237724.615003@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077136393.985.111.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077136393.985.111.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Out of curiosity: what's the latency behavior for Cyclone?  Do all
nodes access a single (shared) counter or is the counter replicated on
each node and driven by a common clock?  My understanding that for
SGI's platform it's the latter.

	--david
