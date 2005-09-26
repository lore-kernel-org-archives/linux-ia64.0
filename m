From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 26 Sep 2005 23:48:14 +0000
Subject: Re: patches added to test tree
Message-Id: <20050926234814.GA24802@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
In-Reply-To: <200509160423.j8G4NCub007777@agluck-lia64.sc.intel.com>
To: linux-ia64@vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 26, 2005 at 11:22:32AM -0700, David Mosberger-Tang wrote:
> I'm trying to use Firefox's Sage extension to track the RSS feeds. 
> Seems to work fine, but for the automated build-feed, the entries look
> like this:
> 
>    2.6.14-rc2 : 2005-09-26 : 17:00
>    2.6.14-rc2:  2005-09-25 : 17:00
> 
> which isn't very helpful.  Would it be possible to include a summary,
> such as "9 of 9 builds succeeded" or something like that?

I ditched the time because it's usually the same anyway, and added a
summary like

2.6.14-rc2 : 2005-09-26 : [patch 3/3] [built 11/11] [boot 3/3]

where it's

[component succeeded/attempted]

-i

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDOIi9WDlSU/gp6ecRAp8aAJ4+uL3FgrIsZmPkB05rzRGqHz62IACghMZP
EPnKzaGIfRRncN6w+SCe4QY=
=v7Fq
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
