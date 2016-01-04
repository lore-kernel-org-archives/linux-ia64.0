From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 04 Jan 2016 20:45:19 +0000
Subject: Re: [PATCH 1/3] checkpatch.pl: add missing memory barriers
Message-Id: <20160104224415-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
 <1451907395-15978-2-git-send-email-mst@redhat.com>
 <1451923660.4334.83.camel@perches.com>
In-Reply-To: <1451923660.4334.83.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Cc : Andy Whitcroft" <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

On Mon, Jan 04, 2016 at 08:07:40AM -0800, Joe Perches wrote:
> On Mon, 2016-01-04 at 13:36 +0200, Michael S. Tsirkin wrote:
> > SMP-only barriers were missing in checkpatch.pl
> >=20
> > Refactor code slightly to make adding more variants easier.
> >=20
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> > =A0scripts/checkpatch.pl | 9 ++++++++-
> > =A01 file changed, 8 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index 2b3c228..0245bbe 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -5116,7 +5116,14 @@ sub process {
> > =A0			}
> > =A0		}
> > =A0# check for memory barriers without a comment.
> > -		if ($line =3D~ /\b(mb|rmb|wmb|read_barrier_depends|smp_mb|smp_rmb|sm=
p_wmb|smp_read_barrier_depends)\(/) {
> > +
> > +		my @barriers =3D ('mb', 'rmb', 'wmb', 'read_barrier_depends');
> > +		my @smp_barriers =3D ('smp_store_release', 'smp_load_acquire', 'smp_=
store_mb');
> > +
> > +		@smp_barriers =3D (@smp_barriers, map {"smp_" . $_} @barriers);
>=20
> I think using map, which so far checkpatch doesn't use,
> makes smp_barriers harder to understand and it'd be
> better to enumerate them.

Okay - I'll rewrite using foreach.

> > +		my $all_barriers =3D join('|', (@barriers, @smp_barriers));
> > +
> > +		if ($line =3D~ /\b($all_barriers)\(/) {
>=20
> It would be better to use /\b$all_barriers\s*\(/
> as there's no reason for the capture and there
> could be a space between the function and the
> open parenthesis.

That's the way it was - space before ( will trigger other
warnings. But sure, ok.

>=20
> > =A0			if (!ctx_has_comment($first_line, $linenr)) {
> > =A0				WARN("MEMORY_BARRIER",
> > =A0				=A0=A0=A0=A0=A0"memory barrier without comment\n" . $herecurr);
