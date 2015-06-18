From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 18 Jun 2015 15:30:03 +0000
Subject: Re: [PATCH 01/44] kernel: Add support for poweroff handler call chain
Message-Id: <20150618153003.GA19224@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-2-git-send-email-linux@roeck-us.net>
 <55821936.4040704@codeaurora.org>
In-Reply-To: <55821936.4040704@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Boyd <sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, Heiko Stuebner <heiko@sntech.de>, Len Brown <len.brown@intel.com>, linux-xtensa@linux-xtensa.org, Pavel Machek <pavel@ucw.cz>, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, Alexander Graf <agraf@suse.de>, linux-acpi@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, xen-devel@lists.xenproject.org, devicetree@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-pm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-tegra@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-metag@vger.kernel.orgli

On Wed, Jun 17, 2015 at 06:04:54PM -0700, Stephen Boyd wrote:
[ ... ]
> 
> What happened to this series? I want to add shutdown support to my
> platform and I need to write a register on the PMIC in one driver to
> configure it for shutdown instead of restart and then write an MMIO
> register to tell the PMIC to actually do the shutdown in another driver.
> It seems that the notifier solves this case for me, albeit with the
> slight complication that I need to order the two with some priority.
> 
Can you use the .shutdown driver callback instead ?

I see other drivers use that, and check for system_state = SYSTEM_POWER_OFF
to power off the hardware.

Guenter
