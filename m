From: Ingo Molnar <mingo@redhat.com>
Date: Tue, 13 Jul 2004 03:58:06 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <Pine.LNX.4.58.0407122354280.13111@devserv.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
 <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
 <20040711123803.GD21264@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
 <Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Jakub Jelinek <jakub@redhat.com>, davidm@hpl.hp.com, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


On Mon, 12 Jul 2004, Linus Torvalds wrote:

> > so ... this should be #ifndef ia64?
> 
> No. Make it a CONFIG_DEFAULT_NOEXEC and make the relevant architectures do
> a
> 
> 	define_bool DEFAULT_NOEXEC y
> 
> in their Kconfig files.
> 
> In general, we should _never_ use an architecture-define. They just
> always end up becoming more and more hairy, and less and less obvious
> what they are all about.
> 
> So instead, make a readable and explicit config define, and let each
> architecture just set it (or not) as they wish.

ok - patch below. ia64 can now define it - the default is that legacy
binaries have executability expectations.

	Ingo

--- linux/fs/binfmt_elf.c.orig
+++ linux/fs/binfmt_elf.c
@@ -627,8 +627,14 @@ static int load_elf_binary(struct linux_
 				executable_stack = EXSTACK_DISABLE_X;
 			break;
 		}
+#ifndef CONFIG_DEFAULT_NOEXEC
+	/*
+	 * Legacy binaries (unless the arch defaults to noexec) have an
+	 * expectation of executability - turn it on:
+	 */
 	if (i = elf_ex.e_phnum)
 		def_flags |= VM_EXEC | VM_MAYEXEC;
+#endif
 
 	/* Some simple consistency checks for the interpreter */
 	if (elf_interpreter) {
