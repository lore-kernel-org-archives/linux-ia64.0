From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Oct 2004 16:26:06 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <16766.31390.547604.110767@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
	<200410251048.48249.bjorn.helgaas@hp.com>
	<16766.360.725296.4208@napali.hpl.hp.com>
	<Pine.LNX.4.58.0410260807080.28839@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0410260807080.28839@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: davidm@hpl.hp.com, Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org

>>>>> On Tue, 26 Oct 2004 08:21:15 -0700 (PDT), Linus Torvalds <torvalds@osdl.org> said:

  Linus> So historically, on x86, an IO port access would be totally
  Linus> synchronous, in that a outb() will actually _wait_ for the
  Linus> out to hit the bus. Quite frankly, I don't think most other
  Linus> architectures ever implemented this even for IO ports, and we
  Linus> should not even _try_ to do so for io_writeX().

Well, ia64 does.  It's precisely what "mf.a" gives you:

  [mf.a] prevents any subsequent data memory accesses by the processor
  from initiating transactions to the external platform until:

    o all prior loads to sequential pages have returned data, and
    o all prior stores to sequential pages have been accepted by
      the external platform

(sequential pages are basically pages mapped uncached).  We use this
to emulate INx/OUTx semantics via memory-mapped I/O.

By your argument, it should be safe to drop the "mf.a" from the I/O
port-based writes.

OTOH, I'm not sure its worth the bother: if you have an I/O device
that does lots of pokes through I/O port space, it's gonna be slow no
matter what and the extra 1000 or so cycles the CPU stalls may not
make any difference (even though it would make any compiler-writer
cringe! ;-).  Also, if x86 gives stronger ordering guarantees, suspect
there is _some_ broken driver out there that may rely on that
property, so it may just be safer to leave the "mf.a" there.

	--david
