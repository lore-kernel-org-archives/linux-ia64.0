From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 07 Jul 2008 01:14:36 +0000
Subject: Re: the printk problem
Message-Id: <1215393276.8970.36.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<1215212420.8970.8.camel@pasglop>
	<alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, parisc-linux@parisc-linux.org

On Fri, 2008-07-04 at 16:25 -0700, Linus Torvalds wrote:
>=20
> On Sat, 5 Jul 2008, Benjamin Herrenschmidt wrote:
> >=20
> > I'll give it a try using =EF=BB=BFprobe_kernel_address() instead on mon=
day.
>=20
> Here's the updated patch which uses probe_kernel_address() instead (and=20
> moves the whole #ifdef mess out of the code that wants it and into a=20
> helper function - and maybe we should then put that helper into=20
> kallsyms.h, but that's a different issue).
>=20
> Still all happily untested, of course. And still with no actual users=20
> converted.

Did a few tests and it seems to work. I'll stick a patch converting
powerpc to use %pS for oops display in -next.

Thanks !

Cheers,
Ben.

