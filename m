From: Con Kolivas <kernel@kolivas.org>
Date: Sun, 31 Jul 2005 04:35:06 +0000
Subject: Re: [sched, patch] better wake-balancing, #2
Message-Id: <200507311435.09225.kernel@kolivas.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart6421577.OHCWCaKClm"
List-Id: <linux-ia64.vger.kernel.org>
References: <200507301929_MC3-1-A601-D4C2@compuserve.com>
In-Reply-To: <200507301929_MC3-1-A601-D4C2@compuserve.com>
To: linux-kernel@vger.kernel.org
Cc: Chuck Ebbert <76306.1226@compuserve.com>, Ingo Molnar <mingo@elte.hu>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64 <linux-ia64@vger.kernel.org>

--nextPart6421577.OHCWCaKClm
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sun, 31 Jul 2005 09:26, Chuck Ebbert wrote:
> On Fri, 29 Jul 2005 at 17:02:07 +0200, Ingo Molnar wrote:
> > do wakeup-balancing only if the wakeup-CPU is idle.
> >
> > this prevents excessive wakeup-balancing while the system is highly
> > loaded, but helps spread out the workload on partly idle systems.
>
> I tested this with Volanomark on dual-processor PII Xeon -- the
> results were very bad:
>
> Before: 5863 messages per second

> After: 5569 messages per second

Can you check schedstats or otherwise to find if volanomark uses=20
sched_yield() ? When last this benchmark came up, it appeared that no jvm=20
used futexes and left locking to yielding. We really should find out if tha=
t=20
is the case before trying to optimise for this benchmark.

Cheers,
Con

--nextPart6421577.OHCWCaKClm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBC7FT9ZUg7+tp6mRURAk7zAJ4vwv1n0picU3J4ODTzTg6IUBT6ogCfaby4
FN2C76fkrGxucZeWjfMY1FY=
=sKKn
-----END PGP SIGNATURE-----

--nextPart6421577.OHCWCaKClm--
