From: Eva Hocks <hocks@SDSC.EDU>
Date: Tue, 17 Sep 2002 21:33:31 +0000
Subject: [Linux-ia64] 2.4.19 ACPI build errors
Message-Id: <marc-linux-ia64-105590701906033@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


The kernel build on Itanium with 2.4.29 and the linux-2.4.19-ia64-020821
patches get the following compile error:


gcc3 -D__KERNEL__ -I/usr/src/linux-2.4.19/include -Wall
-Wstrict-prototypes -Wno-trigraphs -g -O2 -fno-strict-aliasing -fno-common
-fomit-frame-pointer -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127
-falign-functions2 -frename-registers --param max-inline-insnsP00
-mb-step -mconstant-gp  -nostdinc -I
/usr/lib/gcc-lib/ia64-redhat-linux/3.0.1/include -DKBUILD_BASENAME=3Diosapic
-c -o iosapic.o iosapic.c
iosapic.c: In function `iosapic_register_platform_intr':
iosapic.c:529: `ACPI_INTERRUPT_PMI' undeclared (first use in this function)
iosapic.c:529: (Each undeclared identifier is reported only once
iosapic.c:529: for each function it appears in.)
iosapic.c:538: `ACPI_INTERRUPT_INIT' undeclared (first use in this function)
iosapic.c:542: `ACPI_INTERRUPT_CPEI' undeclared (first use in this function)
make[1]: *** [iosapic.o] Error 1
make[1]: Leaving directory `/usr/src/linux-2.4.19/arch/ia64/kernel'
make: *** [_dir_arch/ia64/kernel] Error 2


The config looks like:
CONFIG_ACPI20=3Dy
CONFIG_ACPI_KERNEL_CONFIG=3Dy
CONFIG_ACPI=3Dy
CONFIG_ACPI_INTERPRETER=3Dy


Any hints to get the kernel compiled?
Thanks,Eva



