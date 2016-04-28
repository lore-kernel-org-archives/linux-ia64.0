From: Simon Horman <horms@verge.net.au>
Date: Thu, 28 Apr 2016 23:04:06 +0000
Subject: Re: [PATCH 00/12] Fixing TI Keystone2 kexec
Message-Id: <20160428230406.GA18128@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

Hi Russell,

On Thu, Apr 28, 2016 at 10:26:44AM +0100, Russell King - ARM Linux wrote:
> These changes are required for TI Keystone2 kexec to be functional.  TI
> Keystone2 has the run-time view of physical memory above 4GiB, but with
> a boot time alias below 4GiB which can only be used during the early
> boot.
> 
> This means we need to translate run-time physical addresses (which the
> kernel uses) to boot-time physical addresses, which, having discussed
> with Eric, is what the kexec tools and kexec kernel API requires.
> 
> We publish a special set of boot time resources in /proc/iomem, which
> the (modified) kexec tools look for in preference to the normal resources.
> Hence, if these are found, the kexec tools make use of these resources,
> and thus kexec tools use the boot-time view of physical memory.
> 
> The first three patches have been sitting in linux-next for a while.
> I'm going to put the next ARM specific three into linux-next next week.
> 
> I've sent Eric over a month ago all the patches, including the kexec
> tools patches, but I've heard nothing back.  I'm at a loss how to
> make progress on these patches - and as I'm being hassled about this,
> I'm going to be hassling the community about it, possibly with regular
> re-posts until there is some progress.

My experience is that usually Andrew Morton takes kexec patches
and that this has been the situation for many years now.

With regards to any kexec-tools patches that are appropriate for upstream:
please send them to the kexec mailing list with me CCed and I will see
about including them in the next release. If you have done so already then
I apologise for having missed them.

>  Documentation/kdump/kdump.txt     | 13 ++------
>  arch/arm/boot/dts/keystone.dtsi   |  8 +++++
>  arch/arm/include/asm/kexec.h      | 24 +++++++++++++++
>  arch/arm/include/asm/memory.h     | 38 ++++++++++++++++++-----
>  arch/arm/kernel/machine_kexec.c   |  2 +-
>  arch/arm/kernel/setup.c           | 65 +++++++++++++++++++++++++++++++++++++--
>  arch/arm/mach-keystone/keystone.c |  7 +----
>  arch/arm/mm/idmap.c               |  2 +-
>  arch/ia64/kernel/machine_kexec.c  |  2 +-
>  include/linux/kexec.h             | 42 +++++++++++++++++++++++--
>  kernel/kexec.c                    |  3 +-
>  kernel/kexec_core.c               | 30 +++++++++---------
>  kernel/ksysfs.c                   |  4 +--
>  13 files changed, 193 insertions(+), 47 deletions(-)
> 
> -- 
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
> 
