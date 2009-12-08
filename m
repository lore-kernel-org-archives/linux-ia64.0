From: Luming Yu <luming.yu@gmail.com>
Date: Tue, 08 Dec 2009 12:25:44 +0000
Subject: Re: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <3877989d0912080425o4bf9e2beuf573e47930fd707f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
	 <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
	 <4BDB13256095B24D9644F65379E604265C12@orsmsx505.amr.corp.intel.com>
	 <3877989d0912041919i458300d7ydce73cf77979dad3@mail.gmail.com>
	 <3877989d0912062156v7ba2a192y726f45b550ba50e@mail.gmail.com>
	 <12c511ca0912071335i1a805c2eudb6ecb8f726f6a80@mail.gmail.com>
In-Reply-To: <12c511ca0912071335i1a805c2eudb6ecb8f726f6a80@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Felix Blyakher <felixb@sgi.com>, "Li, Shaohua" <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

On Tue, Dec 8, 2009 at 5:35 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> please check out the attached config.
>
> Your config fails for me too (same way, blank screen, nothing on
> serial console).
>
> Essentially I applied your patch to 2.6.32 (patch only gave a few
> "offset" warnings).   Kernel
> builds ok, and boots on tiger (using tiger_defconfig).
>
> When I turned on some LOCKDEP bits (see attached config) it fails.
> Nothing on the
> early uart console to say why.  Screen just blanks right away.

Hmm, I changed the bad config a bit as below.
Nothing seems to be lockdep releated.

And the resutling 2.6.31 with LOCKDEP bits enabled still
can boot on my system.

But let me try more on other ia64 boxes that I can get access.

Stay tuned.

[root@localhost linux-2.6.31]# diff ../bad.lockdep.config good.config
3,4c3,4
< # Linux kernel version: 2.6.32
< # Mon Dec  7 11:05:28 2009
---
> # Linux kernel version: 2.6.31
> # Tue Dec  8 05:41:56 2009
28a29
> # CONFIG_CLASSIC_RCU is not set
30c31
< # CONFIG_TREE_PREEMPT_RCU is not set
---
> # CONFIG_PREEMPT_RCU is not set
34a36
> # CONFIG_PREEMPT_RCU_TRACE is not set
77c79
< # Kernel Performance Events And Counters
---
> # Performance Counters
81a84
> # CONFIG_STRIP_ASM_SYMS is not set
86a90
> # CONFIG_MARKERS is not set
99c103
< CONFIG_SLOW_WORK=y
---
> # CONFIG_SLOW_WORK is not set
139d142
< # CONFIG_GENERIC_LOCKBREAK is not set
146d148
< CONFIG_HAVE_LEGACY_PER_CPU_AREA=y
212d213
< # CONFIG_KSM is not set
222d222
< CONFIG_ARCH_PROC_KCORE_TEXT=y
251d250
< # CONFIG_PM_RUNTIME is not set
255d253
< # CONFIG_ACPI_POWER_METER is not set
260c258
< # CONFIG_ACPI_DOCK is not set
---
> CONFIG_ACPI_DOCK=y
339d336
< # CONFIG_RDS is not set
369d365
< CONFIG_CFG80211_DEFAULT_PS_VALUE=0
376a373
> CONFIG_MAC80211_DEFAULT_PS_VALUE=0
389d385
< # CONFIG_DEVTMPFS is not set
544d539
< # CONFIG_BE2ISCSI is not set
575a571
> # CONFIG_SCSI_IPR is not set
583d578
< # CONFIG_SCSI_PMCRAID is not set
585d579
< # CONFIG_SCSI_BFA_FC is not set
588c582,642
< # CONFIG_ATA is not set
---
> CONFIG_ATA=m
> CONFIG_ATA_NONSTANDARD=y
> CONFIG_ATA_ACPI=y
> CONFIG_SATA_PMP=y
> # CONFIG_SATA_AHCI is not set
> # CONFIG_SATA_SIL24 is not set
> CONFIG_ATA_SFF=y
> # CONFIG_SATA_SVW is not set
> CONFIG_ATA_PIIX=m
> # CONFIG_SATA_MV is not set
> # CONFIG_SATA_NV is not set
> # CONFIG_PDC_ADMA is not set
> # CONFIG_SATA_QSTOR is not set
> # CONFIG_SATA_PROMISE is not set
> # CONFIG_SATA_SX4 is not set
> # CONFIG_SATA_SIL is not set
> # CONFIG_SATA_SIS is not set
> # CONFIG_SATA_ULI is not set
> # CONFIG_SATA_VIA is not set
> # CONFIG_SATA_VITESSE is not set
> # CONFIG_SATA_INIC162X is not set
> # CONFIG_PATA_ACPI is not set
> # CONFIG_PATA_ALI is not set
> # CONFIG_PATA_AMD is not set
> # CONFIG_PATA_ARTOP is not set
> # CONFIG_PATA_ATIIXP is not set
> # CONFIG_PATA_CMD640_PCI is not set
> # CONFIG_PATA_CMD64X is not set
> # CONFIG_PATA_CS5520 is not set
> # CONFIG_PATA_CS5530 is not set
> # CONFIG_PATA_CYPRESS is not set
> # CONFIG_PATA_EFAR is not set
> # CONFIG_ATA_GENERIC is not set
> # CONFIG_PATA_HPT366 is not set
> # CONFIG_PATA_HPT37X is not set
> # CONFIG_PATA_HPT3X2N is not set
> # CONFIG_PATA_HPT3X3 is not set
> # CONFIG_PATA_IT821X is not set
> # CONFIG_PATA_IT8213 is not set
> # CONFIG_PATA_JMICRON is not set
> # CONFIG_PATA_TRIFLEX is not set
> # CONFIG_PATA_MARVELL is not set
> # CONFIG_PATA_MPIIX is not set
> # CONFIG_PATA_OLDPIIX is not set
> # CONFIG_PATA_NETCELL is not set
> # CONFIG_PATA_NINJA32 is not set
> # CONFIG_PATA_NS87410 is not set
> # CONFIG_PATA_NS87415 is not set
> # CONFIG_PATA_OPTI is not set
> # CONFIG_PATA_OPTIDMA is not set
> # CONFIG_PATA_PDC_OLD is not set
> # CONFIG_PATA_RADISYS is not set
> # CONFIG_PATA_RZ1000 is not set
> # CONFIG_PATA_SC1200 is not set
> # CONFIG_PATA_SERVERWORKS is not set
> # CONFIG_PATA_PDC2027X is not set
> # CONFIG_PATA_SIL680 is not set
> # CONFIG_PATA_SIS is not set
> # CONFIG_PATA_VIA is not set
> # CONFIG_PATA_WINBOND is not set
> # CONFIG_PATA_SCH is not set
704d757
< # CONFIG_KS8851_MLL is not set
714c767
< # CONFIG_IGB is not set
---
> CONFIG_IGB=m
752c805,808
< CONFIG_WLAN=y
---
>
> #
> # Wireless LAN
> #
804d859
< # CONFIG_KEYBOARD_ADP5588 is not set
806d860
< # CONFIG_QT2160 is not set
808d861
< # CONFIG_KEYBOARD_MAX7359 is not set
810d862
< # CONFIG_KEYBOARD_OPENCORES is not set
821d872
< # CONFIG_MOUSE_PS2_SENTELIC is not set
869a921,922
> # CONFIG_SX is not set
> # CONFIG_RIO is not set
911d963
< CONFIG_I2C_COMPAT=y
939,943d990
< # ACPI drivers
< #
< # CONFIG_I2C_SCMI is not set
<
< #
970a1018,1020
> # CONFIG_SENSORS_PCF8574 is not set
> # CONFIG_PCF8575 is not set
> # CONFIG_SENSORS_PCA9539 is not set
992,996d1041
< # CONFIG_HWMON_DEBUG_CHIP is not set
<
< #
< # Native drivers
< #
1046d1090
< # CONFIG_SENSORS_TMP421 is not set
1058,1061d1101
<
< #
< # ACPI drivers
< #
1062a1103
> # CONFIG_HWMON_DEBUG_CHIP is not set
1081d1121
< # CONFIG_MFD_WM831X is not set
1093d1132
< CONFIG_VGA_ARB=y
1095,1096d1133
< CONFIG_DRM_KMS_HELPER=m
< CONFIG_DRM_TTM=m
1177a1215
> CONFIG_HID_DEBUG=y
1201d1238
< CONFIG_HID_TWINHAN=y
1255d1291
< # CONFIG_USB_ISP1362_HCD is not set
1386d1421
< # CONFIG_NILFS2_FS is not set
1453a1489
> # CONFIG_NILFS2_FS is not set
1556d1591
< # CONFIG_STRIP_ASM_SYMS is not set
1595d1629
< # CONFIG_DEBUG_CREDENTIALS is not set
1602d1635
< # CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
1646c1679
< # CONFIG_CRYPTO_FIPS is not set
---
> CONFIG_CRYPTO_FIPS=y
1689d1721
< # CONFIG_CRYPTO_VMAC is not set
1695d1726
< # CONFIG_CRYPTO_GHASH is not set
1741a1773
> CONFIG_HAVE_KVM_IRQCHIP=y
