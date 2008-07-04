From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 04 Jul 2008 23:00:20 +0000
Subject: Re: the printk problem
Message-Id: <1215212420.8970.8.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Peter Anvin <hpa@zytor.com>

On Fri, 2008-07-04 at 13:02 -0700, Linus Torvalds wrote:
>=20
> That function descriptor indirection is totally untested, and I did it=20
> with a
>=20
>         pagefault_disable();
>         __get_user(..)
>         pagefault_enable();
>=20
> thing because I thought it would be nice if printk() was always safe, and=
=20
> passing bogus function pointers to '%pF' should try to work, but quite=20
> frankly, I didn't even check that that part compiles, much less works.
>=20
> ia64/ppc lists cc'd, just in case somebody wants to test this.

I'll give it a try using =EF=BB=BFprobe_kernel_address() instead on monday.

Cheers,
Ben.


