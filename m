From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 22 Oct 2003 21:58:50 +0000
Subject: Re: [PATCH] trivial ia64 numa/discontig fixes
Message-Id: <marc-linux-ia64-106686010113031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106685936312275@msgid-missing>
In-Reply-To: <marc-linux-ia64-106685936312275@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 22, 2003 at 03:46:21PM -0600, Alex Williamson wrote:
> --- linux-2.5/arch/ia64/mm/discontig.c	Wed Oct 22 15:13:48 2003
> +++ linux-2.5/arch/ia64/mm/discontig.c	Wed Oct 22 15:16:42 2003
> @@ -186,7 +186,7 @@
>  			 */
>  			for (cpu = 0; cpu < NR_CPUS; cpu++) {
>  				if (node = node_cpuid[cpu].nid) {
> -					memcpy(cpu_data, __phys_per_cpu_start,
> +					memcpy(__va(cpu_data), __phys_per_cpu_start,
>  					       __per_cpu_end-__per_cpu_start);
>  					__per_cpu_offset[cpu] >  						(char*)__va(cpu_data) -

If we put the __va() above where cpu_data is set, we can remove it from
both places in the loop...  Just thought that might be clearer since the
other assignments use __va() above.

Jesse
