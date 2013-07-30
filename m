From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 30 Jul 2013 18:14:51 +0000
Subject: Re: [PATCH 1/4] efi: provide a generic efi_config_init()
Message-Id: <CA+8MBbLbsrH=gNJ4oc5VzphY6xFMthWoq5R905Rzaow2SmA9uw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
	<1375202858-28470-2-git-send-email-leif.lindholm@linaro.org>
	<CA+8MBbK5S3z+VQhhuT5WT7=7zYy=5zyvZEWfnfTfc1NxXBa=Sg@mail.gmail.com>
	<20130730180230.GJ18151@rocoto.smurfnet.nu>
In-Reply-To: <20130730180230.GJ18151@rocoto.smurfnet.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, patches@linaro.org

On Tue, Jul 30, 2013 at 11:02 AM, Leif Lindholm
<leif.lindholm@linaro.org> wrote:
> So I guess the clean way to deal with that would be to make the
> memremap definition a separate patch?

Or just pull:
+#define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
out of part 3 and put it into part1 (along with some of the commit commentary).

-Tony
