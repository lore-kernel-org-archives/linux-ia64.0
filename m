From: Greg KH <gregkh@suse.de>
Date: Thu, 19 Jan 2006 03:27:40 +0000
Subject: Re: 2.6.16-rc1-mm1: ia64 compile error
Message-Id: <20060119032740.GA16190@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118005053.118f1abc.akpm@osdl.org> <20060119031155.GH19398@stusta.de>
In-Reply-To: <20060119031155.GH19398@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: Andrew Morton <akpm@osdl.org>, Mark Maule <maule@sgi.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thu, Jan 19, 2006 at 04:11:55AM +0100, Adrian Bunk wrote:
> On Wed, Jan 18, 2006 at 12:50:53AM -0800, Andrew Morton wrote:
> >...
> > Changes since 2.6.15-mm4:
> >...
> > +gregkh-pci-pci-msi-vector-targeting-abstractions.patch
> >...
> >  PCI tree updates
> >...
> 
> This patch breaks the ia64 defconfig:
> 
> <--  snip  -->
> 
> ...
>   CC      arch/ia64/dig/machvec.o
> In file included from arch/ia64/dig/machvec.c:3:
> include/asm/machvec_init.h:32: error: 'ia64_msi_init' undeclared here (not in a function)
> make[1]: *** [arch/ia64/dig/machvec.o] Error 1

Yeah, I had to drop the 3rd patch in that series that wsa ia64 specific
due to major conflicts.  Mark said he would give me updated patches
soon.

thanks,

greg k-h
