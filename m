From: Joe Perches <joe@perches.com>
Date: Sun, 10 Jan 2016 15:08:39 +0000
Subject: Re: [PATCH v2 2/3] checkpatch: check for __smp outside barrier.h
Message-Id: <1452438519.7773.23.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452427000-4520-1-git-send-email-mst@redhat.com>
	 <1452427000-4520-3-git-send-email-mst@redhat.com>
In-Reply-To: <1452427000-4520-3-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: Andy Whitcroft <apw@canonical.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Tony Lindgren <tony@atomide.com>

On Sun, 2016-01-10 at 13:57 +0200, Michael S. Tsirkin wrote:
> Introduction of __smp barriers cleans up a bunch of duplicate code, but
> it gives people an additional handle onto a "new" set of barriers - just
> because they're prefixed with __* unfortunately doesn't stop anyone from
> using it (as happened with other arch stuff before.)
>=20
> Add a checkpatch test so it will trigger a warning.
[]
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -5141,6 +5141,16 @@ sub process {
> =A0			}
> =A0		}
> =A0
> +		my $underscore_smp_barriers =3D qr{__smp_($smp_barriers)}x;

another unnecessary capture group

> +
> +		if ($realfile !~ m@^include/asm-generic/@ &&
> +		=A0=A0=A0=A0$realfile !~ m@/barrier\.h$@ &&
> +		=A0=A0=A0=A0$line =3D~ m/\b($underscore_smp_barriers)\s*\(/ &&
> +		=A0=A0=A0=A0$line !~ m/^.\s*\#\s*define\s+($underscore_smp_barriers)\s=
*\(/) {
> +			WARN("MEMORY_BARRIER",
> +			=A0=A0=A0=A0=A0"__smp memory barriers shouldn't be used outside barri=
er.h and asm-generic\n" . $herecurr);
> +		}
> +
> =A0# check for waitqueue_active without a comment.
> =A0		if ($line =3D~ /\bwaitqueue_active\s*\(/) {
> =A0			if (!ctx_has_comment($first_line, $linenr)) {

