From: Horms <horms@verge.net.au>
Date: Mon, 04 Sep 2006 08:22:03 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <20060904082201.GA7814@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 04, 2006 at 10:05:30AM +0200, Jes Sorensen wrote:
> Horms wrote:
> > Which I believe is because nodedata.h is not included, as per
> > ~line 83 of include/asm/processor.h
> > 
> > #ifdef CONFIG_NUMA
> > #include <asm/nodedata.h>
> > #endif
> > 
> > Including nodedata.h doesn't seem appropriate, as it does seem to
> > be numa-specific. I wasn't able to find an alternate definition of
> > CONFIG_NUMA
> 
> IMHO nodedata.h should provide alternative macros for non NUMA builds.
> It seems silly to protect the include with #ifdef.

That is pretty much what I was thinking.
But perhaps there is a reason for it.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/


-- 
VGER BF report: U 0.753438
