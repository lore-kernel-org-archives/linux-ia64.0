From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 06 Apr 2001 17:24:01 +0000
Subject: Re: [Linux-ia64] 2.4.3 ACPI build errors
Message-Id: <marc-linux-ia64-105590693005379@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 6 Apr 2001 11:53:50 -0400 (EDT), "Michael F. Brown" <mbrown@e=
mc.com> said:

  Mike> Hello, I'm trying to build the 2.4.3 kernel after applying the
  Mike> 2.4.3 ia64 patch.  I see the following build errors:

  Mike> gcc -D__KERNEL__ -I/usr/src/linux-2.4.3/include -Wall
  Mike> -Wstrict-prototypes -g -O2 -fomit-frame-pointer
  Mike> -fno-strict-aliasing -pipe -Wa,-x -ffixed-r13
  Mike> -mfixed-range=F10-f15,f32-f127 -funwind-tables
  Mike> -falign-functions2 -mb-step -mconstant-gp -c -o iosapic.o
  Mike> iosapic.c iosapic.c: In function `iosapic_init':
  Mike> iosapic.c:355: structure has no member named `pci_vectors'
  Mike> iosapic.c:356: structure has no member named `num_pci_vectors'
  Mike> make[1]: *** [iosapic.o] Error 1 make[1]: Leaving directory
  Mike> `/usr/src/linux-2.4.3/arch/ia64/kernel' make: ***
  Mike> [_dir_arch/ia64/kernel] Error 2

Ah, yes, you *must* turn on CONFIG_ACPI_KERNEL_CONFIG as the new
bootloader no longer has ACPI built in (actually, I thought that had
been removed a while ago).

Thanks for pointing this out.  I will clean away this configuration
option in the patch.

  Mike> So to work around this, I've tried setting
  Mike> CONFIG_ACPI_KERNEL_CONFIG.  Using make xconfig, this option is
  Mike> greyed out or disabled.

If you selected the "DIG" platform, the option should be active.  You
could try "make menuconfig" as well.

  Mike> So I tried manually adding:

  Mike> CONFIG_ACPI20=3Dy CONFIG_ACPI_KERNEL_CONFIG=3Dy

That doesn't work.

	--david

