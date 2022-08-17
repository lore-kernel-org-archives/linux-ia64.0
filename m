From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 17 Aug 2022 19:21:03 +0000
Subject: Re: [PATCH] ia64: fix clock_getre(CLOCK_MONOTONIC) to report ITC frequency
Message-Id: <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815054944.4130786-1-slyich@gmail.com>
In-Reply-To: <20220815054944.4130786-1-slyich@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sergei Trofimovich <slyich@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 15 Aug 2022 06:49:44 +0100 Sergei Trofimovich <slyich@gmail.com> wr=
ote:

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
Signed-off-by: and to Cc =C9meric Maschino if possible?

Could you please take care of these paperwork issues?
