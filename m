From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 23 Apr 2004 22:29:45 +0000
Subject: Re: [patch 1/3] efivars driver update and move
Message-Id: <20040423222945.GA9594@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
List-Id: <linux-ia64.vger.kernel.org>
References: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
In-Reply-To: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, bjorn.helgaas@hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matthew.e.tolentino@intel.com


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 22, 2004 at 10:32:19AM -0700, Matt Tolentino wrote:
> Andrew,
>=20
> I broke up the efivars driver update patch I had sent out
> quite a while ago into several smaller patches.  This=20
> includes several fixes and suggestions that were pointed
> out.  The patches are broken down as follows:
>=20
> 2 - add new sysfs based efivars driver into
>     drivers/firmware with accompanying Kconfig/Makefile=20
>     changes to make it fully functional for ia64 again.

Trying these against 2.6.5 + ia64 patch, with efibootmgr-0.5.2-test2.

Works: reading, deleting values.
Doesn't work:  creating and editing values

I note that efibootmgr prints out a warning when it can't read
nonexistant variables, like BootNext.  I'll remove that warning.

It's likely a bug in efibootmgr, as this is the first time I've tried
the sysfs side of things.  If you're in a position to help debug, I'd
appreciate it.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--+HP7ph2BbKc20aGI
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAiZjZIavu95Lw/AkRAs6cAJ4szO5uJGFQD9MxrhUwzTElBJveowCffiwp
rSB2Kfu0L28moKObQEX3OoE=
=1Pdt
-----END PGP SIGNATURE-----

--+HP7ph2BbKc20aGI--
