From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 08 Nov 2005 22:09:13 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051108220913.GI20935@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nO3oAMapP4dBpMZi"
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
To: linux-ia64@vger.kernel.org


--nO3oAMapP4dBpMZi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(CC trimmed)

On Tue, Nov 08, 2005 at 10:52:38AM -0800, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> Just a thought... shouldn't it be possible (at least in theory)
> for all the page table macros to be made a bit more dynamically
> flexible so that PAGESIZE can (at least optionally) be specified
> as a boottime parameter?  For example (very loosely):

Well, this suggests to me that maybe we could start working towards a
proper page table abstraction where we can implement totally different
underlying page table implementations with relative ease.

Paul Davies has been looking into this area with some success with an
initial implementation of a guarded page table underneath his
abstraction interface.  The abstraction stuff was posted to linux-mm

http://thread.gmane.org/gmane.linux.kernel.mm/7847

Obviously it isn't something that will happen overnight, but certainly
if a few people could agree it is a useful long term goal that might
be useful.

-i

--nO3oAMapP4dBpMZi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDcSIJWDlSU/gp6ecRAm0JAJ463VLOW44I8MhEW+M3GG4piX8kAQCgmK7k
BnTVSu0ygv5B4VoMmVSnp/M=
=Inv6
-----END PGP SIGNATURE-----

--nO3oAMapP4dBpMZi--
