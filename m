From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 07 Jun 2019 12:03:26 +0000
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <20190607220326.1e21fc9c@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/f4dkIceQ5ZrfVlbLmfAkblH"
List-Id: <linux-ia64.vger.kernel.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Anshuman,

On Fri,  7 Jun 2019 16:04:15 +0530 Anshuman Khandual <anshuman.khandual@arm=
.com> wrote:
>
> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
> +					      unsigned int trap)
> +{
> +	int ret =3D 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret =3D 1;
> +	}
> +	return ret;
> +}

Since this is now declared as "bool" (thanks for that), you should make
"ret" be bool and use true and false;

--=20
Cheers,
Stephen Rothwell

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz6Uo4ACgkQAVBC80lX
0GwAlwgAndGNjcRg/+OZtSy1kiUIeIc3sDi7Ok5AjcBz7eTGTC6rACK7/CqF74Ff
Hw76yMUeoSjtJWLlhqmY0XI4ib30yQJSvSSWJyDvZpmgkDbNO69BK4rT4CO/d2YX
sCodILuUU462hNmmfr9N6uWJGSeDWdEvbfitkR2PEzQAUSsQacEA8UB+bqf+zQ13
xwBTJEE0YFg5UCqOcsE3bSTh/e+p7djYHrQIiZX0ntJOra+nJZuz/GfJQUmx4WYn
AHgcP+Marnv0/MW4JDWYDtetq+Fmr96wk01Ex4gMytm7TcpL0asnQ0IEVwljvVr/
HFKp+ZJLlwZP8lyt90zY76EEDgViPQ==
=7Lk0
-----END PGP SIGNATURE-----

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH--
