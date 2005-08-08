From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 08 Aug 2005 00:17:17 +0000
Subject: Re: Debian kernel and /proc/pal
Message-Id: <20050808001717.GA19349@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
List-Id: <linux-ia64.vger.kernel.org>
References: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
In-Reply-To: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
To: linux-ia64@vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 05, 2005 at 01:36:54PM +0200, Stephane Eranian wrote:
> I recently used an Itanium machine booted with a 2.6 Linux kernel.
> The exact package is:
>         kernel-image-2.6.11-1-mckinley-smp_2.6.11-6_ia64.deb
> 
> It does appear that this kernel is compiled without CONFIG_PALINFO
> which means there is no /proc/pal/cpu* entries.

I filed this under

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=321885

for the latest 2.6.12 packages which have the same thing.

-i

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9qSNWDlSU/gp6ecRAlGiAKDAgaAoUcG1zVNdRiSvByGasxsQgQCgiGZj
XjBd1f8laglY6xlTjDyEA6E=
=MyDb
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
