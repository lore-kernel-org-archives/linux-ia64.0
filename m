From: Matthew Wilcox <willy@debian.org>
Date: Thu, 29 Jan 2004 03:11:42 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040129031142.GB18725@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 28, 2004 at 07:13:42PM -0600, Jack Steiner wrote:
> This wont work with the current usage of the CONFIG options. For 
> example:
> 	# if defined (CONFIG_IA64_HP_SIM)
> 	#  include <asm/machvec_hpsim.h>
> 	# elif defined (CONFIG_IA64_DIG)
> 	#  include <asm/machvec_dig.h>
> 	# elif defined (CONFIG_IA64_HP_ZX1)
> 	#  include <asm/machvec_hpzx1.h>
> 	# elif defined (CONFIG_IA64_SGI_SN2)
> 	#  include <asm/machvec_sn2.h>
> 	# elif defined (CONFIG_IA64_GENERIC)
> 	....
> 
> (It sounded like a good idea though. Most but not all places that check
> CONFIG_IA64_SGI_SN2 also check for CONFIG_IA64_GENERIC).

This one can be easily fixed by testing *first* for CONFIG_IA64_GENERIC,
then for all the other options.  Any other places that won't work?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
