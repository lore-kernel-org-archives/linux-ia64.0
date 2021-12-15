From: Yury Norov <yury.norov@gmail.com>
Date: Wed, 15 Dec 2021 17:45:30 +0000
Subject: Re: [PATCH 2/9] lib/bitmap: implement bitmap_{empty,full} with bitmap_weight_eq()
Message-Id: <CAAH8bW-u5AsFTXUOJPRkF-6dk1LcL7PE0Tm+dUc9Ctb6JMy=tg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211128035704.270739-1-yury.norov@gmail.com> <20211128035704.270739-3-yury.norov@gmail.com>
 <YaPGDOvBzhiRFcOP@qmqm.qmqm.pl> <CAAH8bW9-dbENFUrwPUQ-uJVVX_s=PWb2zpAJ8BqkV3vJE696mA@mail.gmail.com>
 <0ccb827de1164b2989d652bfb6f1bbab@AcuMS.aculab.com>
In-Reply-To: <0ccb827de1164b2989d652bfb6f1bbab@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, "Paul E. McKenney" <paulmck@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexey Klimov <aklimov@redhat.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Andy Gross <agross@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Dennis Zhou <dennis@kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, Geetha sowjanya <gakula@marvell.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Hans de Goede <hdegoede@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Ian Rogers <irogers@google.com>, Ingo Molnar <mingo@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Jason Wessel <jason.wessel@windriver.com>, Jens Axboe <axboe@fb.com>, Jiri Olsa <jolsa@redhat.com>, Jonathan Cameron <jic23@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Kalle Valo <kvalo@codeaurora.org>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Lee Jones <lee.jones@linaro.org>, Marc Zyngier <maz@kernel.org>, Marcin Wojtas <mw@semihalf.com>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Nicholas Piggin <npiggin@gmail.com>, Palmer Dabbelt <palmer@dabbelt.com>, Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Roy Pledge <Roy.Pledge@nxp.com>, Russell King <linux@armlinux.org.uk>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Sergey Senozhatsky <senozhatsky@chromium.org>, Solomon Peachy <pizza@shaftnet.org>, Stephen Boyd <sboyd@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Subbaraya Sundeep <sbhatta@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Sunil Goutham <sgoutham@marvell.com>, Tariq Toukan <tariqt@nvidia.com>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Vineet Gupta <vgupta@kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>, "bcm-kernel-feedback-list@broadcom.com" <bcm-kernel-feedback-list@broadcom.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-perf-users@vger.kernel.org" <linux-perf-users@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Wed, Dec 15, 2021 at 12:41 AM David Laight <David.Laight@aculab.com> wrote:
>
> From: Yury Norov
> > Sent: 14 December 2021 19:43
> ...
> >
> > I think that for long bitmaps the most time consuming operation is moving
> > data to L1, and for short bitmaps the difference between approaches is
> > barely measurable.
> >
> > But hweght_long on each iteration can't be more effective than the current
> > version. So, I'll drop this patch for v2 and keep things unchanged.
>
> Actually do bitmap_full/empty() calls make any sense at all?
> The result is stale since bitmaps are designed to do locked operations.
> If you have a lock covering the bitmap then you should be using
> something that uses non-locked accesses.
> Rightly or wrongly that isn't the bitmap api.

Are you talking about __{set,clear}_bit()?
include/asm-generic/bitops/non-atomic.h
