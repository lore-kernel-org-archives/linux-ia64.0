From: Harald Welte <laforge@netfilter.org>
Date: Thu, 10 Jun 2004 05:46:24 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040610054624.GL11490@sunbeam.de.gnumonks.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="BOmey7/79ja+7F5w"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com> <1086805676.4288.16.camel@tdi> <20040609130001.37a88da1.davem@redhat.com> <20040610014519.GA3158@taniwha.stupidest.org>
In-Reply-To: <20040610014519.GA3158@taniwha.stupidest.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: "David S. Miller" <davem@redhat.com>, Alex Williamson <alex.williamson@hp.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


--BOmey7/79ja+7F5w
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 09, 2004 at 06:45:19PM -0700, Chris Wedgwood wrote:
> On Wed, Jun 09, 2004 at 01:00:01PM -0700, David S. Miller wrote:
>=20
> > How can you legitimately change this structure?  It's an exported
> > userland interface, if you change it all the applications will stop
> > working.
>=20
> Why not split the structure for user-space and kernel-space version
> and cp/frob at/near the syscall boundary?

because it would look like an ugly hack in the setsockopt call, plus
adding another costly/time consuming parse of the table BLOB. =20

Also note that the kernel currently has no code that supports the
generation/modification of rulesets. All it can do is iterate over them.

>   --cw

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--BOmey7/79ja+7F5w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAx/WwXaXGVTD0i/8RAjesAKCZvTwXcJ1JV9yuVzPfa0sTEFy7OgCeJWpM
2PJ7uaS2rCOHIT1SEuk5EjU=
=osOF
-----END PGP SIGNATURE-----

--BOmey7/79ja+7F5w--
