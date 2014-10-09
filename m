From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 09 Oct 2014 15:54:04 +0000
Subject: Re: [PATCH 12/44] mfd: ab8500-sysctrl: Register with kernel poweroff handler
Message-Id: <20141009155404.GC31987@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-13-git-send-email-linux@roeck-us.net>
 <20141007080048.GB25331@lee--X1>
 <20141009103656.GF17836@e104818-lin.cambridge.arm.com>
 <20141009104927.GN20647@lee--X1>
In-Reply-To: <20141009104927.GN20647@lee--X1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, "linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org" <linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org>, "linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, "linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, "linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, "linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org" <linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org>, "linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org" <xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org>, devicetree

On Thu, Oct 09, 2014 at 11:49:27AM +0100, Lee Jones wrote:
> On Thu, 09 Oct 2014, Catalin Marinas wrote:
> 
> > On Tue, Oct 07, 2014 at 09:00:48AM +0100, Lee Jones wrote:
> > > On Mon, 06 Oct 2014, Guenter Roeck wrote:
> > > > --- a/drivers/mfd/ab8500-sysctrl.c
> > > > +++ b/drivers/mfd/ab8500-sysctrl.c
> > > > @@ -6,6 +6,7 @@
> > > 
> > > [...]
> > > 
> > > > +static int ab8500_power_off(struct notifier_block *this, unsigned long unused1,
> > > > +			    void *unused2)
> > > >  {
> > > >  	sigset_t old;
> > > >  	sigset_t all;
> > > > @@ -34,11 +36,6 @@ static void ab8500_power_off(void)
> > > >  	struct power_supply *psy;
> > > >  	int ret;
> > > >  
> > > > -	if (sysctrl_dev = NULL) {
> > > > -		pr_err("%s: sysctrl not initialized\n", __func__);
> > > > -		return;
> > > > -	}
> > > 
> > > Can you explain the purpose of this change please?
> > 
> > I guess it's because the sysctrl_dev is already initialised when
> > registering the power_off handler, so there isn't a way to call the
> > above function with a NULL sysctrl_dev. Probably even with the original
> > code you didn't need this check (after some race fix in
> > ab8500_sysctrl_remove but races is one of the things Guenter's patches
> > try to address).
> 
> Sounds reasonable, although I think this change should be part of
> another patch.
> 
Turns out the options are to either drop the check or to use the device
managed function to register the poweroff handler. I decided to keep
the check and use the device managed function.

Guenter
