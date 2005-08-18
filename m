From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 18 Aug 2005 03:45:48 +0000
Subject: Re: change to the ia64 GIT trees
Message-Id: <20050818034548.GQ29115@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EVh9lyqKgK19OcEf"
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042945E9@scsmsx401.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--EVh9lyqKgK19OcEf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 16, 2005 at 03:00:38PM -0700, Luck, Tony wrote:
> Instead of having separate trees for test and release, there
> is now just one tree which contains "test" and "release" branches.

Does anyone know how one gets to these using cogito?  Or maybe I
should just not use cogito?

$ cg-clone rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git linux-2.6.git
$ cd linux-2.6.git
$ cg-branch-ls
origin  rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

I had expected to see the test and release branches there.

> You can pull each of the branches separately with:
> 
>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 test
> or
>  $ git pull rsync://rsync.kernel.org/..../aegl/linux-2.6 release

Is that supposed to be linux-2.6.git?
 
Along the same lines, when I look at the web view at

http://www.kernel.org/git/?p=linux/kernel/git/aegl/linux-2.6.git;a=summary

and especially the "tree" view (which I use a bit to see what has
changed in a file) what branch am I looking at there, the test or the
release? 

-i

--EVh9lyqKgK19OcEf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDBARsWDlSU/gp6ecRAinJAKDG3oiWpSjEPwAB2IDzy0SoO3ovCQCgriQM
8NUn4zJ08w2Ri1OfVMRKmGY=
=Icns
-----END PGP SIGNATURE-----

--EVh9lyqKgK19OcEf--
