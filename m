From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 30 Sep 2014 10:51:19 +0000
Subject: Re: [PATCH v4 6/8] asm-generic/io.h: Implement generic {read,write}s*()
Message-Id: <20140930105118.GA27560@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
 <CAMo8BfJ9VJ24zsn_6VwNrAntmDqdJu11O79OyMd8eThv3UaaUw@mail.gmail.com>
 <CAMo8Bf+u8er_KF4nJPSPNf9OmKZHu4y0x3Pcb7DU17y5ocBJqw@mail.gmail.com>
 <1799506.5Clfp6gmMu@wuerfel>
In-Reply-To: <1799506.5Clfp6gmMu@wuerfel>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Max Filippov <jcmvbkbc@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, the arch/x86 maintainers <x86@kernel.org>, Stephen Boyd <sboyd@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-serial@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Sam Ravnborg <sam@ravnborg.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 30, 2014 at 12:39:37PM +0200, Arnd Bergmann wrote:
> On Tuesday 30 September 2014 14:26:20 Max Filippov wrote:
> > On Tue, Sep 30, 2014 at 2:22 PM, Max Filippov <jcmvbkbc@gmail.com> wrot=
e:
> > > Hi Thierry,
> > >
> > >> I think this can be fixed by including linux/string.h for memset() a=
nd
> > >> memcpy() in include/asm-generic/io.h.
> > >
> > > Will you send that fix or do I need to do it?
> >=20
> > Never mind, found that it's fixed in today's next.
> >=20
> >=20
>=20
>=20
> Actually I just backed out the original patches, the problem is still
> there in my tree.

I'll integrate the fix for this in my series, so this should be gone
with v5.

Thierry

--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUKosmAAoJEN0jrNd/PrOhrE8QAK/BmvywtJzQDgITRXV6OmlR
zGytBnkrGNB6GPzrir+o11WlOAira8bcr17OWn0JasMkvH8rN1tS0uC91XPt3IPL
EHxFZl2I7AkNvdv2/Iwi/UntwkPBBbBNNeIl+b9ueKeNAEMB7BvzUiYZ00q7plqg
Kkmy09cqoOAOGxaMY5r57/bhitoy8+OM72mamqU/JKApmuJ08jIkRHSWZkWlPq2F
aPd8E0lD/E/skDQ9RDUYPDUl58pSsfiM4YFYZvsaLgJyDua/8dFwVg8QehbegrOh
+hBfs7Kzk5ZMwzfyv+pj/64+Ub3l7i8hVb5h1LIS91xPdCBSr74FeYLp6qgEc/Mp
ina5Oh7+Cv34Us0hvBX1NJRsAA3bgmUnt1XeEGbm2V2p+tq+I5XtYIJTkg7R39YR
51u1oJGL9zjpFk0p5QtnIWl75t/po9TPoxyhW1HXr4XyWRicPE46Si4gA2/y/FWI
PmCy5HLR38yOGNNQFB02lSRdPSGKRoggpMeu2cQEOTFf37D2OphxmSR1LMsCbLml
fqrIbqJqXah4S8wmbaAT81LOBB+/5g/r7BLbYn+tvw2ckxroY9Jyd+UjaiByJ/aZ
6fOGyBc6/jy36Ox6QZCI75pZf+XSgsuva5yBbkdSqKQCrWsKYHrhcaAc3w6fxJAt
NZQ3rK42O9a/3d6wyzTx
=yVff
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--
