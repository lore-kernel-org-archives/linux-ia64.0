From: Jack Steiner <steiner@sgi.com>
Date: Thu, 29 Jan 2004 04:00:08 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040129040008.GA4681@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 29, 2004 at 03:11:42AM +0000, Matthew Wilcox wrote:
> On Wed, Jan 28, 2004 at 07:13:42PM -0600, Jack Steiner wrote:
> > This wont work with the current usage of the CONFIG options. For 
> > example:
> > 	# if defined (CONFIG_IA64_HP_SIM)
> > 	#  include <asm/machvec_hpsim.h>
> > 	# elif defined (CONFIG_IA64_DIG)
> > 	#  include <asm/machvec_dig.h>
> > 	# elif defined (CONFIG_IA64_HP_ZX1)
> > 	#  include <asm/machvec_hpzx1.h>
> > 	# elif defined (CONFIG_IA64_SGI_SN2)
> > 	#  include <asm/machvec_sn2.h>
> > 	# elif defined (CONFIG_IA64_GENERIC)
> > 	....
> > 
> > (It sounded like a good idea though. Most but not all places that check
> > CONFIG_IA64_SGI_SN2 also check for CONFIG_IA64_GENERIC).
> 
> This one can be easily fixed by testing *first* for CONFIG_IA64_GENERIC,
> then for all the other options.  

Sure, but I was reluctant to make that kind of change. As far as I know, most
code expects only a single "system type" to be defined. It seems like it
could prove to be error prone if these definition were order dependent.

If the ordering was incorrect, code could compile ok but might not run on
all platforms if the SN2 version of code was used instead of the generic version.


> Any other places that won't work?

Most of the code looks ok.
AFAIK, we havent tested generic 2.6 kernels on SN2 (Jesse - is this true)  so there may 
be other places that will have problems. But in general, I agree that proper
ordering should usually work.
	
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


