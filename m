From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Date: Mon, 30 Jul 2007 23:07:03 +0000
Subject: Re: regression on HP zx1 platform from ACPI autoload modules patches
Message-Id: <6bffcb0e0707301607x5484f114q9117007d131f7118@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185836238.31298.36.camel@deimos.americas.hpqcorp.net>
In-Reply-To: <1185836238.31298.36.camel@deimos.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Chapman <doug.chapman@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, trenn@suse.de

Hi Doug,

On 31/07/07, Doug Chapman <doug.chapman@hp.com> wrote:
> I am seeing a regression on the HP ia64 zx1 platforms when using
> a .config with CONFIG_IA64_HP_ZX1=y.  Oddly it works OK with
> CONFIG_IA64_GENERIC=y.
>
>
> During bootup it panics with:
>
> Kernel panic - not syncing: Unable to find SBA IOMMU: Try a generic or DIG kernel
>
> I can provide the full console output if that is helpful.

Yes, it is very useful.

>  Also, please let
> me know if there is any other data I can provide that would be helpful.

Kernel .config file.

>
> Using git bisect I have narrowed it down to these 2 commits.  These commits
> cannot be built separately as they appear to have code that depends on each
> other.
>
>
> commit 29b71a1ca74491fab9fed09e9d835d840d042690
> Author: Thomas Renninger <trenn@suse.de>
> Date:   Mon Jul 23 14:43:51 2007 +0200
>
>     ACPI: autoload modules - Create ACPI alias interface
>
>     Modify modpost (file2alias.c) to add acpi*:XYZ0001: alias in modules.alias
>     like:
>     grep acpi /lib/modules/2.6.22-rc4-default/modules.alias
>     alias acpi*:SNY5001:* sony_laptop
>     alias acpi*:SNY6001:* sony_laptop
>     for e.g. the sony_laptop module.
>     This module matches against all ACPI devices with a HID or CID of SNY5001
>     or SNY6001
>
>     Export an uevent and modalias sysfs file containing the string:
>     [MODALIAS=]acpi:PNP0C0C:
>     additional CIDs are concatenated at the end.
>
>     Signed-off-by: Thomas Renninger <trenn@suse.de>
>     Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
>     Signed-off-by: Len Brown <len.brown@intel.com>
>
>
> Author: Thomas Renninger <trenn@suse.de>
> Date:   Mon Jul 23 14:43:32 2007 +0200
>
>     ACPI: autoload modules - ACPICA modifications
>
>     Define standardized HIDs - Rename current acpi_device_id to acpica_device_id
>
>     Signed-off-by: Thomas Renninger <trenn@suse.de>
>     Signed-off-by: Len Brown <len.brown@intel.com>
>
>
>
> - Doug
>

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
