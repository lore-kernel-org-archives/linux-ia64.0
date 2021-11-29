From: Yury Norov <yury.norov@gmail.com>
Date: Mon, 29 Nov 2021 06:38:39 +0000
Subject: Re: [PATCH 0/9] lib/bitmap: optimize bitmap_weight() usage
Message-Id: <20211129063839.GA338729@lapt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211128035704.270739-1-yury.norov@gmail.com>
 <YaPEfZ0t9UFGwpml@qmqm.qmqm.pl>
In-Reply-To: <YaPEfZ0t9UFGwpml@qmqm.qmqm.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mirq-test@rere.qmqm.pl
Cc: linux-kernel@vger.kernel.org, Yury Norov <yury.norov@gmail.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, "Paul E. McKenney" <paulmck@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexey Klimov <aklimov@redhat.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Andy Gross <agross@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Laight <David.Laight@aculab.com>, Dennis Zhou <dennis@kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, Geetha sowjanya <gakula@marvell.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Hans de Goede <hdegoede@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Ian Rogers <irogers@google.com>, Ingo Molnar <mingo@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Jason Wessel <jason.wessel@windriver.com>, Jens Axboe <axboe@fb.com>, Jiri Olsa <jolsa@redhat.com>, Jonathan Cameron <jic23@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Kalle Valo <kvalo@codeaurora.org>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Lee Jones <lee.jones@linaro.org>, Marc Zyngier <maz@kernel.org>, Marcin Wojtas <mw@semihalf.com>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Nicholas Piggin <npiggin@gmail.com>, Palmer Dabbelt <palmer@dabbelt.com>, Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Roy Pledge <Roy.Pledge@nxp.com>, Russell King <linux@armlinux.org.uk>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Sergey Senozhatsky <senozhatsky@chromium.org>, Solomon Peachy <pizza@shaftnet.org>, Stephen Boyd <sboyd@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Subbaraya Sundeep <sbhatta@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Sunil Goutham <sgoutham@marvell.com>, Tariq Toukan <tariqt@nvidia.com>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Vineet Gupta <vgupta@kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>, bcm-kernel-feedback-list@broadcom.com, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

On Sun, Nov 28, 2021 at 07:03:41PM +0100, mirq-test@rere.qmqm.pl wrote:
> On Sat, Nov 27, 2021 at 07:56:55PM -0800, Yury Norov wrote:
> > In many cases people use bitmap_weight()-based functions like this:
> > 
> > 	if (num_present_cpus() > 1)
> > 		do_something();
> > 
> > This may take considerable amount of time on many-cpus machines because
> > num_present_cpus() will traverse every word of underlying cpumask
> > unconditionally.
> > 
> > We can significantly improve on it for many real cases if stop traversing
> > the mask as soon as we count present cpus to any number greater than 1:
> > 
> > 	if (num_present_cpus_gt(1))
> > 		do_something();
> > 
> > To implement this idea, the series adds bitmap_weight_{eq,gt,le}
> > functions together with corresponding wrappers in cpumask and nodemask.
> 
> Having slept on it I have more structured thoughts:
> 
> First, I like substituting bitmap_empty/full where possible - I think
> the change stands on its own, so could be split and sent as is.

Ok, I can do it.

> I don't like the proposed API very much. One problem is that it hides
> the comparison operator and makes call sites less readable:
> 
> 	bitmap_weight(...) > N
> 
> becomes:
> 
> 	bitmap_weight_gt(..., N)
> 
> and:
> 	bitmap_weight(...) <= N
> 
> becomes:
> 
> 	bitmap_weight_lt(..., N+1)
> or:
> 	!bitmap_weight_gt(..., N)
> 
> I'd rather see something resembling memcmp() API that's known enough
> to be easier to grasp. For above examples:
> 
> 	bitmap_weight_cmp(..., N) > 0
> 	bitmap_weight_cmp(..., N) <= 0
> 	...

bitmap_weight_cmp() cannot be efficient. Consider this example:

bitmap_weight_lt(1000 0000 0000 0000, 1) = false
                 ^
                 stop here

bitmap_weight_cmp(1000 0000 0000 0000, 1) = 0
                                 ^
                                 stop here

I agree that '_gt' is less verbose than '>', but the advantage of 
'_gt' over '>' is proportional to length of bitmap, and it means
that this API should exist.

> This would also make the implementation easier in not having to
> copy and paste the code three times. Could also use a simple
> optimization reducing code size:

In the next version I'll reduce code duplication like this:

bool bitmap_eq(..., N);
bool bitmap_ge(..., N);

#define bitmap_weight_gt(..., N)  bitmap_weight_ge(..., N + 1)
#define bitmap_weight_lt(..., N) !bitmap_weight_ge(..., N)
#define bitmap_weight_le(..., N) !bitmap_weight_gt(..., N)

Thanks,
Yury
