From: Matthew Wilcox <willy@debian.org>
Date: Tue, 20 Aug 2002 11:11:23 +0000
Subject: Re: [Linux-ia64] Kernel dumps stacks while calling exported function from a loadable module
Message-Id: <marc-linux-ia64-105590701905957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905956@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905956@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Aug 20, 2002 at 05:52:32PM +0800, Jeff Lee wrote:
> I am having trouble in calling exported functions on my RH 7.2 box.
> running 2.4.9-18 kernel.  The calling module causes kernel stack dumps

My understanding is that this kernel was compiled with gcc 2.96 ...

> The compilation line looks like this:
>=20
> /opt/gcc3.1/bin/gcc -c -DLINUX -D__SMP__ -D"__BOOT_KERNEL_SMP=3D1"
> -D"__BOOT_KERNEL_UP=3D0"  -O2 -Wall -Wstrict-prototypes  -D__ia64__ -D_LP=
64
> -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -falign-functions2
> -fno-common -Wno-unused -mb-step -I -I/usr/src/linux-2.4/drivers/scsi -I
> -I/scsi  -I/usr/src/linux-2.4/drivers/scsi -DMODULE -DMODVERSIONS -include
> /usr/src/linux-2.4/include/linux/modversions.h-D__KERNEL__  myhello1.c

... and you're using gcc 3.1, so maybe this compiler mismatch is causing
the problem?

--=20
Revolutions do not require corporate support.

