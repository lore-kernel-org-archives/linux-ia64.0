From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Aug 2003 06:23:22 +0000
Subject: Re: ia32 core dumps
Message-Id: <marc-linux-ia64-106032382704769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106028340404901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106028340404901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I noticed that one too.

	--david

>>>>> On Fri, 8 Aug 2003 10:27:01 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> On Thu, Aug 07, 2003 at 12:05:55PM -0700, Arun Sharma wrote:
  >> The attached patch implements core dump functionality for IA-32
  >> applications running on ia64.

  Ian> I just needed one little change to make it work against current
  Ian> linus bitkeeper.  Otherwise it works great, thanks!

  Ian> -i ianw@gelato.unsw.edu.au http://www.gelato.unsw.edu.au==  Ian> elfcore32.h 1.1 vs 1.2 === --- 1.1/arch/ia64/ia32/elfcore32.h
  Ian> Fri Aug 8 09:07:30 2003 +++ 1.2/arch/ia64/ia32/elfcore32.h Fri
  Ian> Aug 8 10:05:00 2003 @@ -99,7 +99,7 @@ }
 
  Ian>  static inline int -elf_core_copy_task_fpregs(struct
  Ian> task_struct *tsk, elf_fpregset_t *fpu)
  Ian> +elf_core_copy_task_fpregs(struct task_struct *tsk, struct
  Ian> pt_regs *xregs, elf_fpregset_t *fpu) { struct
  Ian> ia32_user_i387_struct *fpstate = (void*)fpu;
 
