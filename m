From: Matthew Wilcox <willy@debian.org>
Date: Tue, 09 Dec 2003 01:24:01 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107093306406202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 09, 2003 at 11:17:56AM +1100, Peter Chubb wrote:
> Here's a  fix for non-preemption safety in perfmon.c.
> 
> I haven't tried it while running a preemption stress test, but this
> allows q-syscollect to work.
> 
> === arch/ia64/kernel/perfmon.c 1.67 vs edited ==> --- 1.67/arch/ia64/kernel/perfmon.c   Tue Oct 28 17:36:50 2003
> +++ edited/arch/ia64/kernel/perfmon.c Tue Dec  9 10:55:58 2003
> @@ -5475,7 +5475,7 @@
> 	int this_cpu;
> 	int ret;
>  
> -	this_cpu = smp_processor_id();
> +	this_cpu = get_cpu();
> 	min      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
> 	max      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;

surely there needs to be a matching put_cpu() or else preempt is forever
disabled.  no?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
