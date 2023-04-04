From: Mike Rapoport <rppt@kernel.org>
Date: Tue, 04 Apr 2023 07:22:00 +0000
Subject: Re: [PATCH v3 02/14] arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
Message-Id: <ZCvQGJzdED+An8an@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230325060828.2662773-1-rppt@kernel.org>
 <20230325060828.2662773-3-rppt@kernel.org>
 <CAFxkdAr5C7ggZ+WdvDbsfmwuXujT_z_x3qcUnhnCn-WrAurvgA@mail.gmail.com>
In-Reply-To: <CAFxkdAr5C7ggZ+WdvDbsfmwuXujT_z_x3qcUnhnCn-WrAurvgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Justin Forbes <jforbes@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Wed, Mar 29, 2023 at 10:55:37AM -0500, Justin Forbes wrote:
> On Sat, Mar 25, 2023 at 1:09=E2=80=AFAM Mike Rapoport <rppt@kernel.org> w=
rote:
> >
> > From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> >
> > It is not a good idea to change fundamental parameters of core memory
> > management. Having predefined ranges suggests that the values within
> > those ranges are sensible, but one has to *really* understand
> > implications of changing MAX_ORDER before actually amending it and
> > ranges don't help here.
> >
> > Drop ranges in definition of ARCH_FORCE_MAX_ORDER and make its prompt
> > visible only if EXPERT=3Dy
>=20
> I do not like suddenly hiding this behind EXPERT for a couple of
> reasons.  Most importantly, it will silently change the config for
> users building with an old kernel config.  If a user has for instance
> "13" set and building with 4K pages, as is the current configuration
> for Fedora and RHEL aarch64 builds, an oldconfig build will now set it
> to 10 with no indication that it is doing so.  And while I think that
> 10 is a fine default for many aarch64 users, there are valid reasons
> for choosing other values. Putting this behind expert makes it much
> less obvious that this is an option.

That's the idea of EXPERT, no?

This option was intended to allow allocation of huge pages for
architectures that had PMD_ORDER > MAX_ORDER and not to allow user to
select size of maximal physically contiguous allocation.

Changes to MAX_ORDER fundamentally change the behaviour of core mm and
unless users *really* know what they are doing there is no reason to choose
non-default values so hiding this option behind EXPERT seems totally
appropriate to me.
=20
> Justin
>=20
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reviewed-by: Zi Yan <ziy@nvidia.com>
> > Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
> > ---
> >  arch/arm64/Kconfig | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index e60baf7859d1..7324032af859 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -1487,11 +1487,9 @@ config XEN
> >  # 16K |       27          |      14      |       13        |         1=
1         |
> >  # 64K |       29          |      16      |       13        |         1=
3         |
> >  config ARCH_FORCE_MAX_ORDER
> > -       int "Maximum zone order" if ARM64_4K_PAGES || ARM64_16K_PAGES
> > +       int "Maximum zone order" if EXPERT && (ARM64_4K_PAGES || ARM64_=
16K_PAGES)
> >         default "13" if ARM64_64K_PAGES
> > -       range 11 13 if ARM64_16K_PAGES
> >         default "11" if ARM64_16K_PAGES
> > -       range 10 15 if ARM64_4K_PAGES
> >         default "10"
> >         help
> >           The kernel memory allocator divides physically contiguous mem=
ory
> > --
> > 2.35.1
> >
> >

--=20
Sincerely yours,
Mike.
