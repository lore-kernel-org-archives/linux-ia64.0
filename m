From: Steffen Persvold <sp@scali.com>
Date: Sat, 22 Jun 2002 10:05:50 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, 22 Jun 2002, David Mosberger wrote:

> The latest ia64 kernel patch for 2.4.18 is at
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:
>=20
> 	linux-2.4.18-ia64-020622.diff.gz
>=20
> There are some important bug fixes in this patch:
>=20
> 	- munmap near end of per-region mappable address space no
> 	  longer causes virtual memory corruption
> 	- the kernel used to inherit all PSR bits across fork/exec,
> 	  which is a Bad Thing; this has been fixed
>=20

Hi David,

Have you tried CONFIG_IA64_GENERIC=3Dy ? This is what I get :

gcc -D__KERNEL__ -I/usr/src/linux-2.4.18-020622/include -Wall=20
-Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer=20
-fno-strict-aliasing -fno-common -pipe  -ffixed-r13=20
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -mconstant-gp=20
-D__KERNEL__ -I/usr/src/linux-2.4.18-020622/include  -c -o bootloader.o=20
bootloader.c
In file included from bootloader.c:54:
../kernel/fw-emu.c:246:9: #error Not implemented yet...
../kernel/fw-emu.c:257:9: #error Not implemented yet...
bootloader.c: In function `cons_write':
bootloader.c:62: warning: implicit declaration of function `ssc'
make[1]: *** [bootloader.o] Error 1
make[1]: Leaving directory `/usr/src/linux-2.4.18-020622/arch/ia64/boot'
make: *** [boot] Error 2


Seems to be related to efi_get_time() and efi_reset_system() for all other =

platforms than CONFIG_IA64_HP_SIM. Is this intended ?

=20
Regards,=20
--=20
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementati=
on:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS laten=
cy


