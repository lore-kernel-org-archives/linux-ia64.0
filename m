From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Feb 2001 21:02:28 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005184@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Feb 2001 10:58:22 -0800, "Chris McDermott" <mcdermoc@us.ibm.com> said:

  Chris> Anyway, I have ITPs connected to the IBM hardware and have
  Chris> noticed that when the lockup occurs, and we lose video, at
  Chris> least one of the CPUs is executing in flush_tlb_no_ptcg() or
  Chris> handle_IPI(), in the 'do' loop where TLB entries are being
  Chris> purged. What I have observed is that the end address and the
  Chris> start address are in completely different regions. Usually,
  Chris> the start address is in region register 1 (address of
  Chris> 0x2000XXXXXXXXXXXX) and the end address is in region register
  Chris> 3 (address of 0x6000XXXXXXXXXXXX). I don't know if this is
  Chris> the same problem I am seeing on the Lion, but I plan to
  Chris> connect and ITP and a serial console (although we haven't
  Chris> been able to get one to work yet on the Lion with BIOS 71) to
  Chris> see if the symptoms are the same.

This is good info, thanks a lot!  flush_tlb_range() should *never* be
called with an address range that spans entire regions.  So this is
clearly the immediate problem.  The question is of course how it got
there.

I'm just a couple of hours away from hopping on a plane to
Switzerland, and won't be back till Tuesday and am currently busy
tracking down two Heisenbugs which are keeping me from releasing an
updated kernel diff. If someone investigates this some more until in
the meantime, please keep us all posted.

	--david

