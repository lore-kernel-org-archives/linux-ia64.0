From: Alex Williamson <alex_williamson@hp.com>
Date: Wed, 08 Jan 2003 21:52:57 +0000
Subject: Re: [Linux-ia64] disabling nics in efi.
Message-Id: <marc-linux-ia64-105590709805647@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805644@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805644@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

   The EFI driver has nothing to do with whether the NIC shows up
to the OS.  It only makes it unavailble from EFI, the hardware is
still there.  I don't know of any way to make the NICs not show up
other than not loading the module.

	Alex

Roy Dragseth wrote:
>=20
> I have a bunch of HP rx2600 that have two internal nics (10/100Mbit and 1=
Gbit)
> and one external nic (1Gbit).  Is it possible to disable the two internal
> ones in efi so linux won't see them?  I tried to use the disconnect comma=
nd
> in the efi shell, but they still keep showing up when I boot up linux.
> I used
> disconnect 4C
> disconnect 49
> and they report successful operation.  Am I missing the point completely?
>=20
> I also tried the reserve=3D boot option to avoid linux to probe them, but=
 that
> didn't work either.  I probably computed the iobase and extents wrong.  Do
> anyone know how to determine the correct parameters?
>=20
> The reason for wanting to disable the internal nics is that the redhat
> installer insists on fetching the kickstart file over eth0 when doing
> installations over the network and the external nic that I want to use
> becomes eth2.
>=20
> Any hints is greatly appreciated.
>=20
> Best regards,
> Roy.
> --
>=20
>   The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
>               phone:+47 77 64 41 07, fax:+47 77 64 41 00
>      Roy Dragseth, High Performance Computing System Administrator
>          Direct call: +47 77 64 62 56. email: royd@cc.uit.no
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO

