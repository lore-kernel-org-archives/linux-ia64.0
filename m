From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Oct 2004 09:53:56 +0000
Subject: Re: ucontext.h
Message-Id: <16739.49332.196714.933028@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 5 Oct 2004 23:56:21 -0700 (PDT), pramod sharma <pramod8378@yahoo.com> said:

  Pramod> For the intel x86 , running on Linux, the struct ucontext
  Pramod> *ucp ; ucp-> uc_mcontext.gregs[ERR]" field can be used to
  Pramod> find out whether READ or WRITE caused the page fault. This
  Pramod> field simply means that we get the interrupted instruction
  Pramod> from ucontext (saved user context) and check whether it is
  Pramod> read or write.

  Pramod> but for IA -64 , there is no structure defined like this
  Pramod> .......is this not supported for IA64 .

  Pramod> How can I acheive this in IA64 ?

  Pramod> Any pointers in this direction will be helpful.

See this mail:

  http://www.gelato.unsw.edu.au/linux-ia64/0202/3059.html

And/or the comment near si_isr in /usr/include/asm/siginfo.h:

/*
 * si_isr is valid for SIGILL, SIGFPE, SIGSEGV, SIGBUS, and SIGTRAP provided
 * that si_code is non-zero and __ISR_VALID is set in si_flags.
 */
#define si_isr          _sifields._sigfault._isr

For a description of the contents of si_isr, see page 2-154 in Volume
2 of the ``Intel Itanium Architecture Software Developer's Manual'':

  http://www.intel.com/design/itanium/manuals/iiasdmanual.htm

BTW: you'd be better off asking such technical questions on
linux-ia64@vger.kernel.org, which I cc'd on this reply.

	--david
