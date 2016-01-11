From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 11 Jan 2016 10:35:47 +0000
Subject: Re: [PATCH v3 3/3] checkpatch: add virt barriers
Message-Id: <20160111123423-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452454200-8844-1-git-send-email-mst@redhat.com>
 <1452454200-8844-4-git-send-email-mst@redhat.com>
 <CAGRGNgXQANbKD=VA0Qx4Wp1+MpZUVV7by8RrKxF9o=qu=vUQqA@mail.gmail.com>
 <1452466336.7773.46.camel@perches.com>
In-Reply-To: <1452466336.7773.46.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>
Cc: Julian Calaby <julian.calaby@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, "Mailing List, Arm" <linux-arm-kernel@lists.infradead.org>, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.k

On Sun, Jan 10, 2016 at 02:52:16PM -0800, Joe Perches wrote:
> On Mon, 2016-01-11 at 09:13 +1100, Julian Calaby wrote:
> > On Mon, Jan 11, 2016 at 6:31 AM, Michael S. Tsirkin <mst@redhat.com> wr=
ote:
> > > Add virt_ barriers to list of barriers to check for
> > > presence of a comment.
> []
> > > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
> > > @@ -5133,7 +5133,8 @@ sub process {
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}x;
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0my $all_barriers =3D =
qr{
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0$barriers|
> > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0smp_(?:$smp_barrier_stems)
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0smp_(?:$smp_barrier_stems)|
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0virt_(?:$smp_barrier_stems)
> >=20
> > Sorry I'm late to the party here, but would it make sense to write this=
 as:
> >=20
> > (?:smp|virt)_(?:$smp_barrier_stems)
>=20
> Yes.  Perhaps the name might be better as barrier_stems.
>=20
> Also, ideally this would be longest match first or use \b
> after the matches so that $all_barriers could work
> successfully without a following \s*\(
>=20
> my $all_barriers =3D qr{
> 	(?:smp|virt)_(?:barrier_stems)|
> 	$barriers)
> }x;
>=20
> or maybe add separate $smp_barriers and $virt_barriers
>=20
> <shrug>  it doesn't matter much in any case

OK just to clarify - are you OK with merging the patch as is?
Refactorings can come as patches on top if required.

--=20
MST
