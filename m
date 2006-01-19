From: Mark Maule <maule@sgi.com>
Date: Thu, 19 Jan 2006 03:31:31 +0000
Subject: Re: 2.6.16-rc1-mm1: ia64 compile error
Message-Id: <20060119033131.GR3331@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118005053.118f1abc.akpm@osdl.org> <20060119031155.GH19398@stusta.de>
In-Reply-To: <20060119031155.GH19398@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: Andrew Morton <akpm@osdl.org>, Greg Kroah-Hartman <gregkh@suse.de>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

yes, I discovered this last night for generic builds.  I'm fixing up the MSI
patches and will send them out in the morning.

sn2_defconfig and zx1_defconfig builds work, more generic ones do not.

Sorry 'bout that.

Mark

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
> 
> <--  snip  -->
> 
> cu
> Adrian
