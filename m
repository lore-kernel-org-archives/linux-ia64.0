From: grundler@cup.hp.com (Grant Grundler)
Date: Thu, 13 Feb 2003 19:17:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805842@msgid-missing>
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

*sigh*. Next problem is cpqfc driver doesn't build.
I'll disable that too since I don't really need it.

I'd really like to take a whack at the IDE problem you reported
2 weeks ago instead of chasing misc build failures.
Do you have a .config available that builds/works on HP ZX1 platforms?
(well, obviously not on the ZX2000 you reported problems with)
Maybe drop that on kernel.org as linux-2.5.60-ia64-030212.config ?


  gcc -Wp,-MD,drivers/scsi/.cpqfcTSinit.o.d -D__KERNEL__ -Iinclude -Wall -W=
strict-prototypes -Wno-trigraphs -g -O2 -fno-strict-aliasing -fno-common -p=
ipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -falign-functions2 -frename=
-registers --param max-inline-insnsP00 -fomit-frame-pointer -nostdinc -iwit=
hprefix include -mconstant-gp   -DKBUILD_BASENAME=3DcpqfcTSinit -DKBUILD_MO=
DNAME=3Dcpqfc -c -o drivers/scsi/cpqfcTSinit.o drivers/scsi/cpqfcTSinit.c
drivers/scsi/cpqfcTSinit.c: In function `cpqfcTS_proc_info':
drivers/scsi/cpqfcTSinit.c:968: structure has no member named `channel'
drivers/scsi/cpqfcTSinit.c:970: structure has no member named `target'
drivers/scsi/cpqfcTSinit.c: In function `cpqfcTS_TargetDeviceReset':
drivers/scsi/cpqfcTSinit.c:1615: warning: implicit declaration of function =
`scsi_do_cmd'
make[2]: *** [drivers/scsi/cpqfcTSinit.o] Error 1
make[1]: *** [drivers/scsi] Error 2
make: *** [drivers] Error 2

grant

