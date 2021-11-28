From: Yury Norov <yury.norov@gmail.com>
Date: Sun, 28 Nov 2021 23:36:27 +0000
Subject: Re: [PATCH 0/9] lib/bitmap: optimize bitmap_weight() usage
Message-Id: <20211128233627.GA323159@lapt>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211128035704.270739-1-yury.norov@gmail.com>
 <1638096766.3elxdzb8ly.astroid@bobo.none>
In-Reply-To: <1638096766.3elxdzb8ly.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Andy Gross <agross@kernel.org>, David Airlie <airlied@linux.ie>, Alexey Klimov <aklimov@redhat.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Jens Axboe <axboe@fb.com>, bcm-kernel-feedback-list@broadcom.com, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@ACULAB.COM>, Dennis Zhou <dennis@kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, Geetha sowjanya <gakula@marvell.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, Hans de Goede <hdegoede@redhat.com>, Ian Rogers <irogers@google.com>, Jason Wessel <jason.wessel@windriver.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, Jonathan Cameron <jic23@kernel.org>, Jiri Olsa <jolsa@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Jakub Kicinski <kuba@kernel.org>, Kalle Valo <kvalo@codeaurora.org>, kvm@vger.kernel.org, Lee Jones <lee.jones@linaro.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, linux-crypto@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, Andy Lutomirski <luto@kernel.org>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Marc Zyngier <maz@kernel.org>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Marcin Wojtas <mw@semihalf.com>, Palmer Dabbelt <palmer@dabbelt.com>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Solomon Peachy <pizza@shaftnet.org>, Petr Mladek <pmladek@suse.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roy Pledge <Roy.Pledge@nxp.com>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Subbaraya Sundeep <sbhatta@marvell.com>, Stephen Boyd <sboyd@kernel.org>, Sergey Senozhatsky <senozhatsky@chromium.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Sunil Goutham <sgoutham@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Tariq Toukan <tariqt@nvidia.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@kernel.org>, Vincent Guittot <vincent.guittot@linaro.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Will Deacon <will@kernel.org>

On Sun, Nov 28, 2021 at 09:08:41PM +1000, Nicholas Piggin wrote:
> Excerpts from Yury Norov's message of November 28, 2021 1:56 pm:
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
> There would be no change to callers if you maintain counters like what
> is done for num_online_cpus() today. Maybe some fixes to arch code that
> does not use set_cpu_possible() etc APIs required, but AFAIKS it would
> be better to fix such cases anyway.

Thanks, Nick. I'll try to do this.
