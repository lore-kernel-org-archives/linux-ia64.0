From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 18:06:16 +0000
Subject: Re: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005968@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 31 Jul 2001 19:06:28 +0900, nomura@hpc.bs1.fc.nec.co.jp said:

  >> This isn't right.  There is no way a VA->PA translation can set
  >> bit 63 so address 0x80000ffffc000000 could only be generated in
  >> physical mode, which Linux (almost) never uses.  The address
  >> 0xffffc000000 is correct since Linux will access the memory range
  >> only through uncached space (region 6).

  Nomura> I didn't talk about VA-PA translation nor I/O memory range
  Nomura> access by linux.  'mapping' was the wrong word, I'm afraid.

What I'm saying is that an address with bit 63 set is not a proper
physical address (it's nothing that will ever show up on the physical
address bus) and therefore cannot be addressed using virtual
addressing.  Thus, such an address is useless for Linux.

  Nomura> I mean ar.k0 seems to be used by SAL in physical mode and
  Nomura> setting ar.k0 to cached attribute is problematic.

I don't know about SAL internals, but if SAL uses it in physical mode,
it needs to make sure that it's accessing it in uncached mode.  This
seems to work just fine on all existing Intel and HP systems so it
certainly seems possible.

  Nomura> I think setting bit63 to 1 (i.e. physical mode uncached) is
  Nomura> better and safer solution than just putting cached attribute
  Nomura> physical address in ar.k0, unless anyone or any part of code
  Nomura> suffers from the bit.

No, setting bit 63 is not a solution.  k0 must contain the physical
base address of the legacy I/O space, no more, no less.

	--david

