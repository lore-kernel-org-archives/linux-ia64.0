From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 13 Jun 2005 11:20:05 +0000
Subject: Re: flush_icache_range
Message-Id: <42AD6BE5.6050105@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> Looks fine to me.  The large number of shifts in the setup-code is a
> bit unfortunate, but compared to the savings the larger stride
> achieves on today's systems, this penalty is minor.  Still, if you
> could find a sequence that's nicer to McKinley-type cores (with a
> single shifter), that would be a plus.

We need:
- the stride size shift (for dividing)
- the stride size (for the address steps)
- some masking (for rounding down the start address)
I cannot find any sequence with less shifts.
( I do not want to store separately in global variables the shift,
  the value and the mask. )
 
> The other slight concern I have is that if somebody calls
> flush_icache_range() before cpu_init() has been called the first time,
> it won't work. We can probably live with it, but it would have been
> nicer if there had been a clean way to default to stride=5 initially.

I checked where "flush_icache_range()" is used:

fs/binfmt_*.c

do_mmap_pgoff()
sys_init_module()

via flush_icache_user_range():
   copy_to_user_page()

via update_mmu_cache():
   swiotlb_map_single()
   install_page()
   install_file_pte()
   break_cow()
   do_wp_page()
   do_swap_page()
   do_anonymous_page()
   do_no_page()
   handle_pte_fault()

( I hope I have not missed anything. )

These are much after my very first stride size init:

start_kernel():
   setup_arch():
      cpu_init():
         get_max_cacheline_size()

Let's see for the other CPUs: any __init'ed stuff can eventually
do some black magic.

start_kernel():
   rest_init():
      init():
         smp_init():
            for (<the other CPUs>)
               cpu_up(i)

- Either the black trick is before "cpu_up(i)":
  the CPU-i has not got anything about it in its cache,
- Or the black trick is after "cpu_up(i)":
  the (eventually smaller) stride size of CPU-i is
  taken into account.
We are safe anyway.

As far as "sn_flush_all_caches()" is concerned,
can someone, please, from SGI have a look at it?

Debuggers should use their own safe way to flush caches:
the less they reckon on standard kernel routines,
the less chance that a debugging session crashes :-).

Thanks,

Zoltan

