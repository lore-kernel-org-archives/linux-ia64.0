From: Alessandro Zummo <alessandro.zummo@towertech.it>
Date: Wed, 14 Jan 2009 10:57:28 +0000
Subject: Re: [PATCH] add rtc platform driver for EFI
Message-Id: <20090114115728.15f2db18@i1501.lan.towertech.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090109005644.GH32403@ldl.fc.hp.com>
	<20090109032729.6e4cd5fd@i1501.lan.towertech.it>
	<20090109213615.GD31548@ldl.fc.hp.com>
	<20090113003934.0a7da676.akpm@linux-foundation.org>
	<20090114000043.GB24423@colo.lackof.org>
	<20090114011719.GD24423@colo.lackof.org>
	<20090114023055.1d22d09e@i1501.lan.towertech.it>
	<20090114041358.GA21357@ldl.fc.hp.com>
	<20090114043337.GB21357@ldl.fc.hp.com>
In-Reply-To: <20090114043337.GB21357@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dann frazier <dannf@hp.com>
Cc: rtc-linux@googlegroups.com, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stephane eranian <eranian@googlemail.com>

On Tue, 13 Jan 2009 21:33:38 -0700
dann frazier <dannf@hp.com> wrote:

> Munge Stephane Eranian's efirtc.c code into an rtc platform driver

 almost there :) see below
 
> Signed-off-by: dann frazier <dannf@hp.com>
> ---
>  arch/ia64/kernel/time.c |   16 +++
>  drivers/rtc/Kconfig     |   10 ++
>  drivers/rtc/Makefile    |    1 +
>  drivers/rtc/rtc-efi.c   |  240 +++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 267 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/rtc/rtc-efi.c
> 
> diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
> index f0ebb34..558051c 100644
> --- a/arch/ia64/kernel/time.c
> +++ b/arch/ia64/kernel/time.c
> @@ -20,6 +20,7 @@
>  #include <linux/efi.h>
>  #include <linux/timex.h>
>  #include <linux/clocksource.h>
> +#include <linux/platform_device.h>
>  
>  #include <asm/machvec.h>
>  #include <asm/delay.h>
> @@ -405,6 +406,21 @@ static struct irqaction timer_irqaction = {
>  	.name =		"timer"
>  };
>  
> +static struct platform_device rtc_efi_dev = {
> +	.name = "rtc-efi",
> +	.id = -1,
> +};
> +
> +static int __init rtc_init(void)
> +{
> +	if (platform_device_register(&rtc_efi_dev) < 0)
> +		printk(KERN_ERR "unable to register rtc device...\n");
> +       
> +	/* not necessarily an error */
> +	return 0;
> +}
> +module_init(rtc_init);
> +
>  void __init
>  time_init (void)
>  {
> diff --git a/drivers/rtc/Kconfig b/drivers/rtc/Kconfig
> index cced4d1..56cc98f 100644
> --- a/drivers/rtc/Kconfig
> +++ b/drivers/rtc/Kconfig
> @@ -434,6 +434,16 @@ config RTC_DRV_DS1742
>  	  This driver can also be built as a module. If so, the module
>  	  will be called rtc-ds1742.
>  
> +config RTC_DRV_EFI
> +	tristate "EFI RTC"
> +	depends on IA64
> +	help
> +	  If you say yes here you will get support for the EFI
> +	  Real Time Clock.
> +
> +	  This driver can also be built as a module. If so, the module
> +	  will be called rtc-efi.
> +
>  config RTC_DRV_STK17TA8
>  	tristate "Simtek STK17TA8"
>  	depends on RTC_CLASS
> diff --git a/drivers/rtc/Makefile b/drivers/rtc/Makefile
> index 6e28021..7256ce8 100644
> --- a/drivers/rtc/Makefile
> +++ b/drivers/rtc/Makefile
> @@ -35,6 +35,7 @@ obj-$(CONFIG_RTC_DRV_DS1553)	+= rtc-ds1553.o
>  obj-$(CONFIG_RTC_DRV_DS1672)	+= rtc-ds1672.o
>  obj-$(CONFIG_RTC_DRV_DS1742)	+= rtc-ds1742.o
>  obj-$(CONFIG_RTC_DRV_DS3234)	+= rtc-ds3234.o
> +obj-$(CONFIG_RTC_DRV_EFI)	+= rtc-efi.o
>  obj-$(CONFIG_RTC_DRV_EP93XX)	+= rtc-ep93xx.o
>  obj-$(CONFIG_RTC_DRV_FM3130)	+= rtc-fm3130.o
>  obj-$(CONFIG_RTC_DRV_ISL1208)	+= rtc-isl1208.o
> diff --git a/drivers/rtc/rtc-efi.c b/drivers/rtc/rtc-efi.c
> new file mode 100644
> index 0000000..2c98c35
> --- /dev/null
> +++ b/drivers/rtc/rtc-efi.c
> @@ -0,0 +1,240 @@
> +/*
> + * rtc-efi: RTC Class Driver for EFI-based systems
> + *
> + * Copyright (C) 2009 Hewlett-Packard Development Company, L.P.
> + *
> + * Author: dann frazier <dannf@hp.com>
> + * Based on efirtc.c by Stephane Eranian
> + *
> + *  This program is free software; you can redistribute  it and/or modify it
> + *  under  the terms of  the GNU General  Public License as published by the
> + *  Free Software Foundation;  either version 2 of the  License, or (at your
> + *  option) any later version.
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/time.h>
> +#include <linux/platform_device.h>
> +#include <linux/rtc.h>
> +#include <linux/efi.h>
> +
> +#define EFI_ISDST (EFI_TIME_ADJUST_DAYLIGHT|EFI_TIME_IN_DAYLIGHT)
> +/*
> + * EFI Epoch is 1/1/1998
> + */
> +#define EFI_RTC_EPOCH		1998
> +
> +#define LEAP_YEAR(year) ((!(year % 4) && (year % 100)) || !(year % 400))
> +
> +/*
> + * returns day of the year [0-365]
> + */
> +static inline int
> +compute_yday(efi_time_t *eft)
> +{
> +	/* efi_time_t.month is in the [1-12] so, we need -1 */
> +	return rtc_year_days(eft->day - 1, eft->month - 1, eft->year);
> +}
> +/*
> + * returns day of the week [0-6] 0=Sunday
> + *
> + * Don't try to provide a year that's before 1998, please !
> + */
> +static int
> +compute_wday(efi_time_t *eft)
> +{
> +	int y;
> +	int ndays = 0;
> +
> +	if (eft->year < 1998) {
> +		printk(KERN_ERR "efirtc: EFI year < 1998, invalid date\n");
> +		return -1;
> +	}
> +
> +	for (y = EFI_RTC_EPOCH; y < eft->year; y++)
> +		ndays += 365 + (LEAP_YEAR(y) ? 1 : 0);
> +
> +	ndays += compute_yday(eft);
> +
> +	/*
> +	 * 4=1/1/1998 was a Thursday
> +	 */
> +	return (ndays + 4) % 7;
> +}
> +
> +static void
> +convert_to_efi_time(struct rtc_time *wtime, efi_time_t *eft)
> +{
> +	eft->year	= wtime->tm_year + 1900;
> +	eft->month	= wtime->tm_mon + 1;
> +	eft->day	= wtime->tm_mday;
> +	eft->hour	= wtime->tm_hour;
> +	eft->minute	= wtime->tm_min;
> +	eft->second 	= wtime->tm_sec;
> +	eft->nanosecond = 0;
> +	eft->daylight	= wtime->tm_isdst ? EFI_ISDST : 0;
> +	eft->timezone	= EFI_UNSPECIFIED_TIMEZONE;
> +}
> +
> +static void
> +convert_from_efi_time(efi_time_t *eft, struct rtc_time *wtime)
> +{
> +	memset(wtime, 0, sizeof(*wtime));
> +	wtime->tm_sec  = eft->second;
> +	wtime->tm_min  = eft->minute;
> +	wtime->tm_hour = eft->hour;
> +	wtime->tm_mday = eft->day;
> +	wtime->tm_mon  = eft->month - 1;
> +	wtime->tm_year = eft->year - 1900;
> +
> +	/* day of the week [0-6], Sunday=0 */
> +	wtime->tm_wday = compute_wday(eft);
> +
> +	/* day in the year [1-365]*/
> +	wtime->tm_yday = compute_yday(eft);
> +
> +
> +	switch (eft->daylight & EFI_ISDST) {
> +	case EFI_ISDST:
> +		wtime->tm_isdst = 1;
> +		break;
> +	case EFI_TIME_ADJUST_DAYLIGHT:
> +		wtime->tm_isdst = 0;
> +		break;
> +	default:
> +		wtime->tm_isdst = -1;
> +	}
> +}
> +
> +static int efi_read_alarm(struct device *dev, struct rtc_wkalrm *wkalrm)
> +{
> +	efi_time_t eft;
> +	efi_status_t status;
> +
> +	/*
> +	 * As of EFI v1.10, this call always returns an unsupported status
> +	 */
> +	status = efi.get_wakeup_time((efi_bool_t *)&wkalrm->enabled,
> +				     (efi_bool_t *)&wkalrm->pending, &eft);
> +
> +	if (status != EFI_SUCCESS)
> +		return -EINVAL;
> +
> +	convert_from_efi_time(&eft, &wkalrm->time);
> +
> +	return rtc_valid_tm(&wkalrm->time);
> +}
> +
> +static int efi_set_alarm(struct device *dev, struct rtc_wkalrm *wkalrm)
> +{
> +	efi_time_t eft;
> +	efi_status_t status;
> +
> +	convert_to_efi_time(&wkalrm->time, &eft);
> +
> +	/*
> +	 * XXX Fixme:
> +	 * As of EFI 0.92 with the firmware I have on my
> +	 * machine this call does not seem to work quite
> +	 * right
> +	 *
> +	 * As of v1.10, this call always returns an unsupported status
> +	 */
> +	status = efi.set_wakeup_time((efi_bool_t)wkalrm->enabled, &eft);
> +
> +	printk(KERN_WARNING "write status is %d\n", (int)status);
> +
> +	return status = EFI_SUCCESS ? 0 : -EINVAL;
> +}
> +
> +static int efi_read_time(struct device *dev, struct rtc_time *tm)
> +{
> +	efi_status_t status;
> +	efi_time_t eft;
> +	efi_time_cap_t cap;
> +
> +	status = efi.get_time(&eft, &cap);
> +
> +	if (status != EFI_SUCCESS) {
> +		/* should never happen */
> +		printk(KERN_ERR "efitime: can't read time\n");
> +		return -EINVAL;
> +	}
> +
> +	convert_from_efi_time(&eft, tm);
> +
> +	return rtc_valid_tm(tm);
> +}
> +
> +static int efi_set_time(struct device *dev, struct rtc_time *tm)
> +{
> +	efi_status_t status;
> +	efi_time_t eft;
> +
> +	convert_to_efi_time(tm, &eft);
> +
> +	status = efi.set_time(&eft);
> +
> +	return status = EFI_SUCCESS ? 0 : -EINVAL;
> +}
> +
> +static const struct rtc_class_ops efi_rtc_ops = {
> +	.read_time = efi_read_time,
> +	.set_time = efi_set_time,
> +	.read_alarm = efi_read_alarm,
> +	.set_alarm = efi_set_alarm,
> +};
> +
> +static int __init efi_rtc_probe(struct platform_device *dev)
> +{
> +	struct rtc_device *rtc;
> +
> +	rtc = rtc_device_register("rtc-efi", &dev->dev, &efi_rtc_ops,
> +					THIS_MODULE);
> +	if (IS_ERR(rtc)) {
> +		int err = PTR_ERR(rtc);
> +		return err;
> +	}


	if (IS_ERR(rtc))
		return PTR_ERR(rtc);


> +
> +	platform_set_drvdata(dev, rtc);
> +
> +	return 0;
> +}
> +
> +static int __exit efi_rtc_remove(struct platform_device *dev)
> +{
> +	struct rtc_device *rtc = platform_get_drvdata(dev);
> +
> +	rtc_device_unregister(rtc);
> +	kfree(rtc);


 don't free it!!


> +
> +	return 0;
> +}
> +
> +static struct platform_driver efi_rtc_driver = {
> +	.driver = {
> +		.name = "rtc-efi",
> +		.owner = THIS_MODULE,
> +	},
> +	.probe = efi_rtc_probe,
> +	.remove = __exit_p(efi_rtc_remove),
> +};
> +
> +static int __init efi_rtc_init(void)
> +{
> +	return platform_driver_probe(&efi_rtc_driver, efi_rtc_probe);
> +}
> +
> +static void __exit efi_rtc_exit(void)
> +{
> +	platform_driver_unregister(&efi_rtc_driver);
> +}
> +
> +module_init(efi_rtc_init);
> +module_exit(efi_rtc_exit);
> +
> +MODULE_AUTHOR("dann frazier <dannf@hp.com>");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("EFI RTC driver");
> -- 
> 1.5.6.5
> 


-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Torino, Italy

  http://www.towertech.it

