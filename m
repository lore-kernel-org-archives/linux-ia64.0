From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 16 Oct 2019 08:20:22 +0000
Subject: Re: [PATCH V6 0/2] mm/debug: Add tests validating architecture page table helpers
Message-Id: <20191016082022.GN317@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1571131302-32290-1-git-send-email-anshuman.khandual@arm.com>
 <1571150502.5937.39.camel@lca.pw>
 <c052784a-a5d7-878e-cd97-01daa90c0ed8@arm.com>
In-Reply-To: <c052784a-a5d7-878e-cd97-01daa90c0ed8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Qian Cai <cai@lca.pw>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue 15-10-19 20:51:11, Anshuman Khandual wrote:
>=20
>=20
> On 10/15/2019 08:11 PM, Qian Cai wrote:
> > The x86 will crash with linux-next during boot due to this series (v5) =
with the
> > config below plus CONFIG_DEBUG_VM_PGTABLE=3Dy. I am not sure if v6 woul=
d address
> > it.
> >=20
> > https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config
> >=20
> > [=A0=A0=A033.862600][=A0=A0=A0=A0T1] page:ffffea0009000000 is uninitial=
ized and poisoned
> > [=A0=A0=A033.862608][=A0=A0=A0=A0T1] raw: ffffffffffffffff ffffffffffff=
ffff ffffffffffffffff
> > ffffff871140][=A0=A0=A0=A0T1]=A0=A0? _raw_spin_unlock_irq+0x27/0x40
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1]=A0=A0? rest_init+0x307/0x307
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1]=A0=A0kernel_init+0x11/0x139
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1]=A0=A0? rest_init+0x307/0x307
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1]=A0=A0ret_from_fork+0x27/0x50
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1] Modules linked in:
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1] ---[ end trace e99d392b0f7befbd ]-=
--
> > [=A0=A0=A033.871140][=A0=A0=A0=A0T1] RIP: 0010:alloc_gigantic_page_orde=
r+0x3fe/0x490
>=20
> Hmm, with defconfig (DEBUG_VM=3Dy and DEBUG_VM_PGTABLE=3Dy) it does not c=
rash but
> with the config above, it does. Just wondering if it is possible that the=
se
> pages might not been initialized yet because DEFERRED_STRUCT_PAGE_INIT=3D=
y ?

Quite likely. You need to wait for page_alloc_init_late to finish.
>=20
> [   13.898549][    T1] page:ffffea0005000000 is uninitialized and poisoned
> [   13.898549][    T1] raw: ffffffffffffffff ffffffffffffffff fffffffffff=
fffff ffffffffffffffff
> [   13.898549][    T1] raw: ffffffffffffffff ffffffffffffffff fffffffffff=
fffff ffffffffffffffff
> [   13.898549][    T1] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p=
))
> [   13.898549][    T1] ------------[ cut here ]------------
> [   13.898549][    T1] kernel BUG at ./include/linux/mm.h:1107!
> [   13.898549][    T1] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASA=
N PTI
> [   13.898549][    T1] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.4.0-rc=
3-next-20191015+ #

--=20
Michal Hocko
SUSE Labs
