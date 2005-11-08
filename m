From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 08 Nov 2005 01:37:29 +0000
Subject: RE: [Patch]IA64 kexec
Message-Id: <894E37DECA393E4D9374E0ACBBE7427003BC95C8@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Zou Nan hai
> Sent: 2005=C4=EA11=D4=C28=C8=D5 7:28
> To: linux-ia64@vger.kernel.org
> Cc: khalid_aziz@hp.com
> Subject: [Patch]IA64 kexec
>=20
> Here is my patches of kexec on IA64.
>=20
> The kernel patch is against 2.6.14
> The kexec-tools patch is against kexec-tools-1.101
>=20
> I have tested it on a Tiger-4 and a ZX1 machine.
>=20
> Please test and review it.
>=20
> Thanks.
> Zou Nan hai
>=20

To try the patches,=20
You may download kexec-tools
From http://www.xmission.com/~ebiederm/files/kexec/kexec-tools-1.101.tar.gz
Then patch the kexec-tools and install it.
Run
kexec -l vmlinuz --initrd=3Dinitrd --append=3D"root=3D...";
kexec -e to see the second kernel booting.

Thanks
Zou Nan hai


=20
