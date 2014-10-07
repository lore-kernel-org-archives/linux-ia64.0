From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 07 Oct 2014 09:19:36 +0000
Subject: Re: [PATCH 35/44] m68k: Register with kernel poweroff handler
Message-Id: <CAMuHMdVZmsjK9FdK0T6mWwrnNc=Xc97B7ynm+QbWUMBCnvQB_g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
	<1412659726-29957-36-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-36-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "adi-buildroot-devel@lists.sourceforge.net" <adi-buildroot-devel@lists.sourceforge.net>, driverdevel <devel@driverdev.osuosl.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, lguest@lists.ozlabs.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, alpha <linux-alpha@vger.kernel.org>, "moderated list:PANASONIC MN10300..." <linux-am33-list@redhat.com>, Cris <linux-cris-kernel@axis.com>, linux-efi@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-m32r-ja@ml.linux-m32r.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-tegra@vger.kernel.org, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, openipmi-developer@lists.sourceforge.net, uml-devel <user-mode-linux-devel@lists.s>

On Tue, Oct 7, 2014 at 7:28 AM, Guenter Roeck <linux@roeck-us.net> wrote:
> Register with kernel poweroff handler instead of setting pm_power_off
> directly.
>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Joshua Thompson <funaho@jurai.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

As someone already mentioned, having #defines instead of hardcoded
numbers for the priorities would be nice.

Apart from that:

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

> +       register_poweroff_handler_simple(nf_poweroff, 128);

> +       register_poweroff_handler_simple(mac_poweroff, 128);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
