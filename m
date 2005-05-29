From: "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr>
Date: Sun, 29 May 2005 20:23:23 +0000
Subject: Re: flush_icache_range
Message-Id: <429A24BB.3020307@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

Zoltan> I think we cannot use per-CPU data
 > Why?  I didn't think it was used until per-CPU is initialized.

The point is if we used the per-CPU stride size reported by the PAL
for each CPU, and if we stored these values in their respective per-CPU
data area, then they could be different - on a hypothetic mixed system.
We need a stride size that suits for all the CPUs.

  Zoltan> and there is no need for using per-CPU data, because fc.i a
  Zoltan> global operation, the stride size is a common global value
  Zoltan> for a give machine.
 > Ugh, where that is say that?  I can easily imagine a processor where
 > your argument would not hold true.

fc.i is a global operation as any of the CPUs may have some old
instructions in its i-cache(s).
We need to use the minimum of the stride sizes (that suits for all the
CPUs) - on a hypothetic mixed system.
We use a pre-calculated system wide stride size, then why to
replicate this common value in the per-CPU data areas, why not
to use simply a global variable?

I prefer not to support mixed configurations as there is not such a
real machine, => no need to calculate the min. stride size. This is how
my last patch works.
Even much simpler, the "#ifdef CONFIG_ITANIUM" based solution,
(see my patch on 2005-05-23), would be enough in this case:
http://marc.theaimsgroup.com/?l=linux-ia64&m1685596128411&w=2

 > BTW: instead of calculating the min log2 stride, I'd just export the
 > actual stride.  No point doing that in flush_cache over and over
 > again.

We use in "flush_icache_range()" the
   loop_counter = ( end_address - start_address - 1 )  / stride_size
equation. It is more efficient to use a shift by log2(stride_size) than
a division.
We also need the stride size to increment the address for fc.i.

Thanks,

Zoltan


