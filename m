From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 Jul 2004 04:23:46 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <16649.52562.257991.878161@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Jul 2004 20:52:49 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> Here is an update of the patches that does not rely on
  Christoph> bit patterns in C to set predicates. Various other issues
  Christoph> were fixed as well. New code is now 2 or 3 cycles faster
  Christoph> than the old code.

  Christoph> Testing on an HP RX2600 (2x IA64 900 Mhz) yields:

  Christoph> Old Code:

  Christoph> singsing:/usr/src/noship-tests # ./dmt
  Christoph> gettimeofday cycles: 3250 215 215 215 215 215 215 215 215 215

It occurred to me now why your numbers are higher: I linked my program
statically, whereas yours is probably linked dynamically?

	--david
