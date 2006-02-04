From: Andrew Morton <akpm@osdl.org>
Date: Sat, 04 Feb 2006 04:25:31 +0000
Subject: Re: Altix SN2 2.6.16-rc1-mm5 build breakage (was:  msi support)
Message-Id: <20060203202531.27d685fa.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060119194647.12213.44658.14543@lnx-maule.americas.sgi.com>
	<20060119194702.12213.16524.93275@lnx-maule.americas.sgi.com>
	<20060203201441.194be500.pj@sgi.com>
In-Reply-To: <20060203201441.194be500.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: maule@sgi.com, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, gregkh@suse.de

Paul Jackson <pj@sgi.com> wrote:
>
> The following patch seems to be breaking my ia64 sn2_defconfig
>  build of 2.6.16-rc1-mm5:
> 
>      gregkh-pci-altix-msi-support-git-ia64-fix.patch
> 
>  I'm guessing you should remove it for now.
> 
> 
>  Details:
>  ====
> 
>  When I try to build an ia64 sn2_defconfig 2.6.16-rc1-mm5, the
>  build fails:
> 
>      arch/ia64/sn/pci/tioce_provider.c:699:49: macro "ATE_MAKE" passed 3 arguments, but takes just 2
>      arch/ia64/sn/pci/tioce_provider.c: In function `tioce_reserve_m32':
>      arch/ia64/sn/pci/tioce_provider.c:699: error: `ATE_MAKE' undeclared (first use in this function)
> 
>  If I remove the patch:
> 
>      gregkh-pci-altix-msi-support-git-ia64-fix.patch
> 
>  then it compiles fine.

OK.  I autodrop several of Greg's MSI patches because a) they had bugs
which broke stuff a while ago and b) they don't apply and I'm lazy.  So it
looks like you've found a fix for a patch which isn't actually in -mm any
more.  I sent that fix to Greg the other day.

>  It seems that someone added a patchset to change the ATE_MAKE()
>  macro from 2 to 3 args, then someone added this above fix patch
>  for a missed change, then someone reverted it all back to 2 args,
>  but leaving this fix patch.
> 
>  I guess it means Andrew should remove the above patch.

I'll do that, thanks.

