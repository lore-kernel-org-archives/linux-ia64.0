From: Greg Banks <gnb@melbourne.sgi.com>
Date: Fri, 22 Oct 2004 04:26:05 +0000
Subject: Re: [PATCH] I/O space write barrier
Message-Id: <1098419164.21421.58.camel@hole.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410211613.19601.jbarnes@engr.sgi.com>
	 <20041022010150.GH3878@cup.hp.com>  <200410212205.51672.jbarnes@sgi.com>
In-Reply-To: <200410212205.51672.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@sgi.com>
Cc: Grant Grundler <iod00d@hp.com>, Jesse Barnes <jbarnes@engr.sgi.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Fri, 2004-10-22 at 13:05, Jesse Barnes wrote:
>  I think Greg had some ideas about other 
> things to cover as well.  Greg?

You've done most of the stuff I wanted, but it would be nice to see:

*  a mention of the read-to-flush-writes technique and why mmiowb
   is better

*  an example of how and where to use read_relaxed and a description
   of why its better than read

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


