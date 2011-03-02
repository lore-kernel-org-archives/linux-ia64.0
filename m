From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
Date: Wed, 02 Mar 2011 20:48:03 +0000
Subject: about MISC_DEVICES not being enabled in many defconfigs
Message-Id: <20110302204803.GI22310@pengutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-arm-kernel@lists.infradead.org

Hello,

while working on an defconfig (arm/mx27) I noticed that just updating
it[1] results in removing CONFIG_EEPROM_AT24=3Dy.  The reason is that
since commit

	v2.6.36-5965-g5f2365d (misc devices: do not enable by default)

MISC_DEVICES isn't enabled anymore by default.  So all defconfigs that
have CONFIG_SOME_SYMBOL=3Dy (or =3Dm) (with SOME_SYMBOL depending on
MISC_DEVICES) but not CONFIG_MISC_DEVICES=3Dy suffer from the same
problem.

As a defconfig that was reduced before 5f2365d obviously didn't have
CONFIG_MISC_DEVICES=3Dy many defconfigs have that problem.

I did the following to (hopefully) find all affected defconfigs:

	$ git describe
	v2.6.38-rc7
	$ git ls-files drivers/misc | grep Kconfig | xargs grep -h ^config | sed '=
s/config \(.*\)/CONFIG_\1=3D/' > miscsymbols
	$ git ls-files *defconfig | xargs grep -L CONFIG_MISC_DEVICES=3D | xargs g=
rep -F -f miscsymbols
	arch/arm/configs/afeb9260_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/afeb9260_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/at572d940hfek_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/arm/configs/at572d940hfek_defconfig:CONFIG_ATMEL_SSC=3Dm
	arch/arm/configs/at572d940hfek_defconfig:CONFIG_SENSORS_TSL2550=3Dm
	arch/arm/configs/at572d940hfek_defconfig:CONFIG_DS1682=3Dm
	arch/arm/configs/at91cap9adk_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/at91rm9200_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/arm/configs/at91rm9200_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/arm/configs/at91sam9260ek_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/at91sam9261ek_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/at91sam9263ek_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/at91sam9g20ek_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/at91sam9rlek_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/arm/configs/da8xx_omapl_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/davinci_all_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/ep93xx_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/arm/configs/ixp2000_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/arm/configs/ixp23xx_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/arm/configs/ixp4xx_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/arm/configs/mini2440_defconfig:CONFIG_SENSORS_TSL2550=3Dm
	arch/arm/configs/mx27_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/mx3_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/neocore926_defconfig:CONFIG_ATMEL_PWM=3Dy
	arch/arm/configs/neocore926_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/arm/configs/omap2plus_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/arm/configs/pcontrol_g20_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/arm/configs/pcontrol_g20_defconfig:CONFIG_EEPROM_AT24=3Dm
	arch/arm/configs/pnx4008_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/arm/configs/raumfeld_defconfig:CONFIG_ISL29003=3Dy
	arch/arm/configs/raumfeld_defconfig:CONFIG_TI_DAC7512=3Dy
	arch/arm/configs/realview-smp_defconfig:CONFIG_ARM_CHARLCD=3Dy
	arch/arm/configs/realview_defconfig:CONFIG_ARM_CHARLCD=3Dy
	arch/arm/configs/s3c2410_defconfig:CONFIG_EEPROM_AT25=3Dm
	arch/arm/configs/s3c2410_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/arm/configs/s3c2410_defconfig:CONFIG_EEPROM_93CX6=3Dm
	arch/arm/configs/s3c6400_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/s5pc100_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/arm/configs/versatile_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/arm/configs/zeus_defconfig:CONFIG_EEPROM_AT24=3Dm
	arch/avr32/configs/atngw100_mrmt_defconfig:CONFIG_ATMEL_PWM=3Dy
	arch/avr32/configs/favr-32_defconfig:CONFIG_ATMEL_PWM=3Dm
	arch/avr32/configs/favr-32_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/avr32/configs/favr-32_defconfig:CONFIG_ATMEL_SSC=3Dm
	arch/avr32/configs/hammerhead_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/avr32/configs/merisc_defconfig:CONFIG_ATMEL_PWM=3Dy
	arch/avr32/configs/merisc_defconfig:CONFIG_ATMEL_SSC=3Dy
	arch/avr32/configs/mimc200_defconfig:CONFIG_ATMEL_TCLIB=3Dy
	arch/avr32/configs/mimc200_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/avr32/configs/mimc200_defconfig:CONFIG_EEPROM_AT25=3Dy
	arch/blackfin/configs/BlackStamp_defconfig:CONFIG_EEPROM_AT25=3Dy
	arch/blackfin/configs/H8606_defconfig:CONFIG_EEPROM_AT25=3Dy
	arch/blackfin/configs/SRV1_defconfig:CONFIG_EEPROM_AT25=3Dm
	arch/ia64/configs/generic_defconfig:CONFIG_SGI_IOC4=3Dy
	arch/ia64/configs/generic_defconfig:CONFIG_SGI_XP=3Dm
	arch/ia64/configs/gensparse_defconfig:CONFIG_SGI_IOC4=3Dy
	arch/mips/configs/bigsur_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/bigsur_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/mips/configs/bigsur_defconfig:CONFIG_EEPROM_MAX6875=3Dy
	arch/mips/configs/gpr_defconfig:CONFIG_TIFM_CORE=3Dm
	arch/mips/configs/ip32_defconfig:CONFIG_SGI_IOC4=3Dy
	arch/mips/configs/markeins_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/pnx8550-jbs_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/rm200_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/sb1250-swarm_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/wrppmc_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/mips/configs/yosemite_defconfig:CONFIG_SGI_IOC4=3Dm
	arch/powerpc/configs/44x/warp_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/powerpc/configs/52xx/motionpro_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/86xx/gef_ppc9a_defconfig:CONFIG_DS1682=3Dy
	arch/powerpc/configs/86xx/gef_sbc310_defconfig:CONFIG_DS1682=3Dy
	arch/powerpc/configs/86xx/gef_sbc610_defconfig:CONFIG_DS1682=3Dy
	arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/e55xx_smp_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/linkstation_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/powerpc/configs/mpc512x_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/powerpc/configs/mpc5200_defconfig:CONFIG_EEPROM_AT24=3Dy
	arch/powerpc/configs/mpc85xx_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/mpc85xx_smp_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/mpc86xx_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/pasemi_defconfig:CONFIG_EEPROM_LEGACY=3Dy
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_ENCLOSURE_SERVICES=3Dm
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_SENSORS_TSL2550=3Dm
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_EEPROM_AT24=3Dm
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_EEPROM_LEGACY=3Dm
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_EEPROM_MAX6875=3Dm
	arch/powerpc/configs/ppc6xx_defconfig:CONFIG_EEPROM_93CX6=3Dm
	arch/sh/configs/se7206_defconfig:CONFIG_EEPROM_93CX6=3Dy

(For those wondering about the commands above: A line=20

	arch/$arch/configs/xyz_defconfig:CONFIG_SOME_DEVICE=3Dy

means here, that running

	make ARCH=3D$arch xyz_defconfig

results in a config without SOME_DEVICE.

I don't know if that bothers you, but if it does, you should add

	CONFIG_MISC_DEVICES=3Dy

to your defconfig.

Just to let you know ...

Best regards
Uwe

[1] make mx27_defconfig
    make savedefconfig
    mv defconfig arch/arm/configs/mx27_defconfig

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
