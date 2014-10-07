From: =?windows-1252?Q?Philippe_R=E9tornaz?=  <philippe.retornaz@gmail.com>
Date: Tue, 07 Oct 2014 07:46:59 +0000
Subject: Re: [PATCH 01/44] kernel: Add support for poweroff handler call chain
Message-Id: <54339A73.40107@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net> <1412659726-29957-2-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-2-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>, linux-kernel@vger.kernel.org
Cc: linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, Heiko Stuebner <heiko@sntech.de>, Len Brown <len.brown@intel.com>, linux-xtensa@linux-xtensa.org, Pavel Machek <pavel@ucw.cz>, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, Alexander Graf <agraf@suse.de>, linux-acpi@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, xen-devel@lists.xenproject.org, devicetree@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-pm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-tegra@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead

Hello

This seems exactly what I would need on the mc13783 to handle cleanly 
the poweroff,
but after reading this patchset I have the following question:

[...]

> +/*
> + *	Notifier list for kernel code which wants to be called
> + *	to power off the system.
> + */
> +static ATOMIC_NOTIFIER_HEAD(poweroff_handler_list);

[...]

> +void do_kernel_poweroff(void)
> +{
> +	atomic_notifier_call_chain(&poweroff_handler_list, 0, NULL);
> +}
> +

It seems that the poweroff callback needs to be atomic as per
_atomic_notifier_call_chain documentation:

	"Calls each function in a notifier chain in turn.  The functions
	 run in an atomic context"

But this is a problem for many MFD (mc13783, twl4030 etc ...) which are
accessible on only a blocking bus (SPI, I2C).

What I am missing here ?

Thanks,

Philippe
