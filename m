From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 20 Sep 2001 22:58:27 +0000
Subject: Re: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805230@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805230@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Sep 2001 00:09:11 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> The garbage collector of GNU Guile does not need the machine
  Stefan> context in a signal handler. It just looks for heap
  Stefan> references within the programs stack. The top of the stack
  Stefan> is saved when starting the program, the bottom is gained
  Stefan> from the current stack position when garbage
  Stefan> collecting. More references might be within the machines
  Stefan> registers.

You didn't mention the register backing store.  Be sure to scan that
one too!  For the main thread, libc exports a global variable which
will help you find the beginning of the backing store.  The variable
is called "__libc_ia64_register_backing_store_base".  I'm not sure
what pthreads does (Hans can you help?).  The top of the register
backing store can be obtained from the "sc_bsp" member in the ucontext
(uc->uc_mcontext.sc_bsp).

  Stefan> That is why it uses setjmp() in order to get these into a
  Stefan> defined buffer. On a ia64 Linux setjump() is not said to
  Stefan> save *all* registers. That is why I thought the getcontext()
  Stefan> function could help here. Is that true ? I already tried it
  Stefan> with glibc 2.2.3 without success. Still missed some
  Stefan> references...

Do you need *all* registers or *all live* registers?  If it's the
latter and if you're willing to make a function call to obtain this
state, then getcontext() should do all you need: the scratch state
gets killed by the call to getcontext() and hence the "preserved"
registers that it saves is really all you need.

For your particular case, setjmp() would be an option, too.  The major
difference between setjmp() and getcontext() is that the latter
flushes the register stack, whereas the former does not (but you could
do this on your own later on).  Overall, I'd still recommend using
getcontext() though.  It's a little safer for two reasons:

 (a) We go try hard to avoid changing the layout of "struct
     sigcontext" (and ucontext_t by implication).  For the
     jump-buffer, we really only try to avoid changing its size; the
     internal structure could easily change.

 (b) getcontext() is defined to be used for synchronous context
     switches, so you can be certain that it saves all "preserved"
     state.

Hope this helps.

	--david

