From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Oct 2004 15:39:33 +0000
Subject: potential user/kernel-address confusion
Message-Id: <200410041539.i94FdXfM031518@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun,

While running the sparse checker, I discovered a potential problem:

In elfcore32.h, elf_core_copy_task_fpregs() calls save_ia32_fpstate(),
which expects to be copying to user-memory.  However, the ELF
coredumping code will pass you a pointer to kernel-memory and as far
as I can tell, save_ia32_fpstate() probably fail in that case (I don't
see any set_fs(KERNEL_DS), at least).

On a related note:

 - Isn't ia32_sigsuspend() missing a call to set_fs(KERNEL_DS)?  &mask
   is a kernel pointer, after all.

 - Isn't sys32_rt_sigreturn() missing a call to set_fs(KERNEL_DS)
   before the call to do_sigaltstack()?  &st is a kernel pointer, after all.

	--david
