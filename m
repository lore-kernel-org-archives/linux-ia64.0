From: Boqun Feng <boqun.feng@gmail.com>
Date: Thu, 07 Jan 2016 00:43:56 +0000
Subject: Re: [PATCH v2 15/32] powerpc: define __smp_xxx
Message-Id: <20160107004356.GB14605@fixme-laptop.cn.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-16-git-send-email-mst@redhat.com>
 <20160105013648.GA1256@fixme-laptop.cn.ibm.com>
 <20160105085117.GA11858@redhat.com>
 <20160105095341.GA5321@fixme-laptop.cn.ibm.com>
 <20160105180938-mutt-send-email-mst@redhat.com>
 <20160106015152.GA14605@fixme-laptop.cn.ibm.com>
 <20160106222337-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160106222337-mutt-send-email-mst@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paul>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 06, 2016 at 10:23:51PM +0200, Michael S. Tsirkin wrote:
[...]
> > >=20
> > > Sorry, I don't understand - why do you have to do anything?
> > > I changed all users of smp_lwsync so they
> > > use __smp_lwsync on SMP and barrier() on !SMP.
> > >=20
> > > This is exactly the current behaviour, I also tested that
> > > generated code does not change at all.
> > >=20
> > > Is there a patch in your tree that conflicts with this?
> > >=20
> >=20
> > Because in a patchset which implements atomic relaxed/acquire/release
> > variants on PPC I use smp_lwsync(), this makes it have another user,
> > please see this mail:
> >=20
> > http://article.gmane.org/gmane.linux.ports.ppc.embedded/89877
> >=20
> > in definition of PPC's __atomic_op_release().
> >=20
> >=20
> > But I think removing smp_lwsync() is a good idea and actually I think we
> > can go further to remove __smp_lwsync() and let __smp_load_acquire and
> > __smp_store_release call __lwsync() directly, but that is another thing.
> >=20
> > Anyway, I will modify my patch.
> >=20
> > Regards,
> > Boqun
>=20
>=20
> Thanks!
> Could you send an ack then please?
>=20

Sure, if you need one from me, feel free to add my ack for this patch:

Acked-by: Boqun Feng <boqun.feng@gmail.com>

Regards,
Boqun

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWjbTIAAoJEEl56MO1B/q4Xf8H/A0lM6gsUPNqUU24iHbc5O4j
qN+FbAuVULCXdZfNW9uS+HG4Oq9VqZZc4rv5QdX6IHzcYKTYAv7+8rEMHmrxV8A/
mMKfwU07krXlG0IRFhiMpuCzvjAfa0CgPOUHBzGJU5mdrAiM8ymtpa1ofde/uitO
UaRheer5STPZ2kUzrA0r2hYbtWczy6X7yIxioQbXKeR88AuE8X12Me7X+zl9YoPP
NnwnzDhEkvj7wzQVgWTyA4fwu051dOtRENtv0k6UugV2bW45SsuLQ9Co3BUh/iK+
KF/57kaJ9BfOGYF1HAHH10GSkwTyyAsc8SGAQKg6PY/lJsHBDFluEtr98U1ssCA=
=FLp9
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
