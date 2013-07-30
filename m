From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 30 Jul 2013 17:53:10 +0000
Subject: Re: [PATCH 1/4] efi: provide a generic efi_config_init()
Message-Id: <CA+8MBbK5S3z+VQhhuT5WT7=7zYy=5zyvZEWfnfTfc1NxXBa=Sg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
	<1375202858-28470-2-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375202858-28470-2-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, patches@linaro.org

On Tue, Jul 30, 2013 at 9:47 AM, Leif Lindholm <leif.lindholm@linaro.org> wrote:
> +       /*
> +        * Let's see what config tables the firmware passed to us.
> +        */
> +       config_tables = early_mememap(efi.systab->tables,
> +                                      efi.systab->nr_tables * sz);

Breaks bisection on ia64 ... you use early_mememap() here, but don't
define it on ia64 until patch 3/4.  So I get:

drivers/firmware/efi/efi.c: In function 'efi_config_init':
drivers/firmware/efi/efi.c:200: error: implicit declaration of
function 'early_memremap'
drivers/firmware/efi/efi.c:201: warning: assignment makes pointer from
integer without a cast

-Tony
