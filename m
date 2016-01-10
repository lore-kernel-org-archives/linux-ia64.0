From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 19:13:38 +0000
Subject: Re: [PATCH v2 1/3] checkpatch.pl: add missing memory barriers
Message-Id: <20160110191338.GA5063@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452427000-4520-1-git-send-email-mst@redhat.com>
 <1452427000-4520-2-git-send-email-mst@redhat.com>
 <1452438425.7773.21.camel@perches.com>
In-Reply-To: <1452438425.7773.21.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Tony

On Sun, Jan 10, 2016 at 07:07:05AM -0800, Joe Perches wrote:
> On Sun, 2016-01-10 at 13:56 +0200, Michael S. Tsirkin wrote:
> > SMP-only barriers were missing in checkpatch.pl
> >=20
> > Refactor code slightly to make adding more variants easier.
> []
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
> > @@ -5116,7 +5116,25 @@ sub process {
> > =A0			}
> > =A0		}
> > =A0# check for memory barriers without a comment.
> > -		if ($line =3D~ /\b(mb|rmb|wmb|read_barrier_depends|smp_mb|smp_rmb|sm=
p_wmb|smp_read_barrier_depends)\(/) {
> > +
> > +		my $barriers =3D qr{
> > +			mb|
> > +			rmb|
> > +			wmb|
> > +			read_barrier_depends
> > +		}x;
> > +		my $smp_barriers =3D qr{
> > +			store_release|
> > +			load_acquire|
> > +			store_mb|
> > +			($barriers)
> > +		}x;
>=20
> If I use a variable called $smp_barriers, I'd expect
> it to actually be the smp_barriers, not to have to
> prefix it with smp_ before using it.
>=20
> 		my $smp_barriers =3D qr{
> 			smp_store_release|
> 			smp_load_acquire|
> 			smp_store_mb|
> 			smp_read_barrier_depends
> 		}x;
>=20
> or
>=20
> 		my $smp_barriers =3D qr{
> 			smp_(?:store_release|load_acquire|store_mb|read_barrier_depends)
> 		}x;
>=20

Yes but virt barriers (added in patch 3) are same things but prefixed
with virt_.  So we need the stems without smp_ prefix. If smp_barriers is
too confusing we'll just need to give them some other name.
How about:
my $smp_barrier_stems

?

> > +		my $all_barriers =3D qr{
> > +			$barriers|
> > +			smp_($smp_barriers)
> > +		}x;
>=20
> And this shouldn't have a capture group.
>=20
> 		my $all_barriers =3D qr{
> 			$barriers|
> 			$smp_barriers
> 		}x;	=09
> > +
> > +		if ($line =3D~ /\b($all_barriers)\s*\(/) {
>=20
> This doesn't need the capture group either (?:all_barriers)
>=20
> > =A0			if (!ctx_has_comment($first_line, $linenr))
> > {
> > =A0				WARN("MEMORY_BARRIER",
> > =A0				=A0=A0=A0=A0=A0"memory barrier without
> > comment\n" . $herecurr);
