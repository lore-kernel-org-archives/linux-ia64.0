From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 19 Apr 2001 16:41:39 +0000
Subject: Re: [Linux-ia64] Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005436@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005426@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005426@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Does this work?

/usr/bin/getconf _NPROCESSORS_ONLN


On Thu, Apr 19, 2001 at 11:45:28AM +0200, Andreas Schwab wrote:
> How can I detect an SMP system in user space even when running an UP
> kernel?  Things like `cat /proc/cpuinfo' don't count.
>=20
> Andreas.
>=20
> --=20
> Andreas Schwab                                  "And now for something
> SuSE Labs                                        completely different."
> Andreas.Schwab@suse.de
> SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--=20
Mike Madore
Software Engineer
TurboLinux, Inc.

