From: Josue Amaro <josue.amaro@oracle.com>
Date: Wed, 18 Apr 2001 07:57:53 +0000
Subject: Re: [Linux-ia64] IA-32 LDT support patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------2A647AA2DC44AB402190DADC"
Message-Id: <marc-linux-ia64-105590693005422@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005414@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------2A647AA2DC44AB402190DADC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David,

I'll test it as soon as I can.

Thanks,

David Mosberger wrote:

> Below is a patch that goes on top of the IA-64 Linux version of
> v2.4.3.  It adds support for the IA-32 modify_ldt() system call which
> is needed to run certain x86 programs (such as programs linked against
> recent versions of x86 pthreads).
>
> Thanks to Don Dugger and Asit Mallick for reviewing the patch (all
> bugs are mine, of course...).  I really know almost nothing about x86
> and I'm trying hard to keep it that way ;-), but the patch should work
> OK.  At least "netscape" still works and a simple test program linked
> against a version of pthreads that uses modify_ldt() also seems to
> work fine.
>
> Enjoy,
>
>         --david
>
> diff -urN lia64/arch/ia64/ia32/Makefile lia64-kdb/arch/ia64/ia32/Makefile
> --- lia64/arch/ia64/ia32/Makefile       Wed Jan  3 23:06:42 2001
> +++ lia64-kdb/arch/ia64/ia32/Makefile   Fri Apr 13 14:21:30 2001
> @@ -11,7 +11,8 @@
>
>  O_TARGET := ia32.o
>
> -obj-y := ia32_entry.o sys_ia32.o ia32_ioctl.o ia32_signal.o ia32_support.o ia32_traps.o binfmt_elf32.o
> +obj-y := ia32_entry.o sys_ia32.o ia32_ioctl.o ia32_signal.o ia32_support.o ia32_traps.o \
> +        binfmt_elf32.o ia32_ldt.o
>
>  clean::
>
> diff -urN lia64/arch/ia64/ia32/binfmt_elf32.c lia64-kdb/arch/ia64/ia32/binfmt_elf32.c
> --- lia64/arch/ia64/ia32/binfmt_elf32.c Thu Apr  5 09:51:03 2001
> +++ lia64-kdb/arch/ia64/ia32/binfmt_elf32.c     Fri Apr 13 19:34:37 2001
> @@ -2,8 +2,11 @@
>   * IA-32 ELF support.
>   *
>   * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
> + * Copyright (C) 2001 Hewlett-Packard Co
> + * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
>   *
>   * 06/16/00    A. Mallick      initialize csd/ssd/tssd/cflg for ia32_load_state
> + * 04/13/01    D. Mosberger    dropped saving tssd in ar.k1---it's not needed
>   */
>  #include <linux/config.h>
>
> @@ -35,8 +38,8 @@
>  #undef CLOCKS_PER_SEC
>  #define CLOCKS_PER_SEC IA32_CLOCKS_PER_SEC
>
> -extern void ia64_elf32_init(struct pt_regs *regs);
> -extern void put_dirty_page(struct task_struct * tsk, struct page *page, unsigned long address);
> +extern void ia64_elf32_init (struct pt_regs *regs);
> +extern void put_dirty_page (struct task_struct * tsk, struct page *page, unsigned long address);
>
>  #define ELF_PLAT_INIT(_r)              ia64_elf32_init(_r)
>  #define setup_arg_pages(bprm)          ia32_setup_arg_pages(bprm)
> @@ -49,7 +52,7 @@
>  unsigned long *ia32_gdt_table, *ia32_tss;
>
>  struct page *
> -put_shared_page(struct task_struct * tsk, struct page *page, unsigned long address)
> +put_shared_page (struct task_struct * tsk, struct page *page, unsigned long address)
>  {
>         pgd_t * pgd;
>         pmd_t * pmd;
> @@ -83,85 +86,87 @@
>         return 0;
>  }
>
> -void ia64_elf32_init(struct pt_regs *regs)
> +void
> +ia64_elf32_init (struct pt_regs *regs)
>  {
> +       struct vm_area_struct *vma;
>         int nr;
>
> -       put_shared_page(current, virt_to_page(ia32_gdt_table), IA32_PAGE_OFFSET);
> +       /*
> +        * Map GDT and TSS below 4GB, where the processor can find them.  We need to map
> +        * it with privilege level 3 because the IVE uses non-privileged accesses to these
> +        * tables.  IA-32 segmentation is used to protect against IA-32 accesses to them.
> +        */
> +       put_shared_page(current, virt_to_page(ia32_gdt_table), IA32_GDT_OFFSET);
>         if (PAGE_SHIFT <= IA32_PAGE_SHIFT)
> -               put_shared_page(current, virt_to_page(ia32_tss), IA32_PAGE_OFFSET + PAGE_SIZE);
> +               put_shared_page(current, virt_to_page(ia32_tss), IA32_TSS_OFFSET);
>
> -       nr = smp_processor_id();
> +       /*
> +        * Install LDT as anonymous memory.  This gives us all-zero segment descriptors
> +        * until a task modifies them via modify_ldt().
> +        */
> +       vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
> +       if (vma) {
> +               vma->vm_mm = current->mm;
> +               vma->vm_start = IA32_LDT_OFFSET;
> +               vma->vm_end = vma->vm_start + PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
> +               vma->vm_page_prot = PAGE_SHARED;
> +               vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE;
> +               vma->vm_ops = NULL;
> +               vma->vm_pgoff = 0;
> +               vma->vm_file = NULL;
> +               vma->vm_private_data = NULL;
> +               insert_vm_struct(current->mm, vma);
> +       }
>
> -       /* Do all the IA-32 setup here */
> +       nr = smp_processor_id();
>
> -       current->thread.map_base  = 0x40000000;
> -       current->thread.task_size = 0xc0000000;         /* use what Linux/x86 uses... */
> +       current->thread.map_base  = IA32_PAGE_OFFSET/3;
> +       current->thread.task_size = IA32_PAGE_OFFSET;   /* use what Linux/x86 uses... */
>         set_fs(USER_DS);                                /* set addr limit for new TASK_SIZE */
>
> -       /* setup ia32 state for ia32_load_state */
> +       /* Setup the segment selectors */
> +       regs->r16 = (__USER_DS << 16) | __USER_DS; /* ES == DS, GS, FS are zero */
> +       regs->r17 = (__USER_DS << 16) | __USER_CS; /* SS, CS; ia32_load_state() sets TSS and LDT */
> +
> +       /* Setup the segment descriptors */
> +       regs->r24 = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3]);        /* ESD */
> +       regs->r27 = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3]);        /* DSD */
> +       regs->r28 = 0;                                                          /* FSD (null) */
> +       regs->r29 = 0;                                                          /* GSD (null) */
> +       regs->r30 = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[_LDT(nr)]);              /* LDTD */
>
> -       current->thread.eflag = IA32_EFLAG;
> -       current->thread.csd = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0xBL, 1L, 3L, 1L, 1L, 1L);
> -       current->thread.ssd = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1L, 1L, 1L);
> -       current->thread.tssd = IA64_SEG_DESCRIPTOR(IA32_PAGE_OFFSET + PAGE_SIZE, 0x1FFFL, 0xBL,
> -                                                  1L, 3L, 1L, 1L, 1L);
> -
> -       /* CS descriptor */
> -       __asm__("mov ar.csd = %0" : /* no outputs */
> -               : "r" IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0xBL, 1L,
> -                                         3L, 1L, 1L, 1L));
> -       /* SS descriptor */
> -       __asm__("mov ar.ssd = %0" : /* no outputs */
> -               : "r" IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L,
> -                                         3L, 1L, 1L, 1L));
> -       /* EFLAGS */
> -       __asm__("mov ar.eflag = %0" : /* no outputs */ : "r" (IA32_EFLAG));
> -
> -       /* Control registers */
> -       __asm__("mov ar.fsr = %0"
> -               : /* no outputs */
> -               : "r" ((ulong)IA32_FSR_DEFAULT));
> -       __asm__("mov ar.fcr = %0"
> -               : /* no outputs */
> -               : "r" ((ulong)IA32_FCR_DEFAULT));
> -       __asm__("mov ar.fir = r0");
> -       __asm__("mov ar.fdr = r0");
> -       current->thread.old_iob = ia64_get_kr(IA64_KR_IO_BASE);
> -       ia64_set_kr(IA64_KR_IO_BASE, IA32_IOBASE);
> -
> -       /* Get the segment selectors right */
> -       regs->r16 = (__USER_DS << 16) |  (__USER_DS); /* ES == DS, GS, FS are zero */
> -       regs->r17 = (_TSS(nr) << 48) | (_LDT(nr) << 32)
> -                   | (__USER_DS << 16) | __USER_CS;
> -
> -       /* Setup other segment descriptors - ESD, DSD, FSD, GSD */
> -       regs->r24 = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1L, 1L, 1L);
> -       regs->r27 = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1L, 1L, 1L);
> -       regs->r28 = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1L, 1L, 1L);
> -       regs->r29 = IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1L, 1L, 1L);
> -
> -       /* Setup the LDT and GDT */
> -       regs->r30 = ia32_gdt_table[_LDT(nr)];
> -       regs->r31 = IA64_SEG_DESCRIPTOR(0xc0000000L, 0x400L, 0x3L, 1L, 3L,
> -                                       1L, 1L, 1L);
> -
> -       /* Clear psr.ac */
> -       regs->cr_ipsr &= ~IA64_PSR_AC;
> +       /*
> +        * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descriptor
> +        * format defined by Figure 3-11 "Pseudo-Descriptor Format" in the IA-32
> +        * architecture manual.
> +        */
> +       regs->r31 = IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA32_PAGE_SIZE - 1, 0,
> +                                                           0, 0, 0, 0, 0, 0));
>
> +       ia64_psr(regs)->ac = 0;         /* turn off alignment checking */
>         regs->loadrs = 0;
> -}
>
> -#undef STACK_TOP
> -#define STACK_TOP ((IA32_PAGE_OFFSET/3) * 2)
> +       current->thread.eflag = IA32_EFLAG;
> +       current->thread.fsr = IA32_FSR_DEFAULT;
> +       current->thread.fcr = IA32_FCR_DEFAULT;
> +       current->thread.fir = 0;
> +       current->thread.fdr = 0;
> +       current->thread.csd = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_CS >> 3]);
> +       current->thread.ssd = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3]);
> +       current->thread.tssd = IA32_SEG_UNSCRAMBLE(ia32_gdt_table[_TSS(nr)]);
> +
> +       ia32_load_state(current);
> +}
>
> -int ia32_setup_arg_pages(struct linux_binprm *bprm)
> +int
> +ia32_setup_arg_pages (struct linux_binprm *bprm)
>  {
>         unsigned long stack_base;
>         struct vm_area_struct *mpnt;
>         int i;
>
> -       stack_base = STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
> +       stack_base = IA32_STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
>
>         bprm->p += stack_base;
>         if (bprm->loader)
> @@ -175,7 +180,7 @@
>         {
>                 mpnt->vm_mm = current->mm;
>                 mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
> -               mpnt->vm_end = STACK_TOP;
> +               mpnt->vm_end = IA32_STACK_TOP;
>                 mpnt->vm_page_prot = PAGE_COPY;
>                 mpnt->vm_flags = VM_STACK_FLAGS;
>                 mpnt->vm_ops = NULL;
> @@ -197,15 +202,15 @@
>  }
>
>  static unsigned long
> -ia32_mm_addr(unsigned long addr)
> +ia32_mm_addr (unsigned long addr)
>  {
>         struct vm_area_struct *vma;
>
>         if ((vma = find_vma(current->mm, addr)) == NULL)
> -               return(ELF_PAGESTART(addr));
> +               return ELF_PAGESTART(addr);
>         if (vma->vm_start > addr)
> -               return(ELF_PAGESTART(addr));
> -       return(ELF_PAGEALIGN(addr));
> +               return ELF_PAGESTART(addr);
> +       return ELF_PAGEALIGN(addr);
>  }
>
>  /*
> @@ -232,22 +237,9 @@
>          */
>         if (addr == 0)
>                 addr += PAGE_SIZE;
> -#if 1
>         set_brk(ia32_mm_addr(addr), addr + eppnt->p_memsz);
>         memset((char *) addr + eppnt->p_filesz, 0, eppnt->p_memsz - eppnt->p_filesz);
>         kernel_read(filep, eppnt->p_offset, (char *) addr, eppnt->p_filesz);
>         retval = (unsigned long) addr;
> -#else
> -       /* doesn't work yet... */
> -#      define IA32_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_EXEC_PAGESIZE-1))
> -#      define IA32_PAGEOFFSET(_v) ((_v) & (ELF_EXEC_PAGESIZE-1))
> -#      define IA32_PAGEALIGN(_v) (((_v) + ELF_EXEC_PAGESIZE - 1) & ~(ELF_EXEC_PAGESIZE - 1))
> -
> -       down_write(&current->mm->mmap_sem);
> -       retval = ia32_do_mmap(filep, IA32_PAGESTART(addr),
> -                             eppnt->p_filesz + IA32_PAGEOFFSET(eppnt->p_vaddr), prot, type,
> -                             eppnt->p_offset - IA32_PAGEOFFSET(eppnt->p_vaddr));
> -       up_write(&current->mm->mmap_sem);
> -#endif
>         return retval;
>  }
> diff -urN lia64/arch/ia64/ia32/ia32_entry.S lia64-kdb/arch/ia64/ia32/ia32_entry.S
> --- lia64/arch/ia64/ia32/ia32_entry.S   Wed Mar 28 21:42:44 2001
> +++ lia64-kdb/arch/ia64/ia32/ia32_entry.S       Fri Apr 13 14:36:18 2001
> @@ -233,7 +233,7 @@
>         data8 sys32_ni_syscall
>         data8 sys_iopl            /* 110 */
>         data8 sys_vhangup
> -       data8 sys32_ni_syscall          // used to be sys_idle
> +       data8 sys32_ni_syscall          /* used to be sys_idle */
>         data8 sys32_ni_syscall
>         data8 sys32_wait4
>         data8 sys_swapoff         /* 115 */
> @@ -244,7 +244,7 @@
>         data8 sys_clone           /* 120 */
>         data8 sys_setdomainname
>         data8 sys32_newuname
> -       data8 sys_modify_ldt
> +       data8 sys32_modify_ldt
>         data8 sys_adjtimex
>         data8 sys32_mprotect      /* 125 */
>         data8 sys_sigprocmask
> diff -urN lia64/arch/ia64/ia32/ia32_ldt.c lia64-kdb/arch/ia64/ia32/ia32_ldt.c
> --- lia64/arch/ia64/ia32/ia32_ldt.c     Wed Dec 31 16:00:00 1969
> +++ lia64-kdb/arch/ia64/ia32/ia32_ldt.c Fri Apr 13 20:23:48 2001
> @@ -0,0 +1,120 @@
> +/*
> + * Copyright (C) 2001 Hewlett-Packard Co
> + * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
> + *
> + * Adapted from arch/i386/kernel/ldt.c
> + */
> +
> +#include <linux/errno.h>
> +#include <linux/sched.h>
> +#include <linux/string.h>
> +#include <linux/mm.h>
> +#include <linux/smp.h>
> +#include <linux/smp_lock.h>
> +#include <linux/vmalloc.h>
> +
> +#include <asm/uaccess.h>
> +#include <asm/ia32.h>
> +
> +/*
> + * read_ldt() is not really atomic - this is not a problem since synchronization of reads
> + * and writes done to the LDT has to be assured by user-space anyway. Writes are atomic,
> + * to protect the security checks done on new descriptors.
> + */
> +static int
> +read_ldt (void *ptr, unsigned long bytecount)
> +{
> +       char *src, *dst, buf[256];      /* temporary buffer (don't overflow kernel stack!) */
> +       unsigned long bytes_left, n;
> +
> +       if (bytecount > IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE)
> +               bytecount = IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE;
> +
> +       bytes_left = bytecount;
> +
> +       src = (void *) IA32_LDT_OFFSET;
> +       dst = ptr;
> +
> +       while (bytes_left) {
> +               n = sizeof(buf);
> +               if (n > bytes_left)
> +                       n = bytes_left;
> +
> +               /*
> +                * We know we're reading valid memory, but we still must guard against
> +                * running out of memory.
> +                */
> +               if (__copy_from_user(buf, src, n))
> +                       return -EFAULT;
> +
> +               if (copy_to_user(dst, buf, n))
> +                       return -EFAULT;
> +
> +               src += n;
> +               dst += n;
> +               bytes_left -= n;
> +       }
> +       return bytecount;
> +}
> +
> +static int
> +write_ldt (void * ptr, unsigned long bytecount, int oldmode)
> +{
> +       struct ia32_modify_ldt_ldt_s ldt_info;
> +       __u64 entry;
> +
> +       if (bytecount != sizeof(ldt_info))
> +               return -EINVAL;
> +       if (copy_from_user(&ldt_info, ptr, sizeof(ldt_info)))
> +               return -EFAULT;
> +
> +       if (ldt_info.entry_number >= IA32_LDT_ENTRIES)
> +               return -EINVAL;
> +       if (ldt_info.contents == 3) {
> +               if (oldmode)
> +                       return -EINVAL;
> +               if (ldt_info.seg_not_present == 0)
> +                       return -EINVAL;
> +       }
> +
> +       if (ldt_info.base_addr == 0 && ldt_info.limit == 0
> +           && (oldmode || (ldt_info.contents == 0 && ldt_info.read_exec_only == 1
> +                           && ldt_info.seg_32bit == 0 && ldt_info.limit_in_pages == 0
> +                           && ldt_info.seg_not_present == 1 && ldt_info.useable == 0)))
> +               /* allow LDTs to be cleared by the user */
> +               entry = 0;
> +       else
> +               /* we must set the "Accessed" bit as IVE doesn't emulate it */
> +               entry = IA32_SEG_DESCRIPTOR(ldt_info.base_addr, ldt_info.limit,
> +                                           (((ldt_info.read_exec_only ^ 1) << 1)
> +                                            | (ldt_info.contents << 2)) | 1,
> +                                           1, 3, ldt_info.seg_not_present ^ 1,
> +                                           (oldmode ? 0 : ldt_info.useable),
> +                                           ldt_info.seg_32bit,
> +                                           ldt_info.limit_in_pages);
> +       /*
> +        * Install the new entry.  We know we're accessing valid (mapped) user-level
> +        * memory, but we still need to guard against out-of-memory, hence we must use
> +        * put_user().
> +        */
> +       return __put_user(entry, (__u64 *) IA32_LDT_OFFSET + ldt_info.entry_number);
> +}
> +
> +asmlinkage int
> +sys32_modify_ldt (int func, void *ptr, unsigned int bytecount)
> +{
> +       int ret = -ENOSYS;
> +
> +       switch (func) {
> +             case 0:
> +               ret = read_ldt(ptr, bytecount);
> +               break;
> +             case 1:
> +               ret = write_ldt(ptr, bytecount, 1);
> +               break;
> +             case 0x11:
> +               ret = write_ldt(ptr, bytecount, 0);
> +               break;
> +       }
> +       return ret;
> +}
> diff -urN lia64/arch/ia64/ia32/ia32_support.c lia64-kdb/arch/ia64/ia32/ia32_support.c
> --- lia64/arch/ia64/ia32/ia32_support.c Wed Feb 21 16:05:28 2001
> +++ lia64-kdb/arch/ia64/ia32/ia32_support.c     Fri Apr 13 20:20:49 2001
> @@ -1,6 +1,11 @@
>  /*
>   * IA32 helper functions
>   *
> + * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
> + * Copyright (C) 2000 Asit K. Mallick <asit.k.mallick@intel.com>
> + * Copyright (C) 2001 Hewlett-Packard Co
> + * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
> + *
>   * 06/16/00    A. Mallick      added csd/ssd/tssd for ia32 thread context
>   * 02/19/01    D. Mosberger    dropped tssd; it's not needed
>   */
> @@ -21,7 +26,7 @@
>  extern void die_if_kernel (char *str, struct pt_regs *regs, long err);
>
>  void
> -ia32_save_state (struct thread_struct *thread)
> +ia32_save_state (struct task_struct *t)
>  {
>         unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd;
>
> @@ -33,28 +38,30 @@
>              "mov %5=ar.csd;"
>              "mov %6=ar.ssd;"
>              : "=r"(eflag), "=r"(fsr), "=r"(fcr), "=r"(fir), "=r"(fdr), "=r"(csd), "=r"(ssd));
> -       thread->eflag = eflag;
> -       thread->fsr = fsr;
> -       thread->fcr = fcr;
> -       thread->fir = fir;
> -       thread->fdr = fdr;
> -       thread->csd = csd;
> -       thread->ssd = ssd;
> -       asm ("mov ar.k0=%0 ;;" :: "r"(thread->old_iob));
> +       t->thread.eflag = eflag;
> +       t->thread.fsr = fsr;
> +       t->thread.fcr = fcr;
> +       t->thread.fir = fir;
> +       t->thread.fdr = fdr;
> +       t->thread.csd = csd;
> +       t->thread.ssd = ssd;
> +       ia64_set_kr(IA64_KR_IO_BASE, t->thread.old_iob);
>  }
>
>  void
> -ia32_load_state (struct thread_struct *thread)
> +ia32_load_state (struct task_struct *t)
>  {
>         unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd;
> +       struct pt_regs *regs = ia64_task_regs(t);
> +       int nr;
>
> -       eflag = thread->eflag;
> -       fsr = thread->fsr;
> -       fcr = thread->fcr;
> -       fir = thread->fir;
> -       fdr = thread->fdr;
> -       csd = thread->csd;
> -       ssd = thread->ssd;
> +       eflag = t->thread.eflag;
> +       fsr = t->thread.fsr;
> +       fcr = t->thread.fcr;
> +       fir = t->thread.fir;
> +       fdr = t->thread.fdr;
> +       csd = t->thread.csd;
> +       ssd = t->thread.ssd;
>
>         asm volatile ("mov ar.eflag=%0;"
>                       "mov ar.fsr=%1;"
> @@ -64,17 +71,22 @@
>                       "mov ar.csd=%5;"
>                       "mov ar.ssd=%6;"
>                       :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr), "r"(csd), "r"(ssd));
> -       asm ("mov %0=ar.k0 ;;" : "=r"(thread->old_iob));
> -       asm ("mov ar.k0=%0 ;;" :: "r"(IA32_IOBASE));
> +       current->thread.old_iob = ia64_get_kr(IA64_KR_IO_BASE);
> +       ia64_set_kr(IA64_KR_IO_BASE, IA32_IOBASE);
> +
> +       /* load TSS and LDT while preserving SS and CS: */
> +       nr = smp_processor_id();
> +       regs->r17 = (_TSS(nr) << 48) | (_LDT(nr) << 32) | (__u32) regs->r17;
>  }
>
>  /*
> - * Setup IA32 GDT and TSS
> + * Setup IA32 GDT and TSS
>   */
>  void
> -ia32_gdt_init(void)
> +ia32_gdt_init (void)
>  {
> -       unsigned long gdt_and_tss_page;
> +       unsigned long gdt_and_tss_page, ldt_size;
> +       int nr;
>
>         /* allocate two IA-32 pages of memory: */
>         gdt_and_tss_page = __get_free_pages(GFP_KERNEL,
> @@ -86,17 +98,28 @@
>         /* Zero the gdt and tss */
>         memset((void *) gdt_and_tss_page, 0, 2*IA32_PAGE_SIZE);
>
> -       /* CS descriptor in IA-32 format */
> -       ia32_gdt_table[4] = IA32_SEG_DESCRIPTOR(0L, 0xBFFFFFFFL, 0xBL, 1L,
> -                                               3L, 1L, 1L, 1L, 1L);
> -
> -       /* DS descriptor in IA-32 format */
> -       ia32_gdt_table[5] = IA32_SEG_DESCRIPTOR(0L, 0xBFFFFFFFL, 0x3L, 1L,
> -                                               3L, 1L, 1L, 1L, 1L);
> +       /* CS descriptor in IA-32 (scrambled) format */
> +       ia32_gdt_table[__USER_CS >> 3] =
> +               IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSET - 1) >> IA32_PAGE_SHIFT,
> +                                   0xb, 1, 3, 1, 1, 1, 1);
> +
> +       /* DS descriptor in IA-32 (scrambled) format */
> +       ia32_gdt_table[__USER_DS >> 3] =
> +               IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSET - 1) >> IA32_PAGE_SHIFT,
> +                                   0x3, 1, 3, 1, 1, 1, 1);
> +
> +       /* We never change the TSS and LDT descriptors, so we can share them across all CPUs.  */
> +       ldt_size = PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
> +       for (nr = 0; nr < NR_CPUS; ++nr) {
> +               ia32_gdt_table[_TSS(nr)] = IA32_SEG_DESCRIPTOR(IA32_TSS_OFFSET, 235,
> +                                                              0xb, 0, 3, 1, 1, 1, 0);
> +               ia32_gdt_table[_LDT(nr)] = IA32_SEG_DESCRIPTOR(IA32_LDT_OFFSET, ldt_size - 1,
> +                                                              0x2, 0, 3, 1, 1, 1, 0);
> +       }
>  }
>
>  /*
> - * Handle bad IA32 interrupt via syscall
> + * Handle bad IA32 interrupt via syscall
>   */
>  void
>  ia32_bad_interrupt (unsigned long int_num, struct pt_regs *regs)
> @@ -106,8 +129,7 @@
>         die_if_kernel("Bad IA-32 interrupt", regs, int_num);
>
>         siginfo.si_signo = SIGTRAP;
> -       siginfo.si_errno = int_num;     /* XXX is it legal to abuse si_errno like this? */
> +       siginfo.si_errno = int_num;     /* XXX is it OK to abuse si_errno like this? */
>         siginfo.si_code = TRAP_BRKPT;
>         force_sig_info(SIGTRAP, &siginfo, current);
>  }
> -
> diff -urN lia64/arch/ia64/ia32/sys_ia32.c lia64-kdb/arch/ia64/ia32/sys_ia32.c
> --- lia64/arch/ia64/ia32/sys_ia32.c     Thu Apr  5 09:51:22 2001
> +++ lia64-kdb/arch/ia64/ia32/sys_ia32.c Fri Apr 13 20:46:41 2001
> @@ -334,9 +334,9 @@
>         down_write(&current->mm->mmap_sem);
>         retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset >> PAGE_SHIFT);
>         up_write(&current->mm->mmap_sem);
> -#else  // CONFIG_IA64_PAGE_SIZE_4KB
> +#else
>         retval = ia32_do_mmap(file, a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
> -#endif // CONFIG_IA64_PAGE_SIZE_4KB
> +#endif
>         if (file)
>                 fput(file);
>         return retval;
> @@ -1886,8 +1886,7 @@
>                 break;
>
>         case SHMAT:
> -               err = do_sys32_shmat (first, second, third,
> -                                     version, (void *)AA(ptr));
> +               err = do_sys32_shmat (first, second, third, version, (void *)AA(ptr));
>                 break;
>         case SHMDT:
>                 err = sys_shmdt ((char *)AA(ptr));
> @@ -2334,8 +2333,8 @@
>   *    the address of `stack' will not be the address of the `pt_regs'.
>   */
>  asmlinkage long
> -sys32_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data,
> -           long arg4, long arg5, long arg6, long arg7, long stack)
> +sys32_ptrace (int request, pid_t pid, unsigned int addr, unsigned int data,
> +             long arg4, long arg5, long arg6, long arg7, long stack)
>  {
>         struct pt_regs *regs = (struct pt_regs *) &stack;
>         struct task_struct *child;
> @@ -2379,7 +2378,7 @@
>               case PTRACE_PEEKDATA:     /* read word at location addr */
>                 ret = ia32_peek(regs, child, addr, &value);
>                 if (ret == 0)
> -                       ret = put_user(value, (unsigned int *)data);
> +                       ret = put_user(value, (unsigned int *)A(data));
>                 else
>                         ret = -EIO;
>                 goto out;
> @@ -2398,12 +2397,12 @@
>                 break;
>
>               case IA32_PTRACE_GETREGS:
> -               if (!access_ok(VERIFY_WRITE, (int *)data, 17*sizeof(int))) {
> +               if (!access_ok(VERIFY_WRITE, (int *) A(data), 17*sizeof(int))) {
>                         ret = -EIO;
>                         break;
>                 }
>                 for ( i = 0; i < 17*sizeof(int); i += sizeof(int) ) {
> -                       __put_user(getreg(child, i),(unsigned int *) data);
> +                       __put_user(getreg(child, i), (unsigned int *) A(data));
>                         data += sizeof(int);
>                 }
>                 ret = 0;
> @@ -2412,12 +2411,12 @@
>               case IA32_PTRACE_SETREGS:
>               {
>                 unsigned int tmp;
> -               if (!access_ok(VERIFY_READ, (int *)data, 17*sizeof(int))) {
> +               if (!access_ok(VERIFY_READ, (int *) A(data), 17*sizeof(int))) {
>                         ret = -EIO;
>                         break;
>                 }
>                 for ( i = 0; i < 17*sizeof(int); i += sizeof(int) ) {
> -                       __get_user(tmp, (unsigned int *) data);
> +                       __get_user(tmp, (unsigned int *) A(data));
>                         putreg(child, i, tmp);
>                         data += sizeof(int);
>                 }
> @@ -2426,11 +2425,11 @@
>               }
>
>               case IA32_PTRACE_GETFPREGS:
> -               ret = save_ia32_fpstate(child, (struct _fpstate_ia32 *)data);
> +               ret = save_ia32_fpstate(child, (struct _fpstate_ia32 *) A(data));
>                 break;
>
>               case IA32_PTRACE_SETFPREGS:
> -               ret = restore_ia32_fpstate(child, (struct _fpstate_ia32 *)data);
> +               ret = restore_ia32_fpstate(child, (struct _fpstate_ia32 *) A(data));
>                 break;
>
>               case PTRACE_SYSCALL:      /* continue, stop after next syscall */
> @@ -2558,7 +2558,7 @@
>  #define IOLEN  ((65536 / 4) * 4096)
>
>  asmlinkage long
> -sys_iopl (int level, long arg1, long arg2, long arg3)
> +sys_iopl (int level)
>  {
>         extern unsigned long ia64_iobase;
>         int fd;
> @@ -2570,7 +2570,7 @@
>         if (level != 3)
>                 return(-EINVAL);
>         /* Trying to gain more privileges? */
> -       __asm__ __volatile__("mov %0=ar.eflag ;;" : "=r"(old));
> +       asm volatile ("mov %0=ar.eflag ;;" : "=r"(old));
>         if (level > ((old >> 12) & 3)) {
>                 if (!capable(CAP_SYS_RAWIO))
>                         return -EPERM;
> @@ -2587,17 +2587,13 @@
>         }
>
>         down_write(&current->mm->mmap_sem);
> -       lock_kernel();
> -
>         addr = do_mmap_pgoff(file, IA32_IOBASE,
> -                       IOLEN, PROT_READ|PROT_WRITE, MAP_SHARED,
> -                       (ia64_iobase & ~PAGE_OFFSET) >> PAGE_SHIFT);
> -
> -       unlock_kernel();
> +                            IOLEN, PROT_READ|PROT_WRITE, MAP_SHARED,
> +                            (ia64_iobase & ~PAGE_OFFSET) >> PAGE_SHIFT);
>         up_write(&current->mm->mmap_sem);
>
>         if (addr >= 0) {
> -               __asm__ __volatile__("mov ar.k0=%0 ;;" :: "r"(addr));
> +               ia64_set_kr(IA64_KR_IO_BASE, addr);
>                 old = (old & ~0x3000) | (level << 12);
>                 __asm__ __volatile__("mov ar.eflag=%0 ;;" :: "r"(old));
>         }
> @@ -2608,7 +2604,7 @@
>  }
>
>  asmlinkage long
> -sys_ioperm (unsigned long from, unsigned long num, int on)
> +sys_ioperm (unsigned int from, unsigned int num, int on)
>  {
>
>         /*
> @@ -2621,7 +2617,7 @@
>          * XXX proper ioperm() support should be emulated by
>          *      manipulating the page protections...
>          */
> -       return(sys_iopl(3, 0, 0, 0));
> +       return sys_iopl(3);
>  }
>
>  typedef struct {
> diff -urN lia64/arch/ia64/kernel/semaphore.c lia64-kdb/arch/ia64/kernel/semaphore.c
> --- lia64/arch/ia64/kernel/semaphore.c  Wed Dec  6 18:36:35 2000
> +++ lia64-kdb/arch/ia64/kernel/semaphore.c      Fri Apr 13 20:48:40 2001
> @@ -321,13 +321,11 @@
>
>         if (count == 0) {
>                 /* wake a writer */
> -               if (xchg(&sem->write_bias_granted, 1))
> -                       BUG();
> +               xchg(&sem->write_bias_granted, 1);
>                 wq = &sem->write_bias_wait;
>         } else {
>                 /* wake reader(s) */
> -               if (xchg(&sem->read_bias_granted, 1))
> -                       BUG();
> +               xchg(&sem->read_bias_granted, 1);
>                 wq = &sem->wait;
>         }
>         wake_up(wq);    /* wake up everyone on the wait queue */
> diff -urN lia64/arch/ia64/kernel/sys_ia64.c lia64-kdb/arch/ia64/kernel/sys_ia64.c
> --- lia64/arch/ia64/kernel/sys_ia64.c   Thu Apr  5 09:57:58 2001
> +++ lia64-kdb/arch/ia64/kernel/sys_ia64.c       Fri Apr 13 14:23:57 2001
> @@ -253,13 +253,6 @@
>         return -ENOSYS;
>  }
>
> -asmlinkage long
> -sys_modify_ldt (long arg0, long arg1, long arg2, long arg3)
> -{
> -       printk(KERN_ERR "sys_modify_ldt(%lx, %lx, %lx, %lx)!\n", arg0, arg1, arg2, arg3);
> -       return -ENOSYS;
> -}
> -
>  asmlinkage unsigned long
>  ia64_create_module (const char *name_user, size_t size, long arg2, long arg3,
>                     long arg4, long arg5, long arg6, long arg7, long stack)
> diff -urN lia64/arch/ia64/kernel/process.c lia64-kdb/arch/ia64/kernel/process.c
> --- lia64/arch/ia64/kernel/process.c    Thu Apr  5 09:55:58 2001
> +++ lia64-kdb/arch/ia64/kernel/process.c        Fri Apr 13 12:25:19 2001
> @@ -143,7 +143,7 @@
>                 pfm_save_regs(task);
>  #endif
>         if (IS_IA32_PROCESS(ia64_task_regs(task)))
> -               ia32_save_state(&task->thread);
> +               ia32_save_state(task);
>  }
>
>  void
> @@ -156,7 +156,7 @@
>                 pfm_load_regs(task);
>  #endif
>         if (IS_IA32_PROCESS(ia64_task_regs(task)))
> -               ia32_load_state(&task->thread);
> +               ia32_load_state(task);
>  }
>
>  /*
> diff -urN lia64/include/asm-ia64/ia32.h lia64-kdb/include/asm-ia64/ia32.h
> --- lia64/include/asm-ia64/ia32.h       Thu Apr  5 11:51:44 2001
> +++ lia64-kdb/include/asm-ia64/ia32.h   Fri Apr 13 20:14:04 2001
> @@ -108,7 +108,7 @@
>  } sigset32_t;
>
>  struct sigaction32 {
> -       unsigned int  sa_handler;       /* Really a pointer, but need to deal
> +       unsigned int  sa_handler;       /* Really a pointer, but need to deal
>                                              with 32 bits */
>         unsigned int sa_flags;
>         unsigned int sa_restorer;       /* Another 32 bit pointer */
> @@ -118,7 +118,7 @@
>  typedef unsigned int old_sigset32_t;   /* at least 32 bits */
>
>  struct old_sigaction32 {
> -       unsigned int  sa_handler;       /* Really a pointer, but need to deal
> +       unsigned int  sa_handler;       /* Really a pointer, but need to deal
>                                              with 32 bits */
>         old_sigset32_t sa_mask;         /* A 32 bit mask */
>         unsigned int sa_flags;
> @@ -133,7 +133,7 @@
>
>  struct ucontext_ia32 {
>         unsigned int      uc_flags;
> -       unsigned int      uc_link;
> +       unsigned int      uc_link;
>         stack_ia32_t      uc_stack;
>         struct sigcontext_ia32 uc_mcontext;
>         sigset_t          uc_sigmask;   /* mask last for extensibility */
> @@ -252,6 +252,15 @@
>  #define ELF_ARCH       EM_386
>
>  #define IA32_PAGE_OFFSET       0xc0000000
> +#define IA32_STACK_TOP         ((IA32_PAGE_OFFSET/3) * 2)
> +
> +/*
> + * The system segments (GDT, TSS, LDT) have to be mapped below 4GB so the IA-32 engine can
> + * access them.
> + */
> +#define IA32_GDT_OFFSET                (IA32_PAGE_OFFSET)
> +#define IA32_TSS_OFFSET                (IA32_PAGE_OFFSET + PAGE_SIZE)
> +#define IA32_LDT_OFFSET                (IA32_PAGE_OFFSET + 2*PAGE_SIZE)
>
>  #define USE_ELF_CORE_DUMP
>  #define ELF_EXEC_PAGESIZE      IA32_PAGE_SIZE
> @@ -287,7 +296,7 @@
>
>  /* This macro yields a bitmask that programs can use to figure out
>     what instruction set this CPU supports.  */
> -#define ELF_HWCAP      0
> +#define ELF_HWCAP      0
>
>  /* This macro yields a string that ld.so will use to load
>     implementation specific libraries for optimization.  Not terribly
> @@ -304,58 +313,61 @@
>  /*
>   * IA-32 ELF specific definitions for IA-64.
>   */
> -
> +
>  #define __USER_CS      0x23
>  #define __USER_DS      0x2B
>
> -#define SEG_LIM     32
> -#define SEG_TYPE    52
> -#define SEG_SYS     56
> -#define SEG_DPL     57
> -#define SEG_P       59
> -#define SEG_DB      62
> -#define SEG_G       63
> -
>  #define FIRST_TSS_ENTRY 6
>  #define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY+1)
>  #define _TSS(n) ((((unsigned long) n)<<4)+(FIRST_TSS_ENTRY<<3))
>  #define _LDT(n) ((((unsigned long) n)<<4)+(FIRST_LDT_ENTRY<<3))
>
> -#define IA64_SEG_DESCRIPTOR(base, limit, segtype, nonsysseg, dpl, segpresent, segdb, granularity) \
> -              ((base)                         |       \
> -               (limit << SEG_LIM)             |       \
> -               (segtype << SEG_TYPE)          |       \
> -               (nonsysseg << SEG_SYS)         |       \
> -               (dpl << SEG_DPL)               |       \
> -               (segpresent << SEG_P)          |       \
> -               (segdb << SEG_DB)              |       \
> -               (granularity << SEG_G))
> -
> -#define IA32_SEG_BASE 16
> -#define IA32_SEG_TYPE 40
> -#define IA32_SEG_SYS  44
> -#define IA32_SEG_DPL  45
> -#define IA32_SEG_P    47
> -#define IA32_SEG_HIGH_LIMIT    48
> -#define IA32_SEG_AVL   52
> -#define IA32_SEG_DB    54
> -#define IA32_SEG_G     55
> -#define IA32_SEG_HIGH_BASE 56
> -
> -#define IA32_SEG_DESCRIPTOR(base, limit, segtype, nonsysseg, dpl, segpresent, avl, segdb, granularity) \
> -              ((limit & 0xFFFF)                               |       \
> -                (base & 0xFFFFFF << IA32_SEG_BASE)            |       \
> -               (segtype << IA32_SEG_TYPE)                     |       \
> -               (nonsysseg << IA32_SEG_SYS)                    |       \
> -               (dpl << IA32_SEG_DPL)                          |       \
> -               (segpresent << IA32_SEG_P)                     |       \
> -               (((limit >> 16) & 0xF) << IA32_SEG_HIGH_LIMIT) |       \
> -               (avl << IA32_SEG_AVL)                          |       \
> -               (segdb << IA32_SEG_DB)                         |       \
> -               (granularity << IA32_SEG_G)                    |       \
> -               (((base >> 24) & 0xFF) << IA32_SEG_HIGH_BASE))
> +#define IA32_SEG_BASE          16
> +#define IA32_SEG_TYPE          40
> +#define IA32_SEG_SYS           44
> +#define IA32_SEG_DPL           45
> +#define IA32_SEG_P             47
> +#define IA32_SEG_HIGH_LIMIT    48
> +#define IA32_SEG_AVL           52
> +#define IA32_SEG_DB            54
> +#define IA32_SEG_G             55
> +#define IA32_SEG_HIGH_BASE     56
> +
> +#define IA32_SEG_DESCRIPTOR(base, limit, segtype, nonsysseg, dpl, segpresent, avl, segdb, gran)        \
> +              (((limit) & 0xffff)                                                              \
> +               | (((unsigned long) (base) & 0xffffff) << IA32_SEG_BASE)                        \
> +               | ((unsigned long) (segtype) << IA32_SEG_TYPE)                                  \
> +               | ((unsigned long) (nonsysseg) << IA32_SEG_SYS)                                 \
> +               | ((unsigned long) (dpl) << IA32_SEG_DPL)                                       \
> +               | ((unsigned long) (segpresent) << IA32_SEG_P)                                  \
> +               | ((((unsigned long) (limit) >> 16) & 0xf) << IA32_SEG_HIGH_LIMIT)              \
> +               | ((unsigned long) (avl) << IA32_SEG_AVL)                                       \
> +               | ((unsigned long) (segdb) << IA32_SEG_DB)                                      \
> +               | ((unsigned long) (gran) << IA32_SEG_G)                                        \
> +               | ((((unsigned long) (base) >> 24) & 0xff) << IA32_SEG_HIGH_BASE))
> +
> +#define SEG_LIM                32
> +#define SEG_TYPE       52
> +#define SEG_SYS                56
> +#define SEG_DPL                57
> +#define SEG_P          59
> +#define SEG_AVL                60
> +#define SEG_DB         62
> +#define SEG_G          63
> +
> +/* Unscramble an IA-32 segment descriptor into the IA-64 format.  */
> +#define IA32_SEG_UNSCRAMBLE(sd)                                                                         \
> +       (   (((sd) >> IA32_SEG_BASE) & 0xffffff) | ((((sd) >> IA32_SEG_HIGH_BASE) & 0xff) << 24) \
> +        | ((((sd) & 0xffff) | ((((sd) >> IA32_SEG_HIGH_LIMIT) & 0xf) << 16)) << SEG_LIM)        \
> +        | ((((sd) >> IA32_SEG_TYPE) & 0xf) << SEG_TYPE)                                         \
> +        | ((((sd) >> IA32_SEG_SYS) & 0x1) << SEG_SYS)                                           \
> +        | ((((sd) >> IA32_SEG_DPL) & 0x3) << SEG_DPL)                                           \
> +        | ((((sd) >> IA32_SEG_P) & 0x1) << SEG_P)                                               \
> +        | ((((sd) >> IA32_SEG_AVL) & 0x1) << SEG_AVL)                                           \
> +        | ((((sd) >> IA32_SEG_DB) & 0x1) << SEG_DB)                                             \
> +        | ((((sd) >> IA32_SEG_G) & 0x1) << SEG_G))
>
> -#define IA32_IOBASE    0x2000000000000000 /* Virtual addres for I/O space */
> +#define IA32_IOBASE    0x2000000000000000 /* Virtual address for I/O space */
>
>  #define IA32_CR0       0x80000001      /* Enable PG and PE bits */
>  #define IA32_CR4       0              /* No architectural extensions */
> @@ -384,6 +396,25 @@
>         regs->r12 = new_sp;                                                     \
>  } while (0)
>
> +/*
> + * Local Descriptor Table (LDT) related declarations.
> + */
> +
> +#define IA32_LDT_ENTRIES       8192            /* Maximum number of LDT entries supported. */
> +#define IA32_LDT_ENTRY_SIZE    8               /* The size of each LDT entry. */
> +
> +struct ia32_modify_ldt_ldt_s {
> +       unsigned int entry_number;
> +       unsigned int base_addr;
> +       unsigned int limit;
> +       unsigned int seg_32bit:1;
> +       unsigned int contents:2;
> +       unsigned int read_exec_only:1;
> +       unsigned int limit_in_pages:1;
> +       unsigned int seg_not_present:1;
> +       unsigned int useable:1;
> +};
> +
>  extern void ia32_gdt_init (void);
>  extern int ia32_setup_frame1 (int sig, struct k_sigaction *ka, siginfo_t *info,
>                                sigset_t *set, struct pt_regs *regs);
> @@ -392,5 +423,5 @@
>  extern int ia32_exception (struct pt_regs *regs, unsigned long isr);
>
>  #endif /* !CONFIG_IA32_SUPPORT */
> -
> +
>  #endif /* _ASM_IA64_IA32_H */
> diff -urN lia64/include/asm-ia64/processor.h lia64-kdb/include/asm-ia64/processor.h
> --- lia64/include/asm-ia64/processor.h  Thu Apr  5 11:51:41 2001
> +++ lia64-kdb/include/asm-ia64/processor.h      Fri Apr 13 12:26:16 2001
> @@ -417,7 +417,7 @@
>  /*
>   * Free all resources held by a thread. This is called after the
>   * parent of DEAD_TASK has collected the exist status of the task via
> - * wait().  This is a no-op on IA-64.
> + * wait().
>   */
>  #ifdef CONFIG_PERFMON
>    extern void release_thread (struct task_struct *task);
> @@ -514,8 +514,8 @@
>  extern void ia64_load_debug_regs (unsigned long *save_area);
>
>  #ifdef CONFIG_IA32_SUPPORT
> -extern void ia32_save_state (struct thread_struct *thread);
> -extern void ia32_load_state (struct thread_struct *thread);
> +extern void ia32_save_state (struct task_struct *task);
> +extern void ia32_load_state (struct task_struct *task);
>  #endif
>
>  #ifdef CONFIG_PERFMON
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--
"When you see the correct course, act; do not wait for orders."
The Art of War

=======================================================================
  Josue Emmanuel Amaro                         Josue.Amaro@oracle.com
  Linux Products Manager                       Phone:   650.506.1239
  Intel and Linux Technologies Group           Fax:     650.413.0167
=======================================================================


--------------2A647AA2DC44AB402190DADC
Content-Type: text/x-vcard; charset=us-ascii;
 name="josue.amaro.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for Josue Amaro
Content-Disposition: attachment;
 filename="josue.amaro.vcf"

begin:vcard 
n:Amaro;Josue
tel;fax:650 413 0167
tel;work:650 506 1239
x-mozilla-html:FALSE
url:www.oracle.com
org:Oracle Corporation
version:2.1
email;internet:josue.amaro@oracle.com
title:Linux Products Manager
adr;quoted-printable:;;500 Oracle Parkway=0D=0AMS 401 ip 4;Redwood Shores;CA;94065;United States
fn:Josue Amaro
end:vcard

--------------2A647AA2DC44AB402190DADC--


