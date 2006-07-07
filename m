From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 07 Jul 2006 06:29:01 +0000
Subject: Re: cross compiling for ia64?
Message-Id: <20060707062901.GB31522@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
List-Id: <linux-ia64.vger.kernel.org>
References: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
In-Reply-To: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 05, 2006 at 10:43:48PM -0400, Brown, Len wrote:
> Does anybody have the latest instructions and tools to
> cross compile to ia64 from i386 or x86_64 hosts?

For Debian users, I am keeping some up-to-date cross compilers at
Gelato@UNSW for x86 and x86-64

Add

deb http://www.gelato.unsw.edu.au/debian unstable main

to your /etc/apt/sources.list

And then you should be able to do, for example

$ sudo apt-get install gcc-4.1-ia64-linux-gnu

Please report any issues to me (off list).

Thanks,

-i

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFErf8tWDlSU/gp6ecRAkB0AJoCEPc4+AWhWcg4rkM/wOOkgSh8hQCfZc8S
nWT8DM3BBQmGPBOMmN8Ycq8=
=thGd
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
