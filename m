From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 01 Sep 2004 07:28:17 +0000
Subject: Re: [1/1] make bad_page() print all of page->flags
Message-Id: <20040901072817.GA32488@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040901061443.GW5492@holomorphy.com>
In-Reply-To: <20040901061443.GW5492@holomorphy.com>
To: linux-ia64@vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 31, 2004 at 11:14:43PM -0700, William Lee Irwin III wrote:
> (1) is this struct page actually in your virtual mem_map?

I'm assuming so, since when it's turned off it works?

> (2) page->flags looks 32-bit, but ia64 doesn't define
> 	ARCH_HAS_ATOMIC_UNSIGNED that I can tell; what's going on there?
> 	Let's see if those flags are really all zero.

Thanks, I applied the patch and it seems to be all zeros

Bad page state at free_hot_cold_page (in process 'swapper', page e000000004940c98)
flags:0x0000000000000000 mapping:0000000000000000 mapcount:1 count:0
Backtrace:
[-- stops again --]

> (3) "stops dead" isn't a very good description; deadlock? livelock?
> 	interrupts on or off?

It doesn't respond to magic-sysrq and I guess it takes an MCA because
it spontaneously reboots after about 10 seconds, though doesn't print
anything useful before it does that.

Thanks for you help,

-i

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBNXoRWDlSU/gp6ecRAp37AJoDkq00pp7Dd5S7ebfFRzmZoNK6zQCfbRUi
vcxTF32CYznVZGlO/Nb7bQk=
=jv24
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--
