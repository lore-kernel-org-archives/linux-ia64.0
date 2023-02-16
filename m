From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 16 Feb 2023 19:34:42 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <Y+6FUoMdLYyG71Il@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 16, 2023 at 11:17:55AM -0800, Guenter Roeck wrote:
> It isn't just that. Trying to build ia64:allmodconfig with gcc 11.2
> fails due to build warning(s) which are now errors, and the same
> build with gcc 11.3 or later (and binutils 2.32 or later) fails
> completely with
>     Error: Register number out of range 0..1
> and similar all over the place. So there isn't just code bitrot,
> there is also compiler and/or binutils bitrot.

FWIW, ia64-unknown-linux-gnu was removed as a secondary platform between
the gcc-4.6 and gcc-4.7 releases (around 2012).  So this part of the
release criteria no longer applies:

: Our release criteria for the secondary platforms is:
: 
:     The compiler bootstraps successfully, and the C++ runtime library builds.
:     The DejaGNU testsuite has been run, and a substantial majority of the tests pass.

Linux does support a lot of platforms which are tertiary platforms,
of course.  Alpha, arc, csky, hexagon, loongarch, m68k, microblaze,
nios2, openrisc, parisc, riscv, sh and xtensa are all tertiary.  But
even Debian don't ship an x86->ia64 cross-gcc.
