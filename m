From: Arjan van de Ven <arjanv@redhat.com>
Date: Wed, 14 Apr 2004 09:04:02 +0000
Subject: Re: hugetlb demand paging patch part [0/3]
Message-Id: <1081933442.4688.6.camel@laptop.fenrus.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-EWB6MD/1nj3kUT+FMMpP"
List-Id: <linux-ia64.vger.kernel.org>
References: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
In-Reply-To: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>


--=-EWB6MD/1nj3kUT+FMMpP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2004-04-14 at 01:17, Chen, Kenneth W wrote:
> In addition to the hugetlb commit handling that we've been working on
> off the list, Ray Bryant of SGI and I are also working on demand paging
> for hugetlb page.  Here are our final version that has been heavily
> tested on ia64 and x86.  I've broken the patch into 3 pieces so it's
> easier to read/review, etc.

Ok I think it's time to say "HO STOP" here.

If you're going to make the kernel deal with different, concurrent page
sizes then please do it for real. Or alternatively leave hugetlb to be
the kludge/hack it is right now. Anything inbetween is the road to
madness...

--=-EWB6MD/1nj3kUT+FMMpP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAfP6CxULwo51rQBIRAv/XAJ4oAaWDmILpvk+zbyQaZamKl9ZlPQCcD/Ee
pT8aOtTp1bKjL2Vvqsd37/0=
=BePD
-----END PGP SIGNATURE-----

--=-EWB6MD/1nj3kUT+FMMpP--

