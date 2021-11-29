From: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Date: Mon, 29 Nov 2021 16:34:07 +0000
Subject: Re: [PATCH 0/9] lib/bitmap: optimize bitmap_weight() usage
Message-Id: <3CD9ECD8-901E-497B-9AE1-0DDB02346892@rere.qmqm.pl>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211128035704.270739-1-yury.norov@gmail.com>
 <YaPEfZ0t9UFGwpml@qmqm.qmqm.pl> <20211129063839.GA338729@lapt>
In-Reply-To: <20211129063839.GA338729@lapt>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Yury Norov <yury.norov@gmail.com>
Cc: linux-kernel@vger.kernel.org, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Paul E. McKenney" <paulmck@kernel.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Russell King <linux@armlinux.org.uk>, Amitkumar Karwar <amitkarwar@gmail.com>, Alexey Klimov <aklimov@redhat.com>, linux-alpha@vger.kernel.org, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andy Gross <agross@kernel.org>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Andrew Lunn <andrew@lunn.ch>, Andi Kleen <ak@linux.intel.com>, Tejun Heo <tj@kernel.org>, Ard Biesheuvel <ardb@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Anup Patel <anup.patel@wdc.com>, linux-ia64@vger.kernel.org, Andy Shevchenko <andy@infradead.org>, Andy Lutomirski <luto@kernel.org>, Matti Vaittinen <mazziesaccount@gmail.com>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@dabbelt.com>, Catalin Marinas <catalin.marinas@arm.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Borislav Petkov <bp@alien8.de>, Arnd Bergmann <arnd@arndb.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, David Laight <David.Laight@aculab.com>, Sunil Goutham <sgoutham@marvell.com>, David Airlie <airlied@linux.ie>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Viresh Kumar <viresh.kumar@linaro.org>, Daniel Vetter <daniel@ffwll.ch>, bcm-kernel-feedback-list@broadcom.com, Christoph Lameter <cl@linux.com>, linux-crypto@vger.kernel.org, Hans de Goede <hdegoede@redhat.com>, linux-mm@kvack.org, Guo Ren <guoren@kernel.org>, linux-snps-arc@lists.infradead.org, Geetha sowjanya <gakula@marvell.com>, Mark Rutland <mark.rutland@arm.com>, Dinh Nguyen <dinguyen@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, Dennis Zhou <dennis@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <hca@linux.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Randy Dunlap <rdunlap@infradead.org>, Roy Pledge <Roy.Pledge@nxp.com>, Saeed Mahameed <saeedm@nvidia.com>, Jens Axboe <axboe@fb.com>, Jason Wessel <jason.wessel@windriver.com>, Jakub Kicinski <kuba@kernel.org>, Sergey Senozhatsky <senozhatsky@chromium.org>, Ingo Molnar <mingo@redhat.com>, Stephen Boyd <sboyd@kernel.org>, Ian Rogers <irogers@google.com>, Steven Rostedt <rostedt@goodmis.org>, Sagi Grimberg <sagi@grimberg.me>, Sudeep Holla <sudeep.holla@arm.com>, Kalle Valo <kvalo@codeaurora.org>, Tariq Toukan <tariqt@nvidia.com>, Juri Lelli <juri.lelli@redhat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Jonathan Cameron <jic23@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, Jiri Olsa <jolsa@redhat.com>, Vineet Gupta <vgupta@kernel.org>, Solomon Peachy <pizza@shaftnet.org>, Vivien Didelot <vivien.didelot@gmail.com>, Lee Jones <lee.jones@linaro.org>, Will Deacon <will@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, kvm@vger.kernel.org, Kees Cook <keescook@chromium.org>, linux-arm-kernel@lists.infradead.org, Subbaraya Sundeep <sbhatta@marvell.com>, linux-csky@vger.kernel.org, Marcin Wojtas <mw@semihalf.com>, linux-mips@vger.kernel.org, Marc Zyngier <maz@kernel.org>, linux-perf-users@vger.kernel.org, Vincent Guittot <vincent.guittot@linaro.org>, linux-s390@vger.kernel.org, Mark Gross <markgross@kernel.org>, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

Dnia 29 listopada 2021 06:38:39 UTC, Yury Norov <yury.norov@gmail.com> napisał/a:
>On Sun, Nov 28, 2021 at 07:03:41PM +0100, mirq-test@rere.qmqm.pl wrote:
>> On Sat, Nov 27, 2021 at 07:56:55PM -0800, Yury Norov wrote:
>> > In many cases people use bitmap_weight()-based functions like this:
>> > 
>> > 	if (num_present_cpus() > 1)
>> > 		do_something();
>> > 
>> > This may take considerable amount of time on many-cpus machines because
>> > num_present_cpus() will traverse every word of underlying cpumask
>> > unconditionally.
>> > 
>> > We can significantly improve on it for many real cases if stop traversing
>> > the mask as soon as we count present cpus to any number greater than 1:
>> > 
>> > 	if (num_present_cpus_gt(1))
>> > 		do_something();
>> > 
>> > To implement this idea, the series adds bitmap_weight_{eq,gt,le}
>> > functions together with corresponding wrappers in cpumask and nodemask.
>> 
>> Having slept on it I have more structured thoughts:
>> 
>> First, I like substituting bitmap_empty/full where possible - I think
>> the change stands on its own, so could be split and sent as is.
>
>Ok, I can do it.
>
>> I don't like the proposed API very much. One problem is that it hides
>> the comparison operator and makes call sites less readable:
>> 
>> 	bitmap_weight(...) > N
>> 
>> becomes:
>> 
>> 	bitmap_weight_gt(..., N)
>> 
>> and:
>> 	bitmap_weight(...) <= N
>> 
>> becomes:
>> 
>> 	bitmap_weight_lt(..., N+1)
>> or:
>> 	!bitmap_weight_gt(..., N)
>> 
>> I'd rather see something resembling memcmp() API that's known enough
>> to be easier to grasp. For above examples:
>> 
>> 	bitmap_weight_cmp(..., N) > 0
>> 	bitmap_weight_cmp(..., N) <= 0
>> 	...
>
>bitmap_weight_cmp() cannot be efficient. Consider this example:
>
>bitmap_weight_lt(1000 0000 0000 0000, 1) == false
>                 ^
>                 stop here
>
>bitmap_weight_cmp(1000 0000 0000 0000, 1) == 0
>                                 ^
>                                 stop here
>
>I agree that '_gt' is less verbose than '>', but the advantage of 
>'_gt' over '>' is proportional to length of bitmap, and it means
>that this API should exist.

Thank you for the example. Indeed, for less-than to be efficient here you would need to replace
 bitmap_weight_cmp(..., N) < 0
with
 bitmap_weight_cmp(..., N-1) <= 0

It would still be more readable, I think.

Best Regards
Michał Mirosław
