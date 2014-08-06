From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 06 Aug 2014 06:27:14 +0000
Subject: Re: [Q] sched: __ARCH_WANT_UNLOCKED_CTXSW on IA64
Message-Id: <20140806062714.GM9918@twins.programming.kicks-ass.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ffsjeLa00pPTU3fi"
List-Id: <linux-ia64.vger.kernel.org>
References: <876351407274890@web12m.yandex.ru>
In-Reply-To: <876351407274890@web12m.yandex.ru>
To: linux-ia64@vger.kernel.org


--ffsjeLa00pPTU3fi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2014 at 01:41:30AM +0400, Kirill Tkhai wrote:
> Hi, IA64 Gurus,
>=20
> I was looking for the reasons of IA64's __ARCH_WANT_UNLOCKED_CTXSW,
> and found the historical commit below:
>=20
>     commit f8efa27662532ad5adb2790bfc3f4c78e019cfad
>     Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
>     Date:   Thu Jan 26 18:24:59 2006 -0800
>=20
>     [IA64] remove staled comments in asm/system.h
>    =20
>     With the recent optimization made to wrap_mmu_context function,
>     we don't hold tasklist_lock anymore when wrapping context id.
>     The comments in asm/system.h must fall through the crack earlier.
>     Remove staled comments.
>    =20
>     I believe it is still beneficial to unlock the runqueue lock
>     across context switch. So leave __ARCH_WANT_UNLOCKED_CTXSW on.
>    =20
>     Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
>=20
> The comment confuses a reader. It may seem that the #define
> is not necessary now, no comment around it at all.
>=20
> So, could you please point the deadlock we want to avoid
> by __ARCH_WANT_UNLOCKED_CTXSW? I've tried to find, but nothing
> was found by me. No IA64 machines around, so I can't just
> to load kernel w/o this define.

see http://marc.info/?l=3Dlinux-kernel&m=3D131418885605812

--ffsjeLa00pPTU3fi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT4cq+AAoJEHZH4aRLwOS6TAkQAKXMwwK/66jDo/l/e1Mkz83U
r0o22PDShVQD2Phc8mZAkZTWTYwi/HhncgZ3x8Hm2Nw1eiGJzfI73XnETypL1rau
oYpmzNxZHMiA0eGOWuOAVDNs0duOfVj5vKEzmCkMY018ZGpF+JX8Ul8HRqE35V+K
EvGXaErmSgiCP6Ez4aWmb0uSwnybiUBwkD1jsw1NdxQQ3V9Lh8CgXcl+ESs16KxX
krDAPNEwoIuIv/4vMYhNvfCz+0rLeXd6lwGVIEufSvhAZN0k6nL29JXKHCE5DIhG
A9nkEDcCTa4jFMnEk0JoyE+bFgECqzunIMsTv06+S3wPJCiI84MaaN6NQ/bjHHRw
EgF4sOk4dxkBWaLxx70CenQEyQyt/xmoWpQPDVNCGeyj3UH+3C0SJpUEOlSbUnx7
AmBHlCtsEcAtYvdWuAHrOuNbKyOqAg8/1ryBQq3mu5+U9EMHWg+Pz2vj17M55JZF
iptcUPgsW0Y23XY7/f/WhTiuF/plFyB1XAeMYaY17rh0q9RqYeLoIUsl+m4n0jEt
f4cs/ucVyehUjIHlTVetAY4oa0nJjSezA7hDj4IqQnh7yUsUdtYwUaiBYm6a5GPb
W7Z77wq7/DgKZg6pdrjmRjZev3mRGZNUQeV1t0f5nC4mL/hTVjDzkvKiAaRXzvVp
Wy9mXmfqe/520FRlhMU3
=qF0Y
-----END PGP SIGNATURE-----

--ffsjeLa00pPTU3fi--
