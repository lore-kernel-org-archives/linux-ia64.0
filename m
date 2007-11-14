From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 14 Nov 2007 14:35:16 +0000
Subject: Re: perfmon Itanium 9100 series support (Montvale)
Message-Id: <20071114143516.GI6557@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071113223401.GI5747@frankl.hpl.hp.com>
In-Reply-To: <20071113223401.GI5747@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 14, 2007 at 08:30:14AM -0600, Russ Anderson wrote:
> On Tue, Nov 13, 2007 at 02:34:01PM -0800, Stephane Eranian wrote:
> > Hello everyone,
> > 
> > Intel released the Itanium 9100 series (Montvale) a few days ago.
> > 
> > My understanding is that the Montvale PMU is fully compatible with
> > the Montecito PMU (dual-core Itanium 9000 series). Thus, there will
> > not be any patches needed neither at the kernel level, nor in libpfm
> > or pfmon to support this new processor.
> 
> Perfmon prints out "Montecito PMU" when booted on a Montvale.
> Updating the message may avoid some confusion.
> 
Yes, because it prints the PMU model not the processor model.
On Madison, it prints Itanium 2.

> ---
> perfmon: version 2.0 IRQ 238
> perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
> ---
> 
> Both Montvale and Montecito are family 32.  Montvale is model 1.
> Montecito is model 0.
> 
> ---
> saturn1-10:~ # cat /proc/cpuinfo
> processor  : 0
> vendor     : GenuineIntel
> arch       : IA-64
> family     : 32
> model      : 1
> model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
> [...]
> processor  : 4
> vendor     : GenuineIntel
> arch       : IA-64
> family     : 32
> model      : 0
> model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9040
> ---
>  
> > Those comments hold true for the mainline perfmon (v2.0) and
> > the development perfmon in GIT (v2.7).
> 
> Thanks,
> -- 
> Russ Anderson, OS RAS/Partitioning Project Lead  
> SGI - Silicon Graphics Inc          rja@sgi.com

-- 

-Stephane
