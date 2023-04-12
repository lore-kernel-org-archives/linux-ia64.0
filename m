From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 12 Apr 2023 17:27:08 +0000
Subject: Re: [PATCH v3 02/14] arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
Message-Id: <ZDbp7LAHES3YFo30@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230325060828.2662773-1-rppt@kernel.org>
 <20230325060828.2662773-3-rppt@kernel.org>
 <CAFxkdAr5C7ggZ+WdvDbsfmwuXujT_z_x3qcUnhnCn-WrAurvgA@mail.gmail.com>
 <ZCvQGJzdED+An8an@kernel.org>
 <CAFbkSA38eTA_iJ3ttBvQ8G4Rjj8qB12GxY7Z=qmZ8wm+0tZieA@mail.gmail.com>
In-Reply-To: <CAFbkSA38eTA_iJ3ttBvQ8G4Rjj8qB12GxY7Z=qmZ8wm+0tZieA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Justin Forbes <jforbes@fedoraproject.org>
Cc: Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Tue, Apr 04, 2023 at 06:50:01AM -0500, Justin Forbes wrote:
> On Tue, Apr 4, 2023 at 2:22 AM Mike Rapoport <rppt@kernel.org> wrote:
> > On Wed, Mar 29, 2023 at 10:55:37AM -0500, Justin Forbes wrote:
> > > On Sat, Mar 25, 2023 at 1:09 AM Mike Rapoport <rppt@kernel.org> wrote:
> > > >
> > > > From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> > > >
> > > > It is not a good idea to change fundamental parameters of core memory
> > > > management. Having predefined ranges suggests that the values within
> > > > those ranges are sensible, but one has to *really* understand
> > > > implications of changing MAX_ORDER before actually amending it and
> > > > ranges don't help here.
> > > >
> > > > Drop ranges in definition of ARCH_FORCE_MAX_ORDER and make its prompt
> > > > visible only if EXPERT=y
> > >
> > > I do not like suddenly hiding this behind EXPERT for a couple of
> > > reasons.  Most importantly, it will silently change the config for
> > > users building with an old kernel config.  If a user has for instance
> > > "13" set and building with 4K pages, as is the current configuration
> > > for Fedora and RHEL aarch64 builds, an oldconfig build will now set it
> > > to 10 with no indication that it is doing so.  And while I think that
> > > 10 is a fine default for many aarch64 users, there are valid reasons
> > > for choosing other values. Putting this behind expert makes it much
> > > less obvious that this is an option.
> >
> > That's the idea of EXPERT, no?
> >
> > This option was intended to allow allocation of huge pages for
> > architectures that had PMD_ORDER > MAX_ORDER and not to allow user to
> > select size of maximal physically contiguous allocation.
> >
> > Changes to MAX_ORDER fundamentally change the behaviour of core mm and
> > unless users *really* know what they are doing there is no reason to choose
> > non-default values so hiding this option behind EXPERT seems totally
> > appropriate to me.
> 
> It sounds nice in theory. In practice. EXPERT hides too much. When you
> flip expert, you expose over a 175ish new config options which are
> hidden behind EXPERT.  You don't have to know what you are doing just
> with the MAX_ORDER, but a whole bunch more as well.  If everyone were
> already running 10, this might be less of a problem. At least Fedora
> and RHEL are running 13 for 4K pages on aarch64. This was not some
> accidental choice, we had to carry a patch to even allow it for a
> while.  If this does go in as is, we will likely just carry a patch to
> remove the "if EXPERT", but that is a bit of a disservice to users who
> might be trying to debug something else upstream, bisecting upstream
> kernels or testing a patch.  In those cases, people tend to use
> pristine upstream sources without distro patches to verify, and they
> tend to use their existing configs. With this change, their MAX_ORDER
> will drop to 10 from 13 silently.   That can look like a different
> issue enough to ruin a bisect or have them give bad feedback on a
> patch because it introduces a "regression" which is not a regression
> at all, but a config change they couldn't see.

If we remove EXPERT (as prior to this patch), I'd rather keep the ranges
and avoid having to explain to people why some random MAX_ORDER doesn't
build (keeping the range would also make sense for randconfig, not sure
we got to any conclusion there).

-- 
Catalin
