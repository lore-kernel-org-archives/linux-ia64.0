From: Paul Jackson <pj@sgi.com>
Date: Sat, 04 Feb 2006 04:14:41 +0000
Subject: Altix SN2 2.6.16-rc1-mm5 build breakage (was:  msi support)
Message-Id: <20060203201441.194be500.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060119194647.12213.44658.14543@lnx-maule.americas.sgi.com>
	<20060119194702.12213.16524.93275@lnx-maule.americas.sgi.com>
In-Reply-To: <20060119194702.12213.16524.93275@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, gregkh@suse.de, maule@sgi.com

Andrew,

The following patch seems to be breaking my ia64 sn2_defconfig
build of 2.6.16-rc1-mm5:

    gregkh-pci-altix-msi-support-git-ia64-fix.patch

I'm guessing you should remove it for now.


Details:
====

When I try to build an ia64 sn2_defconfig 2.6.16-rc1-mm5, the
build fails:

    arch/ia64/sn/pci/tioce_provider.c:699:49: macro "ATE_MAKE" passed 3 arguments, but takes just 2
    arch/ia64/sn/pci/tioce_provider.c: In function `tioce_reserve_m32':
    arch/ia64/sn/pci/tioce_provider.c:699: error: `ATE_MAKE' undeclared (first use in this function)

If I remove the patch:

    gregkh-pci-altix-msi-support-git-ia64-fix.patch

then it compiles fine.

It seems that someone added a patchset to change the ATE_MAKE()
macro from 2 to 3 args, then someone added this above fix patch
for a missed change, then someone reverted it all back to 2 args,
but leaving this fix patch.

I guess it means Andrew should remove the above patch.

But I really do not know what is going on here.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
