From: Valdis.Kletnieks@vt.edu
Date: Wed, 24 Sep 2003 05:18:34 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="==_Exmh_-1580433968P"
Message-Id: <marc-linux-ia64-106438188813087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
To: linux-ia64@vger.kernel.org

--==_Exmh_-1580433968P
Content-Type: text/plain; charset=us-ascii

On Tue, 23 Sep 2003 15:58:29 PDT, "Luck, Tony" said:
> Alan Cox wrote:
> > On Maw, 2003-09-23 at 19:21, Luck, Tony wrote:
> > > a) the programmer is playing fast and loose with types and/or casts.
> > > b) the end-user is going to be disappointed with the performance.
> > 
> > c) the programmer is being clever and knows the unaligned access is
> > cheaper on average than the cost of making sure it cant happen
> 
> Which is great until the "cleverly written" program is fed a data set
> that pushes into the unaligned case far more frequently than the
> programmer anticipated.

Didn't we recently fix a DoS attack on the TCP stack that was basically this
sort of thing with hashes?  And crafting an attack against this would be a lot
simpler than the hash-function attack.....

--==_Exmh_-1580433968P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE/cSkqcC3lWbTT17ARArzLAKCmZ0L+QeMvsMtsNJ7WF+FKE01+swCfcCn2
i7kRo3EGWP8yKi4kus7OqVQ=
=Bzqo
-----END PGP SIGNATURE-----

--==_Exmh_-1580433968P--
