From: Matthew Wilcox <willy@debian.org>
Date: Tue, 04 Nov 2003 23:04:28 +0000
Subject: Re: percpu data for non-existant cpus
Message-Id: <marc-linux-ia64-106798708313933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106790736528585@msgid-missing>
In-Reply-To: <marc-linux-ia64-106790736528585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 04, 2003 at 10:43:49AM +0900, Takayoshi Kochi wrote:
> --- linux-2.6.0-test6.orig/arch/ia64/mm/tlb.c	Sun Sep 28 09:50:38 2003
> +++ linux-2.6.0-test6/arch/ia64/mm/tlb.c	Wed Oct  8 17:58:42 2003
> @@ -77,7 +77,7 @@
>  	{
>  		int cpu = get_cpu(); /* prevent preemption/migration */
>  		for (i = 0; i < NR_CPUS; ++i)
> -			if (i != cpu)
> +			if (cpu_online(i) && (i != cpu))
>  				per_cpu(ia64_need_tlb_flush, i) = 1;
>  		put_cpu();
>  	}

Surely this should rather be...

	{
		int cpu = get_cpu(); /* prevent preemption/migration */
-		for (i = 0; i < NR_CPUS; ++i)
+		for_each_cpu(i, cpu_online_map)
			if (i != cpu)
				per_cpu(ia64_need_tlb_flush, i) = 1;
		put_cpu();

I suppose one could create a new cpu_map based on cpu_online_map &~ cpu
but that feels rather more heavyweight than a test inside a loop.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
