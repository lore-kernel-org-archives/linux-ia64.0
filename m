From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 02 Sep 2004 06:21:55 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902062155.GJ21873@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Wtrm9ATX0sn6fFKv"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--Wtrm9ATX0sn6fFKv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 01, 2004 at 11:10:30PM -0700, William Lee Irwin III wrote:
> You don't thave CONFIG_DISCONTIGMEM set? Why are you bothering with
> virtual mem_map if not? If the core helpers are insufficiently
> lightweight in the CONFIG_DISCONTIGMEM=n case we are very well going
> to have whatever sanction we need to repair it, as this is the common
> case among end users of the most predominant hardware and architectures.

Just to reply to this: the only reason is that VIRTUAL_MEMMAP is set
in zx1_defconfig.  Maybe it shouldn't be and I might never have
noticed the problem ...

-i

--Wtrm9ATX0sn6fFKv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBNrwDWDlSU/gp6ecRApYHAJ9FEguiiaajamfW4a7MwFSfTpEHwQCfZAof
oDr0XnjZ4wnnHLMnhWlyNA0=
=jtlT
-----END PGP SIGNATURE-----

--Wtrm9ATX0sn6fFKv--
