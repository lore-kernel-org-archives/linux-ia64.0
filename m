From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 18 Feb 2003 19:52:40 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Feb 12, 2003 at 03:26:10PM -0800, David Mosberger wrote:
> An updated ia64 patch is now at:
>=20
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/linux-2.5.60-ia64-=
030212.diff.gz

Thanks for the update.  Here's an error I got when trying to build it
for my Bug Sur machine:

  gcc -Wp,-MD,drivers/char/agp/.i460-agp.o.d -D__KERNEL__ -Iinclude -Wall -=
Wstrict-prototypes -Wno-trigraphs -g -O2 -fno-strict-aliasing -fno-common -=
pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -falign-functions2 -frenam=
e-registers --param max-inline-insnsP00 -fomit-frame-pointer -nostdinc -iwi=
thprefix include -mconstant-gp   -DKBUILD_BASENAME=3Di460_agp -DKBUILD_MODN=
AME=3Di460_agp -c -o drivers/char/agp/i460-agp.o drivers/char/agp/i460-agp.c
drivers/char/agp/i460-agp.c:563: parse error before ';' token
make[3]: *** [drivers/char/agp/i460-agp.o] Error 1
make[2]: *** [drivers/char/agp] Error 2
make[1]: *** [drivers/char] Error 2
make: *** [drivers] Error 2

Seems that an extra ';' got into the structure initialization,
probably during conversion to C99 syle.  The following patch gets me
to this link error:

        ld  -static -T arch/ia64/vmlinux.lds.s arch/ia64/kernel/head.o arch=
/ia64/kernel/init_task.o   init/built-in.o --start-group  usr/built-in.o  a=
rch/ia64/kernel/built-in.o  arch/ia64/mm/built-in.o  arch/ia64/ia32/built-i=
n.o  arch/ia64/dig/built-in.o  kernel/built-in.o  mm/built-in.o  fs/built-i=
n.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o  lib/lib.a  arc=
h/ia64/lib/lib.a  drivers/built-in.o  sound/built-in.o  arch/ia64/pci/built=
-in.o  net/built-in.o --end-group  -o vmlinux
drivers/built-in.o(.text+0xa51f1): In function `agp_return_size':
: undefined reference to `.L111'
drivers/built-in.o(.text+0xa52d1): In function `agp_num_entries':
: undefined reference to `.L121'
make: *** [vmlinux] Error 1

Thanks,
Jesse


--- linux-2.5.60-ia64/drivers/char/agp/i460-agp.c.orig  2003-02-13 10:28:40=
.000000000 -0800
+++ linux-2.5.60-ia64/drivers/char/agp/i460-agp.c       2003-02-13 10:23:04=
.000000000 -0800
@@ -560,7 +560,7 @@
 }

 static struct agp_driver i460_agp_driver =3D {
-       .owner =3D THIS_MODULE;
+       .owner =3D THIS_MODULE
 };

 static int __init agp_intel_i460_probe (struct pci_dev *dev, const struct =
pci_device_id *ent)

