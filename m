From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 09 Oct 2014 10:36:56 +0000
Subject: Re: [PATCH 12/44] mfd: ab8500-sysctrl: Register with kernel poweroff handler
Message-Id: <20141009103656.GF17836@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-13-git-send-email-linux@roeck-us.net>
 <20141007080048.GB25331@lee--X1>
In-Reply-To: <20141007080048.GB25331@lee--X1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Jones <lee.jones@linaro.org>
Cc: "linux-m32r-ja@ml.linux-m32r.org" <linux-m32r-ja@ml.linux-m32r.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "lguest@lists.ozlabs.org" <lguest@lists.ozlabs.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, G

On Tue, Oct 07, 2014 at 09:00:48AM +0100, Lee Jones wrote:
> On Mon, 06 Oct 2014, Guenter Roeck wrote:
> > --- a/drivers/mfd/ab8500-sysctrl.c
> > +++ b/drivers/mfd/ab8500-sysctrl.c
> > @@ -6,6 +6,7 @@
> 
> [...]
> 
> > +static int ab8500_power_off(struct notifier_block *this, unsigned long unused1,
> > +			    void *unused2)
> >  {
> >  	sigset_t old;
> >  	sigset_t all;
> > @@ -34,11 +36,6 @@ static void ab8500_power_off(void)
> >  	struct power_supply *psy;
> >  	int ret;
> >  
> > -	if (sysctrl_dev = NULL) {
> > -		pr_err("%s: sysctrl not initialized\n", __func__);
> > -		return;
> > -	}
> 
> Can you explain the purpose of this change please?

I guess it's because the sysctrl_dev is already initialised when
registering the power_off handler, so there isn't a way to call the
above function with a NULL sysctrl_dev. Probably even with the original
code you didn't need this check (after some race fix in
ab8500_sysctrl_remove but races is one of the things Guenter's patches
try to address).

-- 
Catalin
