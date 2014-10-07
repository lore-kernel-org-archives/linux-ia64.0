From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Tue, 07 Oct 2014 08:04:20 +0000
Subject: Re: [PATCH 31/44] arm: Register with kernel poweroff handler
Message-Id: <54339E84.2070805@atmel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net> <1412659726-29957-32-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-32-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>, linux-kernel@vger.kernel.org, Alexandre Belloni <alexandre.belloni@free-electrons.com>, Boris BREZILLON <boris.brezillon@free-electrons.com>
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.o

On 07/10/2014 07:28, Guenter Roeck :
> Register with kernel poweroff handler instead of setting pm_power_off
> directly. Always use register_poweroff_handler_simple as there is no
> indication that more than one poweroff handler is registered.
> 
> If the poweroff handler only resets the system or puts the CPU in sleep mode,
> select a priority of 0 to indicate that the poweroff handler is one of last
> resort. If the poweroff handler powers off the system, select a priority
> of 128.
> 
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Andrew Victor <linux@maxim.org.za>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
> Cc: Stephen Warren <swarren@wwwdotorg.org>
> Cc: Christian Daudt <bcm@fixthebug.org>
> Cc: Matt Porter <mporter@linaro.org>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Shawn Guo <shawn.guo@freescale.com>
> Cc: Sascha Hauer <kernel@pengutronix.de>
> Cc: Imre Kaloz <kaloz@openwrt.org>
> Cc: Krzysztof Halasa <khc@pm.waw.pl>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Cc: Eric Miao <eric.y.miao@gmail.com>
> Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
> Cc: Robert Jarzmik <robert.jarzmik@free.fr>
> Cc: Marek Vasut <marek.vasut@gmail.com>
> Cc: Ben Dooks <ben-linux@fluff.org>
> Cc: Kukjin Kim <kgene.kim@samsung.com>
> Cc: Linus Walleij <linus.walleij@linaro.org>
> Cc: Tony Prisk <linux@prisktech.co.nz>
> Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  arch/arm/kernel/psci.c                         | 2 +-


>  arch/arm/mach-at91/board-gsia18s.c             | 2 +-
>  arch/arm/mach-at91/setup.c                     | 4 ++--

For the 2 files above: NAK just because:
for the first one -> this file will be removed during 3.19 dev cycle.
for the second one -> the poweroff handlers are removed during the 3.18
cycle and converted in the appropriate poweroff drivers (in
drivers/power/reset/at91-poweroff.c).

So, can you remove these changes from your patch?

Thanks for your work, bye.

>  arch/arm/mach-bcm/board_bcm2835.c              | 2 +-
>  arch/arm/mach-cns3xxx/cns3420vb.c              | 2 +-
>  arch/arm/mach-cns3xxx/core.c                   | 2 +-
>  arch/arm/mach-highbank/highbank.c              | 2 +-
>  arch/arm/mach-imx/mach-mx31moboard.c           | 2 +-
>  arch/arm/mach-iop32x/em7210.c                  | 2 +-
>  arch/arm/mach-iop32x/glantank.c                | 2 +-
>  arch/arm/mach-iop32x/iq31244.c                 | 2 +-
>  arch/arm/mach-iop32x/n2100.c                   | 2 +-
>  arch/arm/mach-ixp4xx/dsmg600-setup.c           | 2 +-
>  arch/arm/mach-ixp4xx/nas100d-setup.c           | 2 +-
>  arch/arm/mach-ixp4xx/nslu2-setup.c             | 2 +-
>  arch/arm/mach-omap2/board-omap3touchbook.c     | 2 +-
>  arch/arm/mach-orion5x/board-mss2.c             | 2 +-
>  arch/arm/mach-orion5x/dns323-setup.c           | 6 +++---
>  arch/arm/mach-orion5x/kurobox_pro-setup.c      | 2 +-
>  arch/arm/mach-orion5x/ls-chl-setup.c           | 2 +-
>  arch/arm/mach-orion5x/ls_hgl-setup.c           | 2 +-
>  arch/arm/mach-orion5x/lsmini-setup.c           | 2 +-
>  arch/arm/mach-orion5x/mv2120-setup.c           | 2 +-
>  arch/arm/mach-orion5x/net2big-setup.c          | 2 +-
>  arch/arm/mach-orion5x/terastation_pro2-setup.c | 2 +-
>  arch/arm/mach-orion5x/ts209-setup.c            | 2 +-
>  arch/arm/mach-orion5x/ts409-setup.c            | 2 +-
>  arch/arm/mach-pxa/corgi.c                      | 2 +-
>  arch/arm/mach-pxa/mioa701.c                    | 2 +-
>  arch/arm/mach-pxa/poodle.c                     | 2 +-
>  arch/arm/mach-pxa/spitz.c                      | 2 +-
>  arch/arm/mach-pxa/tosa.c                       | 2 +-
>  arch/arm/mach-pxa/viper.c                      | 2 +-
>  arch/arm/mach-pxa/z2.c                         | 6 +++---
>  arch/arm/mach-pxa/zeus.c                       | 6 +++---
>  arch/arm/mach-s3c24xx/mach-gta02.c             | 2 +-
>  arch/arm/mach-s3c24xx/mach-jive.c              | 2 +-
>  arch/arm/mach-s3c24xx/mach-vr1000.c            | 2 +-
>  arch/arm/mach-s3c64xx/mach-smartq.c            | 2 +-
>  arch/arm/mach-sa1100/generic.c                 | 2 +-
>  arch/arm/mach-sa1100/simpad.c                  | 2 +-
>  arch/arm/mach-u300/regulator.c                 | 2 +-
>  arch/arm/mach-vt8500/vt8500.c                  | 2 +-
>  arch/arm/xen/enlighten.c                       | 2 +-
>  44 files changed, 51 insertions(+), 51 deletions(-)
> 
> diff --git a/arch/arm/kernel/psci.c b/arch/arm/kernel/psci.c
> index f73891b..dd58d86 100644
> --- a/arch/arm/kernel/psci.c
> +++ b/arch/arm/kernel/psci.c
> @@ -264,7 +264,7 @@ static int psci_0_2_init(struct device_node *np)
>  
>  	arm_pm_restart = psci_sys_reset;
>  
> -	pm_power_off = psci_sys_poweroff;
> +	register_poweroff_handler_simple(psci_sys_poweroff, 128);
>  
>  out_put_node:
>  	of_node_put(np);
> diff --git a/arch/arm/mach-at91/board-gsia18s.c b/arch/arm/mach-at91/board-gsia18s.c
> index b729dd1..6722e66 100644
> --- a/arch/arm/mach-at91/board-gsia18s.c
> +++ b/arch/arm/mach-at91/board-gsia18s.c
> @@ -521,7 +521,7 @@ static void gsia18s_power_off(void)
>  
>  static int __init gsia18s_power_off_init(void)
>  {
> -	pm_power_off = gsia18s_power_off;
> +	register_poweroff_handler_simple(gsia18s_power_off, 128);
>  	return 0;
>  }
>  
> diff --git a/arch/arm/mach-at91/setup.c b/arch/arm/mach-at91/setup.c
> index f7a07a5..9989e88 100644
> --- a/arch/arm/mach-at91/setup.c
> +++ b/arch/arm/mach-at91/setup.c
> @@ -329,7 +329,7 @@ void __init at91_ioremap_shdwc(u32 base_addr)
>  	at91_shdwc_base = ioremap(base_addr, 16);
>  	if (!at91_shdwc_base)
>  		panic("Impossible to ioremap at91_shdwc_base\n");
> -	pm_power_off = at91sam9_poweroff;
> +	register_poweroff_handler_simple(at91sam9_poweroff, 128);
>  }
>  
>  void __iomem *at91_rstc_base;
> @@ -482,7 +482,7 @@ static void at91_dt_shdwc(void)
>  	at91_shdwc_write(AT91_SHDW_MR, wakeup_mode | mode);
>  
>  end:
> -	pm_power_off = at91sam9_poweroff;
> +	register_poweroff_handler_simple(at91sam9_poweroff, 128);
>  
>  	of_node_put(np);
>  }
> diff --git a/arch/arm/mach-bcm/board_bcm2835.c b/arch/arm/mach-bcm/board_bcm2835.c
> index 70f2f39..7d5784f 100644
> --- a/arch/arm/mach-bcm/board_bcm2835.c
> +++ b/arch/arm/mach-bcm/board_bcm2835.c
> @@ -111,7 +111,7 @@ static void __init bcm2835_init(void)
>  
>  	bcm2835_setup_restart();
>  	if (wdt_regs)
> -		pm_power_off = bcm2835_power_off;
> +		register_poweroff_handler_simple(bcm2835_power_off, 0);
>  
>  	bcm2835_init_clocks();
>  
> diff --git a/arch/arm/mach-cns3xxx/cns3420vb.c b/arch/arm/mach-cns3xxx/cns3420vb.c
> index d863d87..136b7c6 100644
> --- a/arch/arm/mach-cns3xxx/cns3420vb.c
> +++ b/arch/arm/mach-cns3xxx/cns3420vb.c
> @@ -224,7 +224,7 @@ static void __init cns3420_init(void)
>  	cns3xxx_ahci_init();
>  	cns3xxx_sdhci_init();
>  
> -	pm_power_off = cns3xxx_power_off;
> +	register_poweroff_handler_simple(cns3xxx_power_off, 128);
>  }
>  
>  static struct map_desc cns3420_io_desc[] __initdata = {
> diff --git a/arch/arm/mach-cns3xxx/core.c b/arch/arm/mach-cns3xxx/core.c
> index f85449a..79e6ead 100644
> --- a/arch/arm/mach-cns3xxx/core.c
> +++ b/arch/arm/mach-cns3xxx/core.c
> @@ -386,7 +386,7 @@ static void __init cns3xxx_init(void)
>  		cns3xxx_pwr_soft_rst(CNS3XXX_PWR_SOFTWARE_RST(SDIO));
>  	}
>  
> -	pm_power_off = cns3xxx_power_off;
> +	register_poweroff_handler_simple(cns3xxx_power_off, 128);
>  
>  	of_platform_populate(NULL, of_default_bus_match_table,
>                          cns3xxx_auxdata, NULL);
> diff --git a/arch/arm/mach-highbank/highbank.c b/arch/arm/mach-highbank/highbank.c
> index 8c35ae4..25d0134 100644
> --- a/arch/arm/mach-highbank/highbank.c
> +++ b/arch/arm/mach-highbank/highbank.c
> @@ -155,7 +155,7 @@ static void __init highbank_init(void)
>  	sregs_base = of_iomap(np, 0);
>  	WARN_ON(!sregs_base);
>  
> -	pm_power_off = highbank_power_off;
> +	register_poweroff_handler_simple(highbank_power_off, 0);
>  	highbank_pm_init();
>  
>  	bus_register_notifier(&platform_bus_type, &highbank_platform_nb);
> diff --git a/arch/arm/mach-imx/mach-mx31moboard.c b/arch/arm/mach-imx/mach-mx31moboard.c
> index bb6f8a5..9b3616f 100644
> --- a/arch/arm/mach-imx/mach-mx31moboard.c
> +++ b/arch/arm/mach-imx/mach-mx31moboard.c
> @@ -559,7 +559,7 @@ static void __init mx31moboard_init(void)
>  
>  	imx_add_platform_device("imx_mc13783", 0, NULL, 0, NULL, 0);
>  
> -	pm_power_off = mx31moboard_poweroff;
> +	register_poweroff_handler_simple(mx31moboard_poweroff, 128);
>  
>  	switch (mx31moboard_baseboard) {
>  	case MX31NOBOARD:
> diff --git a/arch/arm/mach-iop32x/em7210.c b/arch/arm/mach-iop32x/em7210.c
> index 77e1ff0..beeeb0c2 100644
> --- a/arch/arm/mach-iop32x/em7210.c
> +++ b/arch/arm/mach-iop32x/em7210.c
> @@ -201,7 +201,7 @@ static int __init em7210_request_gpios(void)
>  		return 0;
>  	}
>  
> -	pm_power_off = em7210_power_off;
> +	register_poweroff_handler_simple(em7210_power_off, 128);
>  
>  	return 0;
>  }
> diff --git a/arch/arm/mach-iop32x/glantank.c b/arch/arm/mach-iop32x/glantank.c
> index 547b234..050a8e6 100644
> --- a/arch/arm/mach-iop32x/glantank.c
> +++ b/arch/arm/mach-iop32x/glantank.c
> @@ -199,7 +199,7 @@ static void __init glantank_init_machine(void)
>  	i2c_register_board_info(0, glantank_i2c_devices,
>  		ARRAY_SIZE(glantank_i2c_devices));
>  
> -	pm_power_off = glantank_power_off;
> +	register_poweroff_handler_simple(glantank_power_off, 128);
>  }
>  
>  MACHINE_START(GLANTANK, "GLAN Tank")
> diff --git a/arch/arm/mach-iop32x/iq31244.c b/arch/arm/mach-iop32x/iq31244.c
> index 0e1392b..4e9b972 100644
> --- a/arch/arm/mach-iop32x/iq31244.c
> +++ b/arch/arm/mach-iop32x/iq31244.c
> @@ -293,7 +293,7 @@ static void __init iq31244_init_machine(void)
>  	platform_device_register(&iop3xx_dma_1_channel);
>  
>  	if (is_ep80219())
> -		pm_power_off = ep80219_power_off;
> +		register_poweroff_handler_simple(ep80219_power_off, 128);
>  
>  	if (!is_80219())
>  		platform_device_register(&iop3xx_aau_channel);
> diff --git a/arch/arm/mach-iop32x/n2100.c b/arch/arm/mach-iop32x/n2100.c
> index c1cd80e..171d496 100644
> --- a/arch/arm/mach-iop32x/n2100.c
> +++ b/arch/arm/mach-iop32x/n2100.c
> @@ -356,7 +356,7 @@ static void __init n2100_init_machine(void)
>  	i2c_register_board_info(0, n2100_i2c_devices,
>  		ARRAY_SIZE(n2100_i2c_devices));
>  
> -	pm_power_off = n2100_power_off;
> +	register_poweroff_handler_simple(n2100_power_off, 128);
>  }
>  
>  MACHINE_START(N2100, "Thecus N2100")
> diff --git a/arch/arm/mach-ixp4xx/dsmg600-setup.c b/arch/arm/mach-ixp4xx/dsmg600-setup.c
> index 43ee06d..6fb5072 100644
> --- a/arch/arm/mach-ixp4xx/dsmg600-setup.c
> +++ b/arch/arm/mach-ixp4xx/dsmg600-setup.c
> @@ -281,7 +281,7 @@ static void __init dsmg600_init(void)
>  
>  	platform_add_devices(dsmg600_devices, ARRAY_SIZE(dsmg600_devices));
>  
> -	pm_power_off = dsmg600_power_off;
> +	register_poweroff_handler_simple(dsmg600_power_off, 128);
>  }
>  
>  MACHINE_START(DSMG600, "D-Link DSM-G600 RevA")
> diff --git a/arch/arm/mach-ixp4xx/nas100d-setup.c b/arch/arm/mach-ixp4xx/nas100d-setup.c
> index 4e0f762..bd9a8d6 100644
> --- a/arch/arm/mach-ixp4xx/nas100d-setup.c
> +++ b/arch/arm/mach-ixp4xx/nas100d-setup.c
> @@ -292,7 +292,7 @@ static void __init nas100d_init(void)
>  
>  	platform_add_devices(nas100d_devices, ARRAY_SIZE(nas100d_devices));
>  
> -	pm_power_off = nas100d_power_off;
> +	register_poweroff_handler_simple(nas100d_power_off, 128);
>  
>  	if (request_irq(gpio_to_irq(NAS100D_RB_GPIO), &nas100d_reset_handler,
>  		IRQF_TRIGGER_LOW, "NAS100D reset button", NULL) < 0) {
> diff --git a/arch/arm/mach-ixp4xx/nslu2-setup.c b/arch/arm/mach-ixp4xx/nslu2-setup.c
> index 88c025f..c4c5475 100644
> --- a/arch/arm/mach-ixp4xx/nslu2-setup.c
> +++ b/arch/arm/mach-ixp4xx/nslu2-setup.c
> @@ -262,7 +262,7 @@ static void __init nslu2_init(void)
>  
>  	platform_add_devices(nslu2_devices, ARRAY_SIZE(nslu2_devices));
>  
> -	pm_power_off = nslu2_power_off;
> +	register_poweroff_handler_simple(nslu2_power_off, 128);
>  
>  	if (request_irq(gpio_to_irq(NSLU2_RB_GPIO), &nslu2_reset_handler,
>  		IRQF_TRIGGER_LOW, "NSLU2 reset button", NULL) < 0) {
> diff --git a/arch/arm/mach-omap2/board-omap3touchbook.c b/arch/arm/mach-omap2/board-omap3touchbook.c
> index 70b904c..0c0a0e2 100644
> --- a/arch/arm/mach-omap2/board-omap3touchbook.c
> +++ b/arch/arm/mach-omap2/board-omap3touchbook.c
> @@ -344,7 +344,7 @@ static void __init omap3_touchbook_init(void)
>  {
>  	omap3_mux_init(board_mux, OMAP_PACKAGE_CBB);
>  
> -	pm_power_off = omap3_touchbook_poweroff;
> +	register_poweroff_handler_simple(omap3_touchbook_poweroff, 128);
>  
>  	if (system_rev >= 0x20 && system_rev <= 0x34301000) {
>  		omap_mux_init_gpio(23, OMAP_PIN_INPUT);
> diff --git a/arch/arm/mach-orion5x/board-mss2.c b/arch/arm/mach-orion5x/board-mss2.c
> index 66f9c3b..3840d66 100644
> --- a/arch/arm/mach-orion5x/board-mss2.c
> +++ b/arch/arm/mach-orion5x/board-mss2.c
> @@ -86,5 +86,5 @@ static void mss2_power_off(void)
>  void __init mss2_init(void)
>  {
>  	/* register mss2 specific power-off method */
> -	pm_power_off = mss2_power_off;
> +	register_poweroff_handler_simple(mss2_power_off, 0);
>  }
> diff --git a/arch/arm/mach-orion5x/dns323-setup.c b/arch/arm/mach-orion5x/dns323-setup.c
> index 56edeab..353ca3d 100644
> --- a/arch/arm/mach-orion5x/dns323-setup.c
> +++ b/arch/arm/mach-orion5x/dns323-setup.c
> @@ -669,7 +669,7 @@ static void __init dns323_init(void)
>  		if (gpio_request(DNS323_GPIO_POWER_OFF, "POWEROFF") != 0 ||
>  		    gpio_direction_output(DNS323_GPIO_POWER_OFF, 0) != 0)
>  			pr_err("DNS-323: failed to setup power-off GPIO\n");
> -		pm_power_off = dns323a_power_off;
> +		register_poweroff_handler_simple(dns323a_power_off, 128);
>  		break;
>  	case DNS323_REV_B1:
>  		/* 5182 built-in SATA init */
> @@ -686,7 +686,7 @@ static void __init dns323_init(void)
>  		if (gpio_request(DNS323_GPIO_POWER_OFF, "POWEROFF") != 0 ||
>  		    gpio_direction_output(DNS323_GPIO_POWER_OFF, 0) != 0)
>  			pr_err("DNS-323: failed to setup power-off GPIO\n");
> -		pm_power_off = dns323b_power_off;
> +		register_poweroff_handler_simple(dns323b_power_off, 128);
>  		break;
>  	case DNS323_REV_C1:
>  		/* 5182 built-in SATA init */
> @@ -696,7 +696,7 @@ static void __init dns323_init(void)
>  		if (gpio_request(DNS323C_GPIO_POWER_OFF, "POWEROFF") != 0 ||
>  		    gpio_direction_output(DNS323C_GPIO_POWER_OFF, 0) != 0)
>  			pr_err("DNS-323: failed to setup power-off GPIO\n");
> -		pm_power_off = dns323c_power_off;
> +		register_poweroff_handler_simple(dns323c_power_off, 128);
>  
>  		/* Now, -this- should theorically be done by the sata_mv driver
>  		 * once I figure out what's going on there. Maybe the behaviour
> diff --git a/arch/arm/mach-orion5x/kurobox_pro-setup.c b/arch/arm/mach-orion5x/kurobox_pro-setup.c
> index fe6a48a..c4101f1 100644
> --- a/arch/arm/mach-orion5x/kurobox_pro-setup.c
> +++ b/arch/arm/mach-orion5x/kurobox_pro-setup.c
> @@ -376,7 +376,7 @@ static void __init kurobox_pro_init(void)
>  	i2c_register_board_info(0, &kurobox_pro_i2c_rtc, 1);
>  
>  	/* register Kurobox Pro specific power-off method */
> -	pm_power_off = kurobox_pro_power_off;
> +	register_poweroff_handler_simple(kurobox_pro_power_off, 128);
>  }
>  
>  #ifdef CONFIG_MACH_KUROBOX_PRO
> diff --git a/arch/arm/mach-orion5x/ls-chl-setup.c b/arch/arm/mach-orion5x/ls-chl-setup.c
> index 028ea03..005bb04 100644
> --- a/arch/arm/mach-orion5x/ls-chl-setup.c
> +++ b/arch/arm/mach-orion5x/ls-chl-setup.c
> @@ -312,7 +312,7 @@ static void __init lschl_init(void)
>  	gpio_set_value(LSCHL_GPIO_USB_POWER, 1);
>  
>  	/* register power-off method */
> -	pm_power_off = lschl_power_off;
> +	register_poweroff_handler_simple(lschl_power_off, 0);
>  
>  	pr_info("%s: finished\n", __func__);
>  }
> diff --git a/arch/arm/mach-orion5x/ls_hgl-setup.c b/arch/arm/mach-orion5x/ls_hgl-setup.c
> index 32b7129..37c29a0 100644
> --- a/arch/arm/mach-orion5x/ls_hgl-setup.c
> +++ b/arch/arm/mach-orion5x/ls_hgl-setup.c
> @@ -259,7 +259,7 @@ static void __init ls_hgl_init(void)
>  	gpio_set_value(LS_HGL_GPIO_USB_POWER, 1);
>  
>  	/* register power-off method */
> -	pm_power_off = ls_hgl_power_off;
> +	register_poweroff_handler_simple(ls_hgl_power_off, 0);
>  
>  	pr_info("%s: finished\n", __func__);
>  }
> diff --git a/arch/arm/mach-orion5x/lsmini-setup.c b/arch/arm/mach-orion5x/lsmini-setup.c
> index a6493e7..ffec72f 100644
> --- a/arch/arm/mach-orion5x/lsmini-setup.c
> +++ b/arch/arm/mach-orion5x/lsmini-setup.c
> @@ -260,7 +260,7 @@ static void __init lsmini_init(void)
>  	gpio_set_value(LSMINI_GPIO_USB_POWER, 1);
>  
>  	/* register power-off method */
> -	pm_power_off = lsmini_power_off;
> +	register_poweroff_handler_simple(lsmini_power_off, 0);
>  
>  	pr_info("%s: finished\n", __func__);
>  }
> diff --git a/arch/arm/mach-orion5x/mv2120-setup.c b/arch/arm/mach-orion5x/mv2120-setup.c
> index e032f01..dadc2b9 100644
> --- a/arch/arm/mach-orion5x/mv2120-setup.c
> +++ b/arch/arm/mach-orion5x/mv2120-setup.c
> @@ -225,7 +225,7 @@ static void __init mv2120_init(void)
>  	if (gpio_request(MV2120_GPIO_POWER_OFF, "POWEROFF") != 0 ||
>  	    gpio_direction_output(MV2120_GPIO_POWER_OFF, 1) != 0)
>  		pr_err("mv2120: failed to setup power-off GPIO\n");
> -	pm_power_off = mv2120_power_off;
> +	register_poweroff_handler_simple(mv2120_power_off, 128);
>  }
>  
>  /* Warning: HP uses a wrong mach-type (R6) in their bootloader */
> diff --git a/arch/arm/mach-orion5x/net2big-setup.c b/arch/arm/mach-orion5x/net2big-setup.c
> index ba73dc7..3a73dce 100644
> --- a/arch/arm/mach-orion5x/net2big-setup.c
> +++ b/arch/arm/mach-orion5x/net2big-setup.c
> @@ -413,7 +413,7 @@ static void __init net2big_init(void)
>  
>  	if (gpio_request(NET2BIG_GPIO_POWER_OFF, "power-off") = 0 &&
>  	    gpio_direction_output(NET2BIG_GPIO_POWER_OFF, 0) = 0)
> -		pm_power_off = net2big_power_off;
> +		register_poweroff_handler_simple(net2big_power_off, 128);
>  	else
>  		pr_err("net2big: failed to configure power-off GPIO\n");
>  
> diff --git a/arch/arm/mach-orion5x/terastation_pro2-setup.c b/arch/arm/mach-orion5x/terastation_pro2-setup.c
> index 6208d12..2a234cb 100644
> --- a/arch/arm/mach-orion5x/terastation_pro2-setup.c
> +++ b/arch/arm/mach-orion5x/terastation_pro2-setup.c
> @@ -353,7 +353,7 @@ static void __init tsp2_init(void)
>  	i2c_register_board_info(0, &tsp2_i2c_rtc, 1);
>  
>  	/* register Terastation Pro II specific power-off method */
> -	pm_power_off = tsp2_power_off;
> +	register_poweroff_handler_simple(tsp2_power_off, 128);
>  }
>  
>  MACHINE_START(TERASTATION_PRO2, "Buffalo Terastation Pro II/Live")
> diff --git a/arch/arm/mach-orion5x/ts209-setup.c b/arch/arm/mach-orion5x/ts209-setup.c
> index 9136797..50bdfbc 100644
> --- a/arch/arm/mach-orion5x/ts209-setup.c
> +++ b/arch/arm/mach-orion5x/ts209-setup.c
> @@ -318,7 +318,7 @@ static void __init qnap_ts209_init(void)
>  	i2c_register_board_info(0, &qnap_ts209_i2c_rtc, 1);
>  
>  	/* register tsx09 specific power-off method */
> -	pm_power_off = qnap_tsx09_power_off;
> +	register_poweroff_handler_simple(qnap_tsx09_power_off, 128);
>  }
>  
>  MACHINE_START(TS209, "QNAP TS-109/TS-209")
> diff --git a/arch/arm/mach-orion5x/ts409-setup.c b/arch/arm/mach-orion5x/ts409-setup.c
> index 5c079d31..06a7cc0 100644
> --- a/arch/arm/mach-orion5x/ts409-setup.c
> +++ b/arch/arm/mach-orion5x/ts409-setup.c
> @@ -307,7 +307,7 @@ static void __init qnap_ts409_init(void)
>  	platform_device_register(&ts409_leds);
>  
>  	/* register tsx09 specific power-off method */
> -	pm_power_off = qnap_tsx09_power_off;
> +	register_poweroff_handler_simple(qnap_tsx09_power_off, 128);
>  }
>  
>  MACHINE_START(TS409, "QNAP TS-409")
> diff --git a/arch/arm/mach-pxa/corgi.c b/arch/arm/mach-pxa/corgi.c
> index 06022b2..a93bac0 100644
> --- a/arch/arm/mach-pxa/corgi.c
> +++ b/arch/arm/mach-pxa/corgi.c
> @@ -718,7 +718,7 @@ static void corgi_restart(enum reboot_mode mode, const char *cmd)
>  
>  static void __init corgi_init(void)
>  {
> -	pm_power_off = corgi_poweroff;
> +	register_poweroff_handler_simple(corgi_poweroff, 0);
>  
>  	/* Stop 3.6MHz and drive HIGH to PCMCIA and CS */
>  	PCFR |= PCFR_OPDE;
> diff --git a/arch/arm/mach-pxa/mioa701.c b/arch/arm/mach-pxa/mioa701.c
> index 29997bd..c4345a4 100644
> --- a/arch/arm/mach-pxa/mioa701.c
> +++ b/arch/arm/mach-pxa/mioa701.c
> @@ -750,7 +750,7 @@ static void __init mioa701_machine_init(void)
>  	pxa_set_keypad_info(&mioa701_keypad_info);
>  	pxa_set_udc_info(&mioa701_udc_info);
>  	pxa_set_ac97_info(&mioa701_ac97_info);
> -	pm_power_off = mioa701_poweroff;
> +	register_poweroff_handler_simple(mioa701_poweroff, 0);
>  	platform_add_devices(devices, ARRAY_SIZE(devices));
>  	gsm_init();
>  
> diff --git a/arch/arm/mach-pxa/poodle.c b/arch/arm/mach-pxa/poodle.c
> index 1319916..c9536ed 100644
> --- a/arch/arm/mach-pxa/poodle.c
> +++ b/arch/arm/mach-pxa/poodle.c
> @@ -432,7 +432,7 @@ static void __init poodle_init(void)
>  {
>  	int ret = 0;
>  
> -	pm_power_off = poodle_poweroff;
> +	register_poweroff_handler_simple(poodle_poweroff, 0);
>  
>  	PCFR |= PCFR_OPDE;
>  
> diff --git a/arch/arm/mach-pxa/spitz.c b/arch/arm/mach-pxa/spitz.c
> index 840c3a4..09f0de8 100644
> --- a/arch/arm/mach-pxa/spitz.c
> +++ b/arch/arm/mach-pxa/spitz.c
> @@ -944,7 +944,7 @@ static void spitz_restart(enum reboot_mode mode, const char *cmd)
>  static void __init spitz_init(void)
>  {
>  	init_gpio_reset(SPITZ_GPIO_ON_RESET, 1, 0);
> -	pm_power_off = spitz_poweroff;
> +	register_poweroff_handler_simple(spitz_poweroff, 0);
>  
>  	PMCR = 0x00;
>  
> diff --git a/arch/arm/mach-pxa/tosa.c b/arch/arm/mach-pxa/tosa.c
> index c158a6e..3a4af1d 100644
> --- a/arch/arm/mach-pxa/tosa.c
> +++ b/arch/arm/mach-pxa/tosa.c
> @@ -940,7 +940,7 @@ static void __init tosa_init(void)
>  
>  	init_gpio_reset(TOSA_GPIO_ON_RESET, 0, 0);
>  
> -	pm_power_off = tosa_poweroff;
> +	register_poweroff_handler_simple(tosa_poweroff, 0);
>  
>  	PCFR |= PCFR_OPDE;
>  
> diff --git a/arch/arm/mach-pxa/viper.c b/arch/arm/mach-pxa/viper.c
> index de3b080..679c8ea 100644
> --- a/arch/arm/mach-pxa/viper.c
> +++ b/arch/arm/mach-pxa/viper.c
> @@ -919,7 +919,7 @@ static void __init viper_init(void)
>  {
>  	u8 version;
>  
> -	pm_power_off = viper_power_off;
> +	register_poweroff_handler_simple(viper_power_off, 128);
>  
>  	pxa2xx_mfp_config(ARRAY_AND_SIZE(viper_pin_config));
>  
> diff --git a/arch/arm/mach-pxa/z2.c b/arch/arm/mach-pxa/z2.c
> index e1a121b..e0195ac 100644
> --- a/arch/arm/mach-pxa/z2.c
> +++ b/arch/arm/mach-pxa/z2.c
> @@ -693,8 +693,6 @@ static void z2_power_off(void)
>  	pxa27x_set_pwrmode(PWRMODE_DEEPSLEEP);
>  	pxa27x_cpu_pm_enter(PM_SUSPEND_MEM);
>  }
> -#else
> -#define z2_power_off   NULL
>  #endif
>  
>  /******************************************************************************
> @@ -719,7 +717,9 @@ static void __init z2_init(void)
>  	z2_keys_init();
>  	z2_pmic_init();
>  
> -	pm_power_off = z2_power_off;
> +#ifdef CONFIG_PM
> +	register_poweroff_handler_simple(z2_power_off, 0);
> +#endif
>  }
>  
>  MACHINE_START(ZIPIT2, "Zipit Z2")
> diff --git a/arch/arm/mach-pxa/zeus.c b/arch/arm/mach-pxa/zeus.c
> index 205f9bf..6118fd5 100644
> --- a/arch/arm/mach-pxa/zeus.c
> +++ b/arch/arm/mach-pxa/zeus.c
> @@ -690,8 +690,6 @@ static void zeus_power_off(void)
>  	local_irq_disable();
>  	cpu_suspend(PWRMODE_DEEPSLEEP, pxa27x_finish_suspend);
>  }
> -#else
> -#define zeus_power_off   NULL
>  #endif
>  
>  #ifdef CONFIG_APM_EMULATION
> @@ -847,7 +845,9 @@ static void __init zeus_init(void)
>  	__raw_writel(msc0, MSC0);
>  	__raw_writel(msc1, MSC1);
>  
> -	pm_power_off = zeus_power_off;
> +#ifdef CONFIG_PM
> +	register_poweroff_handler_simple(zeus_power_off, 0);
> +#endif
>  	zeus_setup_apm();
>  
>  	pxa2xx_mfp_config(ARRAY_AND_SIZE(zeus_pin_config));
> diff --git a/arch/arm/mach-s3c24xx/mach-gta02.c b/arch/arm/mach-s3c24xx/mach-gta02.c
> index fc3a08d..ca78150 100644
> --- a/arch/arm/mach-s3c24xx/mach-gta02.c
> +++ b/arch/arm/mach-s3c24xx/mach-gta02.c
> @@ -579,7 +579,7 @@ static void __init gta02_machine_init(void)
>  	i2c_register_board_info(0, gta02_i2c_devs, ARRAY_SIZE(gta02_i2c_devs));
>  
>  	platform_add_devices(gta02_devices, ARRAY_SIZE(gta02_devices));
> -	pm_power_off = gta02_poweroff;
> +	register_poweroff_handler_simple(gta02_poweroff, 128);
>  
>  	regulator_has_full_constraints();
>  }
> diff --git a/arch/arm/mach-s3c24xx/mach-jive.c b/arch/arm/mach-s3c24xx/mach-jive.c
> index 7804d3c..5a828a3 100644
> --- a/arch/arm/mach-s3c24xx/mach-jive.c
> +++ b/arch/arm/mach-s3c24xx/mach-jive.c
> @@ -657,7 +657,7 @@ static void __init jive_machine_init(void)
>  	s3c_i2c0_set_platdata(&jive_i2c_cfg);
>  	i2c_register_board_info(0, jive_i2c_devs, ARRAY_SIZE(jive_i2c_devs));
>  
> -	pm_power_off = jive_power_off;
> +	register_poweroff_handler_simple(jive_power_off, 128);
>  
>  	platform_add_devices(jive_devices, ARRAY_SIZE(jive_devices));
>  }
> diff --git a/arch/arm/mach-s3c24xx/mach-vr1000.c b/arch/arm/mach-s3c24xx/mach-vr1000.c
> index f88c584..40d7655 100644
> --- a/arch/arm/mach-s3c24xx/mach-vr1000.c
> +++ b/arch/arm/mach-s3c24xx/mach-vr1000.c
> @@ -306,7 +306,7 @@ static void vr1000_power_off(void)
>  
>  static void __init vr1000_map_io(void)
>  {
> -	pm_power_off = vr1000_power_off;
> +	register_poweroff_handler_simple(vr1000_power_off, 128);
>  
>  	s3c24xx_init_io(vr1000_iodesc, ARRAY_SIZE(vr1000_iodesc));
>  	s3c24xx_init_uarts(vr1000_uartcfgs, ARRAY_SIZE(vr1000_uartcfgs));
> diff --git a/arch/arm/mach-s3c64xx/mach-smartq.c b/arch/arm/mach-s3c64xx/mach-smartq.c
> index b3d1353..61f0893 100644
> --- a/arch/arm/mach-s3c64xx/mach-smartq.c
> +++ b/arch/arm/mach-s3c64xx/mach-smartq.c
> @@ -291,7 +291,7 @@ static int __init smartq_power_off_init(void)
>  	/* leave power on */
>  	gpio_direction_output(S3C64XX_GPK(15), 0);
>  
> -	pm_power_off = smartq_power_off;
> +	register_poweroff_handler_simple(smartq_power_off, 128);
>  
>  	return ret;
>  }
> diff --git a/arch/arm/mach-sa1100/generic.c b/arch/arm/mach-sa1100/generic.c
> index d4ea142..6b839cf 100644
> --- a/arch/arm/mach-sa1100/generic.c
> +++ b/arch/arm/mach-sa1100/generic.c
> @@ -311,7 +311,7 @@ static struct platform_device *sa11x0_devices[] __initdata = {
>  
>  static int __init sa1100_init(void)
>  {
> -	pm_power_off = sa1100_power_off;
> +	register_poweroff_handler_simple(sa1100_power_off, 0);
>  	return platform_add_devices(sa11x0_devices, ARRAY_SIZE(sa11x0_devices));
>  }
>  
> diff --git a/arch/arm/mach-sa1100/simpad.c b/arch/arm/mach-sa1100/simpad.c
> index 41e476e..a65ca58 100644
> --- a/arch/arm/mach-sa1100/simpad.c
> +++ b/arch/arm/mach-sa1100/simpad.c
> @@ -373,7 +373,7 @@ static int __init simpad_init(void)
>  	if (ret)
>  		printk(KERN_WARNING "simpad: Unable to register cs3 GPIO device");
>  
> -	pm_power_off = simpad_power_off;
> +	register_poweroff_handler_simple(simpad_power_off, 0);
>  
>  	sa11x0_ppc_configure_mcp();
>  	sa11x0_register_mtd(&simpad_flash_data, simpad_flash_resources,
> diff --git a/arch/arm/mach-u300/regulator.c b/arch/arm/mach-u300/regulator.c
> index 0493a84..c98eb6e 100644
> --- a/arch/arm/mach-u300/regulator.c
> +++ b/arch/arm/mach-u300/regulator.c
> @@ -98,7 +98,7 @@ static int __init __u300_init_boardpower(struct platform_device *pdev)
>  			   U300_SYSCON_PMCR_DCON_ENABLE, 0);
>  
>  	/* Register globally exported PM poweroff hook */
> -	pm_power_off = u300_pm_poweroff;
> +	register_poweroff_handler_simple(u300_pm_poweroff, 128);
>  
>  	return 0;
>  }
> diff --git a/arch/arm/mach-vt8500/vt8500.c b/arch/arm/mach-vt8500/vt8500.c
> index 2da7be3..515946b 100644
> --- a/arch/arm/mach-vt8500/vt8500.c
> +++ b/arch/arm/mach-vt8500/vt8500.c
> @@ -155,7 +155,7 @@ static void __init vt8500_init(void)
>  			pr_err("%s:ioremap(power_off) failed\n", __func__);
>  	}
>  	if (pmc_base)
> -		pm_power_off = &vt8500_power_off;
> +		register_poweroff_handler_simple(vt8500_power_off, 0);
>  	else
>  		pr_err("%s: PMC Hibernation register could not be remapped, not enabling power off!\n", __func__);
>  
> diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
> index 0e15f01..0da639b 100644
> --- a/arch/arm/xen/enlighten.c
> +++ b/arch/arm/xen/enlighten.c
> @@ -336,7 +336,7 @@ static int __init xen_pm_init(void)
>  	if (!xen_domain())
>  		return -ENODEV;
>  
> -	pm_power_off = xen_power_off;
> +	register_poweroff_handler_simple(xen_power_off, 128);
>  	arm_pm_restart = xen_restart;
>  
>  	return 0;
> 


-- 
Nicolas Ferre
