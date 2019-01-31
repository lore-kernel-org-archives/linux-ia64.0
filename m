From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 31 Jan 2019 06:41:39 +0000
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of memblock_alloc*()
Message-Id: <20190131064139.GB28876@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
 <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
In-Reply-To: <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Petr Mladek <pmladek@suse.com>, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, devicetree@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-xtensa@linux-xtensa.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-mips@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
>=20
>=20
> Le 21/01/2019 =E0 09:04, Mike Rapoport a =E9crit=A0:
> >Add check for the return value of memblock_alloc*() functions and call
> >panic() in case of error.
> >The panic message repeats the one used by panicing memblock allocators w=
ith
> >adjustment of parameters to include only relevant ones.
> >
> >The replacement was mostly automated with semantic patches like the one
> >below with manual massaging of format strings.
> >
> >@@
> >expression ptr, size, align;
> >@@
> >ptr =3D memblock_alloc(size, align);
> >+ if (!ptr)
> >+ 	panic("%s: Failed to allocate %lu bytes align=3D0x%lx\n", __func__,
> >size, align);
> >
> >Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
> >Acked-by: Paul Burton <paul.burton@mips.com>	     # MIPS
> >Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
> >Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
> >---
>=20
> [...]
>=20
> >diff --git a/mm/sparse.c b/mm/sparse.c
> >index 7ea5dc6..ad94242 100644
> >--- a/mm/sparse.c
> >+++ b/mm/sparse.c
>=20
> [...]
>=20
> >@@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned long=
 size, int nid)
> >  		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
> >  						__pa(MAX_DMA_ADDRESS),
> >  						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> >+	if (!sparsemap_buf)
> >+		panic("%s: Failed to allocate %lu bytes align=3D0x%lx nid=3D%d from=
=3D%lx\n",
> >+		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
> >+
>=20
> memblock_alloc_try_nid_raw() does not panic (help explicitly says: Does n=
ot
> zero allocated memory, does not panic if request cannot be satisfied.).

"Does not panic" does not mean it always succeeds.
=20
> Stephen Rothwell reports a boot failure due to this change.

Please see my reply on that thread.

> Christophe
>=20
> >  	sparsemap_buf_end =3D sparsemap_buf + size;
> >  }
> >
>=20

--=20
Sincerely yours,
Mike.
