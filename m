From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 06 Jul 2006 03:30:32 +0000
Subject: Re: cross compiling for ia64?
Message-Id: <20060706033032.GC2678@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
List-Id: <linux-ia64.vger.kernel.org>
References: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
In-Reply-To: <CFF307C98FEABE47A452B27C06B85BB6E59456@hdsmsx411.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 05, 2006 at 10:43:48PM -0400, Brown, Len wrote:
> Does anybody have the latest instructions and tools to
> cross compile to ia64 from i386 or x86_64 hosts?

What distribution are you using?

The generic way is http://www.kegel.com/crosstool/ though I tend to
have varying levels of success with that.

If you are using Debian you can try 

http://www.gelato.unsw.edu.au/IA64wiki/DebianCrossCompiler

or I can make the packages available to you.  In fact, I might try to
find some time to setup a cross compiler repository you can put in
sources.list.

-i

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFErIPYWDlSU/gp6ecRAuccAJ95O6ljvkpgtBTpWQPURQOQZy4+7QCg1+/k
QGtr0jtETJ+lJQAlp6KTGXY=
=KQcn
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
