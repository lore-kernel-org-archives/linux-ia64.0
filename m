From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 15 Oct 2001 17:11:25 +0000
Subject: Re: [Linux-ia64] Probable seamless bug: can't pop es
Message-Id: <marc-linux-ia64-105590698805343@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805337@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 14 Oct 2001 12:35:54 -0600, n0ano@indstorage.com said:

  Don> Short answer: Yes, the GDTD was set up wrong, here's the patch
  Don> to fix this.  (I must be getting better, it only took me a
  Don> weekend to find the single bit that had to change rather than
  Don> my typical effort of over a week :-) We were neglecting to set
  Don> the present bit, an obvious no-no.

Ah, yes, indeed.  Good catch!

  Don> Long answer: I'm amazed we've gotten as far as we have with
  Don> this bug.  ANY attempt by an IA32 program to load a segment
  Don> register from the GDT would cause a fault.  The only reason we
  Don> have worked up to now is that the IA64 code sets up all of the
  Don> segment descriptors manually without reference to the GDT and
  Don> very few protected mode IA32 programs attempt to load any of
  Don> the segment registers.

  Don> Also, there is a non-zero change that this will fix the problem
  Don> with Wine trying to run certain programs, you might want to try
  Don> TurboTax again with this fix in.

I tried it and TurboTax does start up now!  It's still pretty crash
happy (e.g., "View Forms" kills it), but it's still impressive to
watch it.

Does anyone know how well TurboTax works with WINE on a real x86
machine?  Does it work without a full windows installation?

Perhaps more significantly, this apparently also was the bug that kept
x86 abiword from working.

Thanks,

	--david

