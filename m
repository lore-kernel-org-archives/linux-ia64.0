From: Greg Edwards <edwardsg@sgi.com>
Date: Sat, 20 Aug 2005 01:50:49 +0000
Subject: Re: clean up sn2 region definitions
Message-Id: <20050820015049.GC14392@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050819215218.GA21689@sgi.com>
In-Reply-To: <20050819215218.GA21689@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 19, 2005 at 03:06:26PM -0700, Jesse Barnes wrote:
| On Friday, August 19, 2005 2:52 pm, Greg Edwards wrote:
| > -#define CACHED			0xe000000000000000UL
| > -#define UNCACHED                0xc000000000000000UL
| > -#define UNCACHED_PHYS           0x8000000000000000UL
| > +#define CACHED			RGN_BASE(RGN_KERNEL)
| > +#define UNCACHED                RGN_BASE(RGN_UNCACHED)
| > +#define UNCACHED_PHYS           RGN_BASE(RGN_HPAGE)
| 
| You could also just rip out these redundant sn2 definitions and replace 
| them by the ia64 ones... :)

Yeah, but that would make too much sense.  ;)  I'll send out a new patch
shortly.

Greg
