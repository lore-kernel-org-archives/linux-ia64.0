From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 15 Jul 2016 01:41:51 +0000
Subject: Re: [PATCH v2 02/11] mm: Hardened usercopy
Message-Id: <20160715014151.GA13944@balbir.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org>
 <20160714232019.GA28254@350D>
 <1468544658.30053.26.camel@redhat.com>
In-Reply-To: <1468544658.30053.26.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Rik van Riel <riel@redhat.com>
Cc: bsingharora@gmail.com, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Thu, Jul 14, 2016 at 09:04:18PM -0400, Rik van Riel wrote:
> On Fri, 2016-07-15 at 09:20 +1000, Balbir Singh wrote:
>=20
> > > =3D
> > > +		=A0=A0=A0((unsigned long)end & (unsigned
> > > long)PAGE_MASK)))
> > > +		return NULL;
> > > +
> > > +	/* Allow if start and end are inside the same compound
> > > page. */
> > > +	endpage =3D virt_to_head_page(end);
> > > +	if (likely(endpage =3D page))
> > > +		return NULL;
> > > +
> > > +	/* Allow special areas, device memory, and sometimes
> > > kernel data. */
> > > +	if (PageReserved(page) && PageReserved(endpage))
> > > +		return NULL;
> >=20
> > If we came here, it's likely that endpage > page, do we need to check
> > that only the first and last pages are reserved? What about the ones
> > in
> > the middle?
>=20
> I think this will be so rare, we can get away with just
> checking the beginning and the end.
>

But do we want to leave a hole where an aware user space
can try a longer copy_* to avoid this check? If it is unlikely
should we just bite the bullet and do the check for the entire
range?

Balbir Singh.=20


