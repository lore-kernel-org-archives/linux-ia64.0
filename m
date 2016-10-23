From: Julia Lawall <julia.lawall@lip6.fr>
Date: Sun, 23 Oct 2016 05:42:05 +0000
Subject: Re: [PATCH 6/6] IA64-sn2_smp: Combine two seq_printf() calls into one call in sn2_ptc_seq_show()
Message-Id: <alpine.DEB.2.20.1610230741400.1972@hadrien>
List-Id: <linux-ia64.vger.kernel.org>
References: <8daf03e1-5f6d-fc3b-c2db-397e6d4a9a1c@users.sourceforge.net> <c3e12189-6122-e806-6cb2-b2518e64e983@users.sourceforge.net> <1477166856.3817.4.camel@perches.com> <72f6fc41-9bf8-2eef-848f-8eefba7dade6@users.sourceforge.net>
In-Reply-To: <72f6fc41-9bf8-2eef-848f-8eefba7dade6@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Joe Perches <joe@perches.com>, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Borislav Petkov <bp@suse.de>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>, Ingo Molnar <mingo@kernel.org>, =?ISO-8859-15?Q?J=F6rg_R=F6del?= <jroedel@suse.de>, Krzysztof Kozlowski <krzk@kernel.org>, Robert Richter <rrichter@cavium.com>, Robin Murphy <robin.murphy@arm.com>, Tony Luck <tony.luck@intel.com>, Toshi Kani <toshi.kani@hpe.com>, Vineet Gupta <vgupta@synopsys.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org



On Sat, 22 Oct 2016, SF Markus Elfring wrote:

> >> @@ -494,12 +494,11 @@ static int sn2_ptc_seq_show(struct seq_file *file, void *data)
> >>  	int cpu;
> >>
> >>  	cpu = *(loff_t *) data;
> >> -
> >> -	if (!cpu) {
> >> +	if (!cpu)
> >>  		seq_printf(file,
> >> -			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2 ipi_fluches ipi_nsec\n");
> >> -		seq_printf(file, "# ptctest %d, flushopt %d\n", sn2_ptctest, sn2_flush_opt);
> >> -	}
> >> +			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2 ipi_fluches ipi_nsec\n"
> >> +			   "# ptctest %d, flushopt %d\n",
> >> +			   sn2_ptctest, sn2_flush_opt);
> >>
> >>  	if (cpu < nr_cpu_ids && cpu_online(cpu)) {
> >>  		stat = &per_cpu(ptcstats, cpu);
> >
> > Please think more.
> >
> > printf has to inspect character by character looking for
> > a vsprintf % character and 0 termination.
> >
> > seq_puts does a strlen then memcpy.
>
> Would you prefer to use this function also at this source code place?

I think that he is expecting that you will figure out the answer by
yourself.

julia
