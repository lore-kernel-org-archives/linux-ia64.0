From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 02 May 2005 11:39:14 +0000
Subject: Re: Simple Stupid Performance counters
Message-Id: <17014.4450.123162.974010@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504291312370.15808@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 29 Apr 2005 13:14:33 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> Time is measured using the cycle counter (TSC on IA32,
  Christoph> ITC on IA64) which has a very low latency.

Very low latency?  I guess that's relative, but at 36 cycles, AR.ITC
is one of the slowest registers.  If done properly, you can normally
hide the latency of the first read (assuming you don't have too many
other AR/CR accesses pending), but I see that your macros don't do
that either:

+#define PC_START(x) x=(get_cycles() << 8) + smp_processor_id()

The shift & add ensure that even PC_START() will incur the full 36
cycle latency.

	--david
