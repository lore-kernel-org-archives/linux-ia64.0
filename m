From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 17 Aug 2015 16:19:06 +0000
Subject: Re: [RFT PATCH] ia64: generic_defconfig: convert to use libata PATA drivers
Message-Id: <55D2097A.7090203@cogentembedded.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439826388-31456-1-git-send-email-b.zolnierkie@samsung.com>
 <1439826388-31456-2-git-send-email-b.zolnierkie@samsung.com>
In-Reply-To: <1439826388-31456-2-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org

Hello.

On 08/17/2015 06:46 PM, Bartlomiej Zolnierkiewicz wrote:

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
> This patch converts generic_defconfig to use libata PATA
> drivers (sgiioc4 IDE host driver has no corresponding libata
> driver yet so it is not converted).
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> ---
> Build tested only.
> If you have affected hardware please test.  Thank you.
>
>   arch/ia64/configs/generic_defconfig | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
> index 81f686d..f55be82 100644
> --- a/arch/ia64/configs/generic_defconfig
> +++ b/arch/ia64/configs/generic_defconfig
[...]
> @@ -62,6 +59,9 @@ CONFIG_SCSI_QLOGIC_1280=y
>   CONFIG_ATA=y
>   CONFIG_ATA_PIIX=y
>   CONFIG_SATA_VITESSE=y
> +CONFIG_PATA_CMD64X=y
> +CONFIG_PATA_MPIIX=y

    If you're enabling the MPIIX support (which I doubt is necessary), why not 
enable the "old" PIIX support?

> +CONFIG_ATA_GENERIC=y

MBR, Sergei

