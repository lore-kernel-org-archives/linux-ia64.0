From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 22 Oct 2003 18:08:20 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106684611528567@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 22 Oct 2003 13:45:47 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> On Tue, Oct 21, 2003 at 04:10:51PM +1000, Ian Wienand wrote:

  >> arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect
  >> section attributes for .data.gate

  Ian> I figured out why (sorry if it's obvious); gas matches anything
  Ian> with prefix '.data.' as a data special section and flags it as
  Ian> 'SHF_ALLOC + SHF_WRITE' as per ELF [*].

It wasn't obvious to me.  I really disklike all this section-name
based matching in BFD/GAS, but it appears to ingrained to have an easy
fix.

  Ian> Issuing

  Ian> .section .data.gate, "ax"

  Ian> thus conflicts as it's assumed to be an extension of a .data
  Ian> section.

  Ian> Should this even be in data at all, considering it's code?
  Ian> What about something along the lines of the attached patch
  Ian> which puts it in it's own section?

Actually, as far as the kernel is concerned, it _is_ data.  Only when
it's mapped at the gate address is it used as text.  I'm not sure why
I put "ax" there---it was most likely a left-over from earlier
experimentation.  So I think the fix is to change "ax" to "aw" (the
data isn't really writable, but to avoid losing more memory to
page-alignment, it's better to keep the gate page in the writeable
data section).  Do you want to try this?

	--david
