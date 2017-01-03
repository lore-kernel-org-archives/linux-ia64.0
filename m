From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Tue, 03 Jan 2017 21:27:44 +0000
Subject: Re: [PATCH v5 09/14] jump_label: port __jump_table to linker tables
Message-Id: <20170103212744.GF13946@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <20161222023811.21246-1-mcgrof@kernel.org>
 <20161222023811.21246-10-mcgrof@kernel.org>
 <1482415702.9552.125.camel@linux.intel.com>
In-Reply-To: <1482415702.9552.125.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: gnomes@lxorguk.ukuu.org.uk, dalias@libc.org, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, mpe@ellerman.id.au, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, david.vrabel@citrix.com, linux-xte

On Thu, Dec 22, 2016 at 04:08:22PM +0200, Andy Shevchenko wrote:
> On Wed, 2016-12-21 at 18:38 -0800, Luis R. Rodriguez wrote:
> > Move the __jump_table from the a custom section solution
> > to a generic solution, this avoiding extra vmlinux.lds.h
> > customizations.
> >=20
> > This also demos the use of the .data linker table and of
> > the shared asm call push_section_tbl().
> >=20
>=20
> > =A0{
> > =A0	asm_volatile_goto("1:\n\t"
> > =A0		=A0WASM(nop) "\n\t"
> > -		=A0".pushsection __jump_table,=A0=A0\"aw\"\n\t"
> > +		=A0push_section_tbl_any(.data, __jump_table, aw)
> > =A0		=A0".word 1b, %l[l_yes], %c0\n\t"
> > =A0		=A0".popsection\n\t"
> > =A0		=A0: :=A0=A0"i" (&((char *)key)[branch]) :=A0=A0: l_yes);
> > @@ -26,7 +28,7 @@ static __always_inline bool
> > arch_static_branch_jump(struct static_key *key, bool
> > =A0{
> > =A0	asm_volatile_goto("1:\n\t"
> > =A0		=A0WASM(b) " %l[l_yes]\n\t"
> > -		=A0".pushsection __jump_table,=A0=A0\"aw\"\n\t"
> > +		=A0push_section_tbl_any(.data, __jump_table, aw)
> > =A0		=A0".word 1b, %l[l_yes], %c0\n\t"
> > =A0		=A0".popsection\n\t"
>=20
> Does it make sense to introduce something like
>=20
> #define pop_section_tbl ".popsection\n\t"
> #define pop_section_tbl_any pop_section_tbl

Absolutely ! However this would be an evolution, and I would much
prefer to add this later as an atomic step later to enable other
users to also be using this shared macro. I did not have an immediate
need for a pop_section_tbl() macro as its not section specific.

  Luis
