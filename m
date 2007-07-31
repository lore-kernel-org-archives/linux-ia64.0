From: Thomas Renninger <trenn@suse.de>
Date: Tue, 31 Jul 2007 16:40:42 +0000
Subject: RE: regression on HP zx1 platform from ACPI autoload modulespatches
Message-Id: <1185900042.18821.213.camel@queen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A020E3AD2@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A020E3AD2@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Doug Chapman <doug.chapman@hp.com>, Tony Luck <tony.luck@gmail.com>, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 2007-07-31 at 09:29 -0700, Luck, Tony wrote:
> > commit 8c8eb78f673c07b60f31751e1e47ac367c60c6b7
> 
> Oops.  I cut & pasted the wrong commit id.  The fix went in as
> commit 7091138fb762aed22317b4ff91eb211e7da3865c.
> 
> > FYI, I did a git pull yesterday just before I hit this issue so I should
> > have had the latest stuff.
> 
> So this confuses me.  Linus pulled this into his tree on Friday (IIRC), but
> at the very latest on Saturday (as there is a commit *after* this one that
> is dated 2007-07-28 19:29:37).
> 
> The patch that is in the tree appears to be identical to the one that
> Thomas Renninger posted to this thread, and you confirmed as working.
> 
> So when you have a moment, please pull latest Linus tree.  Confirm that
> this patch is present:
>  $ grep hp_ioc_iommu_device_ids arch/ia64/hp/common/sba_iommu.c
>  static const struct acpi_device_id hp_ioc_iommu_device_ids[] = {
>  	.ids		= hp_ioc_iommu_device_ids,
>  $
> 
> and that it builds and boots for you.

Tony, it looks like the patch has not hit Linus tree yet:

> git-branch
* master
  origin

> git-pull
Already up-to-date.

> patch --dry-run -p1 -i ../../tmp/acpi_autoloading_ia64_fix.patch 
patching file arch/ia64/hp/common/sba_iommu.c

    Thomas

