From: Jes Sorensen <jes@sgi.com>
Date: Mon, 04 Sep 2006 08:05:30 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <44FBDE4A.80405@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote:
> Which I believe is because nodedata.h is not included, as per
> ~line 83 of include/asm/processor.h
> 
> #ifdef CONFIG_NUMA
> #include <asm/nodedata.h>
> #endif
> 
> Including nodedata.h doesn't seem appropriate, as it does seem to
> be numa-specific. I wasn't able to find an alternate definition of
> CONFIG_NUMA

IMHO nodedata.h should provide alternative macros for non NUMA builds.
It seems silly to protect the include with #ifdef.

Cheers,
Jes


-- 
VGER BF report: U 0.5
