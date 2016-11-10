From: kbuild test robot <lkp@intel.com>
Date: Thu, 10 Nov 2016 13:51:38 +0000
Subject: Re: [PATCH 1/3] crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
Message-Id: <201611102107.imfeZjH3%fengguang.wu@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
List-Id: <linux-ia64.vger.kernel.org>
References: <147877904646.31483.2251653505359017982.stgit@hbathini.in.ibm.com>
In-Reply-To: <147877904646.31483.2251653505359017982.stgit@hbathini.in.ibm.com>
To: linux-ia64@vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hari,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.9-rc4]
[cannot apply to powerpc/next next-20161110]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Hari-Bathini/kexec-fadump-remove-dependency-with-CONFIG_KEXEC-and-reuse-crashkernel-parameter-for-fadump/20161110-200330
config: h8300-h8300h-sim_defconfig (attached as .config)
compiler: h8300-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=h8300 

All warnings (new ones prefixed by >>):

   In file included from arch/h8300/include/asm/elf.h:8:0,
                    from include/linux/elfcore.h:6,
                    from include/linux/crash_core.h:5,
                    from include/linux/kexec.h:17,
                    from kernel/reboot.c:11:
>> arch/h8300/include/asm/ptrace.h:31:34: warning: 'struct task_struct' declared inside parameter list will not be visible outside of this definition or declaration
    extern long h8300_get_reg(struct task_struct *task, int regno);
                                     ^~~~~~~~~~~
   arch/h8300/include/asm/ptrace.h:32:33: warning: 'struct task_struct' declared inside parameter list will not be visible outside of this definition or declaration
    extern int h8300_put_reg(struct task_struct *task, int regno,
                                    ^~~~~~~~~~~

vim +31 arch/h8300/include/asm/ptrace.h

d2a5f499 Yoshinori Sato 2015-05-11  15  #define H8300_REGS_NO 12
d2a5f499 Yoshinori Sato 2015-05-11  16  #endif
d2a5f499 Yoshinori Sato 2015-05-11  17  
d2a5f499 Yoshinori Sato 2015-05-11  18  #define arch_has_single_step()	(1)
d2a5f499 Yoshinori Sato 2015-05-11  19  
d2a5f499 Yoshinori Sato 2015-05-11  20  #define user_mode(regs) (!((regs)->ccr & PS_S))
d2a5f499 Yoshinori Sato 2015-05-11  21  #define instruction_pointer(regs) ((regs)->pc)
d2a5f499 Yoshinori Sato 2015-05-11  22  #define profile_pc(regs) instruction_pointer(regs)
d2a5f499 Yoshinori Sato 2015-05-11  23  #define user_stack_pointer(regs) ((regs)->sp)
d2a5f499 Yoshinori Sato 2015-05-11  24  #define current_pt_regs() ((struct pt_regs *) \
d2a5f499 Yoshinori Sato 2015-05-11  25  	(THREAD_SIZE + (unsigned long)current_thread_info()) - 1)
d2a5f499 Yoshinori Sato 2015-05-11  26  #define signal_pt_regs() ((struct pt_regs *)current->thread.esp0)
d2a5f499 Yoshinori Sato 2015-05-11  27  #define current_user_stack_pointer() rdusp()
d2a5f499 Yoshinori Sato 2015-05-11  28  #define task_pt_regs(task) \
d2a5f499 Yoshinori Sato 2015-05-11  29  	((struct pt_regs *) (task_stack_page(task) + THREAD_SIZE) - 1)
d2a5f499 Yoshinori Sato 2015-05-11  30  
d2a5f499 Yoshinori Sato 2015-05-11 @31  extern long h8300_get_reg(struct task_struct *task, int regno);
d2a5f499 Yoshinori Sato 2015-05-11  32  extern int h8300_put_reg(struct task_struct *task, int regno,
d2a5f499 Yoshinori Sato 2015-05-11  33  			 unsigned long data);
d2a5f499 Yoshinori Sato 2015-05-11  34  
d2a5f499 Yoshinori Sato 2015-05-11  35  #endif /* __ASSEMBLY__ */
d2a5f499 Yoshinori Sato 2015-05-11  36  #endif /* _H8300_PTRACE_H */

:::::: The code at line 31 was first introduced by commit
:::::: d2a5f4999f6c211adf30d9788349e13988d6f2a7 h8300: Assembly headers

:::::: TO: Yoshinori Sato <ysato@users.sourceforge.jp>
:::::: CC: Yoshinori Sato <ysato@users.sourceforge.jp>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--IJpNTDwzlM2Ie8A6
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AAA=

--IJpNTDwzlM2Ie8A6--
