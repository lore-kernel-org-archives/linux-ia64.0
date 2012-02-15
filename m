From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 15 Feb 2012 23:22:49 +0000
Subject: Re: [PATCH v2] arch/ia64: remove references to cpu_*_map.
Message-Id: <87k43nbsli.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4F3B8EAE.4050809@linux.vnet.ibm.com> <20120215130240.7308f373.akpm@linux-foundation.org>
In-Reply-To: <20120215130240.7308f373.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Gortmaker <paul.gortmaker@windriver.com>, Gilad Ben-Yossef <gilad@benyossef.com>

On Wed, 15 Feb 2012 13:02:40 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 15 Feb 2012 16:23:34 +0530
> "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:
> 
> > This patch ought to go along with the patchsets that do cleanups in other
> > architectures as well.. And it looks like Rusty's patchset[1] is a superset of
> > Venki's patchset[2].. So, Rusty, would you kindly take this patch into your
> > patchset? (It should come before the 11/12 in your patchset. This should apply
> > at that point easily, because I have modified it to suit your 11/12 which also
> > touches ia64).
> 
> OK, I'm officially all confused.  I think I'll drop everything and wait
> until it settles down.  Please, someone prepare a single patch series.
> 
> The cpumask-related patches whcih I'm currently holding are:
> 
> smp-introduce-a-generic-on_each_cpu_mask-function.patch
> #arm-move-arm-over-to-generic-on_each_cpu_mask.patch: fold
> arm-move-arm-over-to-generic-on_each_cpu_mask.patch
> #tile-move-tile-to-use-generic-on_each_cpu_mask.patch: fold
> tile-move-tile-to-use-generic-on_each_cpu_mask.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func-fix.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func-update.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func-update-fix.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func-v9.patch
> smp-add-func-to-ipi-cpus-based-on-parameter-func-v9-fix.patch
> slub-only-ipi-cpus-that-have-per-cpu-obj-to-flush.patch
> fs-only-send-ipi-to-invalidate-lru-bh-when-needed.patch
> mm-only-ipi-cpus-to-drain-local-pages-if-they-exist.patch
> mm-only-ipi-cpus-to-drain-local-pages-if-they-exist-update.patch
> mm-only-ipi-cpus-to-drain-local-pages-if-they-exist-v9.patch
> #
> arch-ia64-remove-references-to-cpu__map.patch
> cpumask-avoid-mask-based-num_possible_cpus-and-num_online_cpus.patch
> 
> So I'm thinking the thing to do is to drop just the final two?

Keep them all, I'll rebase on top of linux-next, and send you a few
patches.  I'm not going to break down by arch, that was just in the hope
that the arch maintainers themselves would take them...

Thanks,
Rusty.
