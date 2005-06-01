From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 01 Jun 2005 23:50:05 +0000
Subject: Re: flush_icache_range
Message-Id: <17054.18861.133922.671273@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 29 May 2005 22:23:23 +0200, "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr> said:

  Zoltan> David Mosberger wrote:
  Zoltan> I think we cannot use per-CPU data

  >> Why?  I didn't think it was used until per-CPU is initialized.

  Zoltan> The point is if we used the per-CPU stride size reported by
  Zoltan> the PAL for each CPU, and if we stored these values in their
  Zoltan> respective per-CPU data area, then they could be different -
  Zoltan> on a hypothetic mixed system.  We need a stride size that
  Zoltan> suits for all the CPUs.

If a CPU advertises an optimal stride-size of 128 bytes, that better
work for all CPUs in the system, even if the optimal stride for
another CPU is smaller, say 64 bytes.

If you want to do a global min and store that in a global variable,
sure, that's fine too.  I _think_ the per-CPU approach would come out
as simpler code, but I could be wrong.

  Zoltan> I prefer not to support mixed configurations as there is not
  Zoltan> such a real machine, => no need to calculate the min. stride
  Zoltan> size.

We should write software that fits the architecture, not just today's
machines.  Doing the latter just calls for trouble when new machines
are being introduced.  Never underestimate the cleverness of future hw
designers...

  >> BTW: instead of calculating the min log2 stride, I'd just export the
  >> actual stride.  No point doing that in flush_cache over and over
  >> again.

  Zoltan> We use in "flush_icache_range()" the loop_counter = (
  Zoltan> end_address - start_address - 1 ) / stride_size equation. It
  Zoltan> is more efficient to use a shift by log2(stride_size) than a
  Zoltan> division.  We also need the stride size to increment the
  Zoltan> address for fc.i.

Ah, I forgot about the division.  Yes, storing the log2 makes more
sense, then.

	--david
