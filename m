From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 22 Feb 2002 16:58:11 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905169@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Feb 2002 12:35:51 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> I made some measures and found that on Itanium it takes
  Christian> about ~700 CPU cycles to load a single byte when TLB is
  Christian> missing and VHPT is enabled vs. ~900 cycles with VHPT
  Christian> disabled and handling the TLB miss in the IVT.

It's not that simple.  On Itanium, the VHPT will help only if the TLB
entry can be found in the cache (this is described in the Itanium
microarch. manual, IIRC).  I don't think anything has been said
publically yet what McKinley does, so we'll have to wait a bit longer.

The 700 cycle number sounds too high.  For example, I have a little
test program that shows repeatedly touching ~92 pages takes about 25
cycles on average and touching more than 128 pages takes about 73
cycles on average, for a difference of about 48 cycles.

  Christian> Does
  Christian> anybody know if the VHPT walker is implemented in
  Christian> hardware (probably not), microcode (that's what I think)
  Christian> or unimplemented at all?

It's definitely implemented in hardware, though I don't know the
implementation details.

	--david

