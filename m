From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 18 Jan 2001 18:28:09 +0000
Subject: Re: [Linux-ia64] CD recorder software for Big Sur
Message-Id: <marc-linux-ia64-105590693005083@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005081@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005081@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

We use mkisofs and cdrecord to burn our installation CD's.

Here are command lines that work for us.

mkisofs  -no-emul-boot -b boot.img -c boot.catalog -R -T -J -o ../cdrom.img=
 .

cdrecord fs=8196k speed=3D8 dev=3D2,0,0 -v -eject cdrom.img

Of course the dev and speed parameters would vary depending on your drive
and media.  There is much more information in the documentation.

On Thu, Jan 18, 2001 at 06:18:14PM +0000, Eric Wang wrote:
> Dear all,
>=20
> I have tried to use a PC and Easy Creator to create a iso image then burn=
=20
> into a CD, but I could not read this CD with Big Sur machine in EFI promp=
t.=20
> Would you please tell me where can I get a program that can burn a CD and=
 be=20
> read by Big Sur in EFI?
>=20
> Thank you and have a nice day!
>=20
> Eric
>=20
> Eric Wang
> IA64 desktop engineering
> SGI
>=20
> _________________________________________________________________________
> Get Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com.
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Mike Madore
Software Engineer
TurboLinux, Inc.

