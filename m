From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 08 Aug 2003 00:27:01 +0000
Subject: Re: ia32 core dumps
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Message-Id: <marc-linux-ia64-106030244024444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106028340404901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106028340404901@msgid-missing>
To: linux-ia64@vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 07, 2003 at 12:05:55PM -0700, Arun Sharma wrote:
> The attached patch implements core dump functionality for IA-32 
> applications running on ia64.

I just needed one little change to make it work against current linus
bitkeeper.  Otherwise it works great, thanks!

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elfcore32.h.diff"

===== elfcore32.h 1.1 vs 1.2 =====
--- 1.1/arch/ia64/ia32/elfcore32.h	Fri Aug  8 09:07:30 2003
+++ 1.2/arch/ia64/ia32/elfcore32.h	Fri Aug  8 10:05:00 2003
@@ -99,7 +99,7 @@
 }
 
 static inline int 
-elf_core_copy_task_fpregs(struct task_struct *tsk, elf_fpregset_t *fpu)
+elf_core_copy_task_fpregs(struct task_struct *tsk, struct pt_regs *xregs, elf_fpregset_t *fpu)
 {
 	struct ia32_user_i387_struct *fpstate = (void*)fpu;
 

--CE+1k2dSO48ffgeK--
