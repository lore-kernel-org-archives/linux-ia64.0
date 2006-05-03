From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 03 May 2006 10:53:27 +0000
Subject: Re: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <20060503105326.GA13605@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
List-Id: <linux-ia64.vger.kernel.org>
References: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 03, 2006 at 10:07:35AM +0200, Christian Hildner wrote:
> Yes. So why not picking up Ken's idea of two parallel IVTs.

I have a version of this, which I've tried to post here but I think
the size limit here is very low.  It made it through to linux-mm

http://marc.theaimsgroup.com/?l=linux-mm&m=114664224732618&w=2

or the patches are at

http://www.gelato.unsw.edu.au/~ianw/lvhpt/patches/v2

It generates ivt.S using a little script.  Any feedback on this
approach welcome.

-i

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEWIumWDlSU/gp6ecRAgzGAJ0YIhNFQ0D3mPmvnzzgXRk1N2yzDQCfdhST
zPg445cIABpvPLDMn9WUcJA=
=X8JA
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
