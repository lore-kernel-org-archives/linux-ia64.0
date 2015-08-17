From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Mon, 17 Aug 2015 19:27:23 +0000
Subject: Re: [RFT PATCH] ia64: zx1_defconfig: convert to use libata PATA drivers
Message-Id: <CAA9xbM52onBKCw9i=_ar0W67651JpJnRTj6AeVsmJ4UAtzubew@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439826388-31456-1-git-send-email-b.zolnierkie@samsung.com>
	<1439826388-31456-5-git-send-email-b.zolnierkie@samsung.com>
In-Reply-To: <1439826388-31456-5-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ide@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

I'm running kernels configured that way (i.e. using libata PATA
drivers) for years on my hp workstation zx6000 (zx1 chipset) without
apparent problems.

Cheers,

     =C3=89meric

2015-08-17 17:46 GMT+02:00 Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.=
com>:
> IDE subsystem has been deprecated since 2009 and the majority
> (if not all) of Linux distributions have switched to use
> libata for ATA support exclusively.  However there are still
> some users (mostly old or/and embedded non-x86 systems) that
> have not converted from using IDE subsystem to libata PATA
> drivers.  This doesn't seem to be good thing in the long-term
> for Linux as while there is less and less PATA systems left
> in use:
>
> * testing efforts are divided between two subsystems
>
> * having duplicate drivers for same hardware confuses users
>
> This patch converts zx1_defconfig to use libata PATA
> drivers.
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> ---
> Build tested only.
> If you have affected hardware please test.  Thank you.
>
>  arch/ia64/configs/zx1_defconfig | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defc=
onfig
> index b504c8e..1ecda7e 100644
> --- a/arch/ia64/configs/zx1_defconfig
> +++ b/arch/ia64/configs/zx1_defconfig
> @@ -27,11 +27,6 @@ CONFIG_IP_MULTICAST=3Dy
>  CONFIG_NETFILTER=3Dy
>  CONFIG_BLK_DEV_LOOP=3Dy
>  CONFIG_BLK_DEV_RAM=3Dy
> -CONFIG_IDE=3Dy
> -CONFIG_BLK_DEV_IDECD=3Dy
> -CONFIG_BLK_DEV_GENERIC=3Dy
> -CONFIG_BLK_DEV_CMD64X=3Dy
> -CONFIG_SCSI=3Dy
>  CONFIG_BLK_DEV_SD=3Dy
>  CONFIG_CHR_DEV_ST=3Dy
>  CONFIG_CHR_DEV_OSST=3Dy
> @@ -43,6 +38,9 @@ CONFIG_SCSI_LOGGING=3Dy
>  CONFIG_SCSI_FC_ATTRS=3Dy
>  CONFIG_SCSI_SYM53C8XX_2=3Dy
>  CONFIG_SCSI_QLOGIC_1280=3Dy
> +CONFIG_ATA=3Dy
> +CONFIG_PATA_CMD64X=3Dy
> +CONFIG_ATA_GENERIC=3Dy
>  CONFIG_FUSION=3Dy
>  CONFIG_FUSION_SPI=3Dy
>  CONFIG_FUSION_FC=3Dy
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
