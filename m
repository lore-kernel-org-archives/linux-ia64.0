From: Rik van Riel <riel@redhat.com>
Date: Fri, 15 Jul 2016 01:04:18 +0000
Subject: Re: [PATCH v2 02/11] mm: Hardened usercopy
Message-Id: <1468544658.30053.26.camel@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-KZJAwjbKcy8GWaOESkNS"
List-Id: <linux-ia64.vger.kernel.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org>
	 <20160714232019.GA28254@350D>
In-Reply-To: <20160714232019.GA28254@350D>
To: bsingharora@gmail.com, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--=-KZJAwjbKcy8GWaOESkNS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-07-15 at 09:20 +1000, Balbir Singh wrote:

> > =3D=3D
> > +		=C2=A0=C2=A0=C2=A0((unsigned long)end & (unsigned
> > long)PAGE_MASK)))
> > +		return NULL;
> > +
> > +	/* Allow if start and end are inside the same compound
> > page. */
> > +	endpage =3D virt_to_head_page(end);
> > +	if (likely(endpage =3D=3D page))
> > +		return NULL;
> > +
> > +	/* Allow special areas, device memory, and sometimes
> > kernel data. */
> > +	if (PageReserved(page) && PageReserved(endpage))
> > +		return NULL;
>=20
> If we came here, it's likely that endpage > page, do we need to check
> that only the first and last pages are reserved? What about the ones
> in
> the middle?

I think this will be so rare, we can get away with just
checking the beginning and the end.

--=20

All Rights Reversed.
--=-KZJAwjbKcy8GWaOESkNS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXiDaSAAoJEM553pKExN6D6uIIAKN7TgG6txgGbnc5u842to8Y
3onll7X1bxNRDoiohBXsmoCTB8Taa6Ww5jduLzxsxD5jFJSjRAKpR9Dq1RLTeG+P
jKOw5tUu3KGj86rJuCpRHZF/FcPWIFode9mhcRFP+l4SucdpGY2TT4qdwuHPtkAC
+e04TCM0knAUCsZAjh1/dewujxGK45ssvdS0W9z6ASEEO07dnfbkwe10jAtAHwJ/
RpyHZAtOUyc0mpYb+JFhD1bdN1BS9YQTydVkTC2Xb33u1TYKd8mkILPs/cSe7Atk
7kZKV9BFL1qQgnUvKuTjf6pBQDf3HqAnFvgLzDG9d1niLnZ+/8/1LKoum3nLMPw=
=+jcM
-----END PGP SIGNATURE-----

--=-KZJAwjbKcy8GWaOESkNS--

