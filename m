From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Mar 2005 18:31:28 +0000
Subject: Re: flush_icache_range
Message-Id: <16952.31616.352193.514473@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Mar 2005 11:58:17 +0100, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> I ran flush_icache_range() for 1000 times for the same page
  Zoltan> (i.e. the "fc" has really nothing to do).  The other CPUs
  Zoltan> were idle. No traffic on the bus.  I simply took the ITC
  Zoltan> value before and after...  Here are the values (average for
  Zoltan> the 1000 runs):

  Zoltan> With a 64-byte stride: 110143 nsec 187218 cycles
  Zoltan> With a 32-byte stride: 225606 nsec 383477 cycles

That's definitely a worthwhile improvement.  I re-checked and it turns
out that I misremembered what I measured: the test-case I had was
testing whether a better scheduled loop-body would help.  I think I
actually wrote that in the Merced days, so I couldn't even have tested
64-byte stride at that time.

I re-ran the test case now and got these results:

 page size   cache-line           stride
	       state       32 bytes	64 bytes
-------------------------------------------------------------
	       dirty	   32,000	22,000 (86 cyc/line)
 16 KB
	       clean	   26,000	12,800 (50 cyc/line)
-------------------------------------------------------------
	       dirty	  130,000	85,000 (83 cyc/line)
 64 KB
	       clean	  105,000	54,000 (52 cyc/line)
-------------------------------------------------------------

While all the numbers are substantially lower than what you're seeing,
clearly using a 64-byte stride is a big win.  I assume the difference
between our results is due to chipsets.  My measurements were done
with a 1.5GHz/6M Madison and the zx1 chipset, which doesn't go beyond
4-way (hence latency tends to be substantially better than with more
scalable chipsets).

	--david
