From: Eric Piel <Eric.Piel@Bull.Net>
Date: Fri, 18 Apr 2003 12:00:19 +0000
Subject: Re: [perfmon] Re: [Linux-ia64] [BUG] perfmon doesn't send SIGPROF in
Message-Id: <marc-linux-ia64-105590723705561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
>=20
> The attached patch against 2.5.67 corrects the problem. Note that this
> patch also includes other updates.
>=20
> Let me know how it goes.
Very good, it worked!:
# ./realfeel4=20
897.528 MHz
secondsPerTick=3D1.11417e-09
ticksPerSecond=897528470.872679
sample_period =3D 6282699
smallest =3D 4511, largest =3D 8271, nsamples =3D 1426, sigma =3D 6869234,
sigmasqr =3D 33252330632
Mean 4817.13, stddev 337.37

Thank you!

Also, after a quick glance at the patch I noticed this update:
-/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL,
0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
{0UL,0UL, 0UL, 0UL}},
-/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL,
0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
{0UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL,
0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
{0UL,0UL, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL,
0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
{0UL,0UL, 0UL, 0UL}},

Could you describe shortly what this is suppose to fix? Recently I had
some troubles with some PMU counters on Itanium2 (hard to trigger) and I
wonder if this could be solved by that patch...

Eric

