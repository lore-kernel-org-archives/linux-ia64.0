From: Ingo Molnar <mingo@redhat.com>
Date: Mon, 12 Jul 2004 18:08:11 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
 <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
 <20040711123803.GD21264@devserv.devel.redhat.com>
In-Reply-To: <20040711123803.GD21264@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Jelinek <jakub@redhat.com>
Cc: davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


On Sun, 11 Jul 2004, Jakub Jelinek wrote:

> > --- linux/fs/binfmt_elf.c.orig3	
> > +++ linux/fs/binfmt_elf.c	
> > @@ -627,8 +627,14 @@ static int load_elf_binary(struct linux_
> >  				executable_stack = EXSTACK_DISABLE_X;
> >  			break;
> >  		}
> > +#ifdef __i386_
> > +	/*
> > +	 * Legacy x86 binaries have an expectation of executability for
> > +	 * virtually all their address-space - turn executability on:
> > +	 */
> >  	if (i = elf_ex.e_phnum)
> >  		def_flags |= VM_EXEC | VM_MAYEXEC;
> > +#endif
> 
> This looks incorrect. There are many arches where legacy binaries expect
> the executability for virtually all their address-space (my guess is all
> but x86-64 and ia64), and even on those two legacy binaries expected at
> least stack executable.

so ... this should be #ifndef ia64?

to all the purists: this cannot be done via VM_DATA_DEFAULT_FLAGS, because
some architectures enforce the X bit, some dont. In fact only ia64 seems
to enforce it reliably for all binaries.

the #ifdef could be made an arch inline or define. But it's really
academic as only ia64 seems to have this problem. So i'd suggest the patch
below.

	Ingo

--- linux/fs/binfmt_elf.c.orig
+++ linux/fs/binfmt_elf.c
@@ -627,8 +627,14 @@ static int load_elf_binary(struct linux_
 				executable_stack = EXSTACK_DISABLE_X;
 			break;
 		}
+#ifndef __ia64__
+	/*
+	 * Legacy binaries (except ia64) have an expectation of executability
+	 * for virtually all their address-space - turn executability on:
+	 */
 	if (i = elf_ex.e_phnum)
 		def_flags |= VM_EXEC | VM_MAYEXEC;
+#endif
 
 	/* Some simple consistency checks for the interpreter */
 	if (elf_interpreter) {
