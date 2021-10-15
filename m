From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 15 Oct 2021 13:04:50 +0000
Subject: Re: [PATCH 2/2] sched: Centralize SCHED_{SMT, MC, CLUSTER} definitions
Message-Id: <YWl8cogsS2Lah1mk@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211008115347.425234-1-valentin.schneider@arm.com>
 <20211008115347.425234-3-valentin.schneider@arm.com>
 <CAGsJ_4wqtcOdsFDzR98PFbjxRyTqzf7P3p3erup84SXESYonYw@mail.gmail.com>
 <87bl3zlex8.mognet@arm.com>
In-Reply-To: <87bl3zlex8.mognet@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <valentin.schneider@arm.com>
Cc: Barry Song <21cnbao@gmail.com>, LKML <linux-kernel@vger.kernel.org>, LAK <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Aubrey Li <aubrey.li@linux.intel.com>, Barry Song <song.bao.hua@hisilicon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Jonathan Cameron <jonathan.cameron@huawei.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86 <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Mike Rapoport <rppt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ardb@kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>, Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, Kefeng Wang <wangkefeng.wang@huawei.com>, Sergei Trofimovich <slyfox@gentoo.org>, David Hildenbrand <david@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Masahiro Yamada <masahiroy@kernel.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Chris Down <chris@chrisdown.name>, Vipin Sharma <vipinsh@google.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Daniel Borkmann <daniel@iogearbox.net>, Vlastimil Babka <vbabka@suse.cz>, Frederic Weisbecker <frederic@kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Oct 08, 2021 at 04:22:27PM +0100, Valentin Schneider wrote:

> So x86 has it default yes, and a lot of others (e.g. arm64) have it default
> no.
> 
> IMO you don't gain much by disabling them. SCHED_MC and SCHED_CLUSTER only
> control the presence of a sched_domain_topology_level - if it's useless it
> gets degenerated at domain build time. Some valid reasons for not using
> them is if the architecture defines its own topology table (e.g. powerpc
> has CACHE and MC levels which are not gated behind any CONFIG).
> 
> SCHED_SMT has an impact on code generated in sched/core.c, but that is also
> gated by a static key.
> 
> So I'd say having them default yes is sensible. I'd even say we should
> change the "If unsure say N here." to "Y".

Right, so I tend to agree (and also that we should fix that Kconfig help
text). But it would be very nice to have feedback from the affected arch
maintainers.
