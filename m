From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 06 Mar 2007 02:10:58 +0000
Subject: RE: Crash Dump Region
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086C01@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306015655.GA27129@verge.net.au>
In-Reply-To: <20070306015655.GA27129@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2007=C4=EA3=D4=C26=C8=D5 9:57
> To: Zou, Nanhai
> Cc: Linux-IA64; fastboot
> Subject: Crash Dump Region
>=20
> Hi,
>=20
> I am currently looking over the code that places the crashdump
> region into /proc/iomem, and the code that determines its base
> address if it is not passed on the kernel comamnd. It seems to me that
> the current code allows the crashkernel to be placed incide a
> /proc/iomem region of any type. Is this behaviour correct?
> If not, should it be restricted to "System RAM" regions?
>=20
 I not sure if I understand your question.
 Kernel will find a big enough region inside efi memmap with WB attribute, =
excluding all the other reserved regions.

 Zou Nanhai.

> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
