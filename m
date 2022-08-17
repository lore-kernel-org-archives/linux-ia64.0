From: matoro <matoro_mailinglist_kernel@matoro.tk>
Date: Wed, 17 Aug 2022 21:57:42 +0000
Subject: Re: [PATCH] ia64: fix clock_getre(CLOCK_MONOTONIC) to report ITC frequency
Message-Id: <6d07209d000b671a3bc48003905652e8@matoro.tk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815054944.4130786-1-slyich@gmail.com>
 <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
In-Reply-To: <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergei Trofimovich <slyich@gmail.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi Andrew, I came up with the prototype for this patch, but it was based=20
entirely on Sergei's investigation which was documented in=20
https://bugs.gentoo.org/596382.  I asked him to send it upstream because=20
I'm unable to attach my realname to it due to my job.  I can place a=20
signed-off-by with my handle but I understand that's normally against=20
kernel policy which is why I didn't.  Either way the bulk of the work=20
belongs to Sergei, I just scribbled it down, and he cleaned it up for=20
this submission.

-------- Original Message --------
Subject: Re: [PATCH] ia64: fix clock_getre(CLOCK_MONOTONIC) to report=20
ITC frequency
Date: 2022-08-17 15:21
 From: Andrew Morton <akpm@linux-foundation.org>
To: Sergei Trofimovich <slyich@gmail.com>

On Mon, 15 Aug 2022 06:49:44 +0100 Sergei Trofimovich <slyich@gmail.com>=20
wrote:

> clock_gettime(CLOCK_MONOTONIC, &tp) is very precise on ia64 as it uses
> ITC (similar to rdtsc on x86). It's not quite a hrtimer as it is a few
> times slower than 1ns. Usually 2-3ns.
>=20
> clock_getres(CLOCK_MONOTONIC, &res) never reflected that fact and
> reported 0.04s precision (1/HZ value).
>=20
> In https://bugs.gentoo.org/596382 gstreamer's test suite failed loudly
> when it noticed precision discrepancy.
>=20
> Before the change:
>=20
>     clock_getres(CLOCK_MONOTONIC, &res) reported 250Hz precision.
>=20
> After the change:
>=20
>     clock_getres(CLOCK_MONOTONIC, &res) reports ITC (400Mhz) precision.
>=20
> The patch is based on matoro's fix. It adds a bit of explanation why we
> need to special-case arch-specific clock_getres().
>=20

It would be best (and nice) to include the original developer's
Signed-off-by: and to Cc =C3=89meric Maschino if possible?

Could you please take care of these paperwork issues?
