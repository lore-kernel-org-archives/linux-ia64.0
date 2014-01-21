From: Dennis Schridde <devurandom@gmx.net>
Date: Tue, 21 Jan 2014 23:39:49 +0000
Subject: Re: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <20140122003949.05d83ccb@samson>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/377oLTL8XteiUrdC/kPKCpc"
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org

--Sig_/377oLTL8XteiUrdC/kPKCpc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Am Tue, 21 Jan 2014 23:24:03 +0000
schrieb "Luck, Tony" <tony.luck@intel.com>:

> I'd start off with using the old compiler
> for arch/ia64/kernel/* (perhaps arch/ia64/mm/* too) and the new
> compiler for everything else.

Thanks for your suggestion. How do I do that properly?
I think the following will not work, because changing CC will cause
arch/ia64/kernel to be rebuild, right?
# make -C arch/ia64/kernel CC=3Dgcc-4.7.3
# make CC=3Dgcc-4.5.4

And what would you suggest to add after ia64/kernel and ia64/mm? I do
not know much about the parts of the kernel that run at this early
stage.

--Dennis

--Sig_/377oLTL8XteiUrdC/kPKCpc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJS3wVFAAoJEGIxC0Gvwa5a+kwQAJwuBYL9Uggm5hMIxg7s5QEk
KwTzviNTkZyVrz5myXAwos07ZRbvCq9WBlj59tB2avcZ0u9Ecx7E2nl3R7utM/Fy
y20k4qrn63k1lqsyb91WqtUp54FpcB9YNoWwz/GdQKxJ5SL74ANhuealDhLthLPS
z3TuH3JlmugELzjBpcsZnP585cmHNlWylIePJfSnkGSmUoARPmduqThEOV0Sf+Zi
df8lBu9noGk+J1kFU7lD1k2EJYSqXtjJFuMjB2puODS8n/mZQuoovlYgrV/NSYrx
RmQVPbMnK45lBaENqcPn5FkjRgGuHMsdeEURPPy3HwUOtY1sUE8P71IPjOhK67DU
F0BrwKILjtz+pz0JbBYPbubRkMPiQ9uAOye4apgmlYP9czX1g2Di+zbZafk1pCPc
yJYEWqVdmnVcVRT/TqcOZ7nLtFmn79TpEy6bkLRw6Wg51mC5bst2g6H5oZzMYn2D
HWlCgIwwSXkPMvlti+zuxyCwI3DCUoPVnpkaanas1B9x03PEr1G5OByjpth1nzao
KTHbrAq9pODkflFt7r+dVPr+uBsbDEUyuxanb2h7mkOyeAhgs5gDcqd0tSvX8zMj
h1FLoe++MVVwmX+inxQtpfM2AJTEZSkxZjpxv8CLAdoRJQhvGirgCKuaLTO2ZBX0
RSiy9PEWfwX2thUVSAzN
=bkt0
-----END PGP SIGNATURE-----

--Sig_/377oLTL8XteiUrdC/kPKCpc--
