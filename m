From: JinShan Xiong <jinshan.xiong@gmail.com>
Date: Thu, 27 Jan 2005 04:54:40 +0000
Subject: About intercepting linux system call
Message-Id: <b3b26beb05012620543066d40@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all, 

i just want to intercept ia64 linux kernel's syscall entry. I remapped
the physical page contained syscall table to a new read/write page in
a vmalloc region(0xa0000...) since ia64 linux kernel has been linked
the syscall table into a .rodata section, Yes, I can modify the
syscall entry now, but the kernel crashed after the kernel entered
into my own new function.

I run my test code on a Hp-ia64 machine with redhat AS-2.1e installed,
and the kernel is 2.4.18-e.47smp.

I am not familiar with ia64 architecture, please help me, thanks. 

dauglas 

Here is my test code: 

/* vi: set ts=4 sw=4 expandtab: */ 

#include <linux/config.h> 
#include <linux/kernel.h> 
#include <linux/module.h> 
#include <linux/unistd.h> 
#include <linux/sched.h> 
#include <asm/pgtable.h> 
#include <linux/vmalloc.h> 
#include <linux/mm.h> 
#include <asm/uaccess.h> 

extern void *sys_call_table[]; 

//static long (*old_time)(struct timeval *, struct timezone *); 
static long (*old_time)(int); 


static asmlinkage long new_time(struct timeval *tv, struct timezone *tz) 
{ 
   if (tv) { 
       struct timeval ktv; 
       do_gettimeofday(&ktv); 
       if (copy_to_user(tv, &ktv, sizeof(ktv))) 
           return -EFAULT; 
   } 
   if (tz) { 
       extern struct timezone sys_tz; 
       if (copy_to_user(tz, &sys_tz, sizeof(sys_tz))) 
           return -EFAULT; 
   } 
   return 0;int init_module(void) 
{ 
   pte_t *pte; 
   pmd_t *pmd; 
   pgd_t *pgd; 
   unsigned long addr, phys_addr; 
   unsigned long new_addr; 
   int ret; 
   struct page *page; 

   addr = (unsigned long)(&sys_call_table[1025- 1024 ]); 
   printk("Time entry's address: %llx, *addr = %llx!\n", 
       addr, *(unsigned long*)addr); 

   page = virt_to_page(addr); 
   printk("page = %p\n", page); 
   SetPageReserved(page); 

   phys_addr = __pa(addr); 

   new_addr = vmalloc(PAGE_SIZE); 
   vfree(new_addr); 

   phys_addr = phys_addr & ~(PAGE_SIZE - 1); 
   ret = remap_page_range((unsigned long)new_addr, phys_addr,
PAGE_SIZE, PAGE_KERNEL);
   if(ret) { 
       printk("remap page return with error = %d\n", ret); 
       return ret; 
   } 


   pgd = pgd_offset_k(new_addr);   printk("pgd = %p\n", pgd); 
   pmd = pmd_offset(pgd, new_addr); 
   if(pmd_none(*pmd)) { 
       printk("address: %llx has no pmd!\n", new_addr); 
       return -1; 
   } 

   pte = pte_offset(pmd, new_addr); 
   if(pte_none(*pte)) { 
       /* Why? */ 
       printk("No pte!\n"); 
       set_pte(pte, mk_pte_phys(phys_addr, PAGE_KERNEL)); 
       if(pte_none(*pte)) { 
           printk("Can't set pte!\n"); 
           return -1; 
       } 
   } 


   if(pte_write(*pte)) { 
       printk("sys_call_table is writable!\n"); 
   } else { 
       printk("sys_call_table is read-only!\n"); 
   } 

   { 
       unsigned long x; 

       x = new_addr + (addr & (PAGE_SIZE - 1)); 

       old_time = *(unsigned long *)addr; 

  printk("pgd = %p\n", pgd); 
   pmd = pmd_offset(pgd, new_addr); 
   if(pmd_none(*pmd)) { 
       printk("address: %llx has no pmd!\n", new_addr); 
       return -1; 
   } 

   pte = pte_offset(pmd, new_addr); 
   if(pte_none(*pte)) { 
       /* Why? */ 
       printk("No pte!\n"); 
       set_pte(pte, mk_pte_phys(phys_addr, PAGE_KERNEL)); 
       if(pte_none(*pte)) { 
           printk("Can't set pte!\n"); 
           return -1; 
       } 
   } 


   if(pte_write(*pte)) { 
       printk("sys_call_table is writable!\n"); 
   } else { 
       printk("sys_call_table is read-only!\n"); 
   } 

   { 
       unsigned long x; 

       x = new_addr + (addr & (PAGE_SIZE - 1)); 

       old_time = *(unsigned long *)addr; 

       *(unsigned long *)x = (unsigned long)new_time; //+ 0x4000000000000000; 
       printk("x = %llx\n", x); 
   } 

   printk("*addr = %llx\n", *(unsigned long *)addr); 


   pte_clear(pte); 

   return 0; 
} 

void cleanup_module() 
{ 
   printk("Byebye!\n"); 
} 

Here is kernel crash msg: 

Time entry's address: e000000004883a80, *addr = e0000000044913e0! 
page = a0007fff8e47ee00 
pgd = e00000000493c000 
No pte! 
sys_call_table is writable! 
x = a00000000032ba80 
*addr = e000000000319d70 
insmod[1279]: IA-64 Illegal operation fault 0 
--> __insmod_ro_S.rodata_L296 [ro] 0x7da <-- 

Pid: 1279, comm:               insmod 
psr : 0000141008026018 ifs : 8000000000000008 ip  :
[<e000000000319d72>]    Tainted: P
unat: 0000000000000000 pfs : 0000000000000008 rsc : 0000000000000003 
rnat: e0000003fc454658 bsps: 0010000000000661 pr  : 0000000000000199 
ldrs: 0000000000000000 ccv : 00000000000001ad fpsr: 0009804c0270033f 
b0  : e00000000440df00 b6  : e000000004402f60 b7  : 0000000000000000 
f6  : 1003e000000000877c629 f7  : 1003efb93e672fa98528d 
f8  : 1003e0000000000000180 f9  : 10003c000000000000000 
r1  : e000000004cf5760 r2  : 0000000000000000 r3  : 00000000000000ff 
r8  : e0000001104a7f00 r9  : 20000000002a4fc0 r10 : ffffffffffffffff 
r11 : 60000fffffff4ab0 r12 : e0000001104a7e60 r13 : e0000001104a0000 
r14 : e000000000000000 r15 : e00000000440df00 r16 : e0000001104a7e70 
r17 : e0000001104a7e78 r18 : 00001413085a6010 r19 : 20000000001a7610 
r20 : 0000000000000002 r21 : 20000000000588a0 r22 : 400000000002fe88 
r23 : 0000000000000010 r24 : 20000000002a7900 r25 : 20000000002a78f8 
r26 : 60000000000243d8 r27 : 20000000002a44c0 r28 : 200000000014d160 
r29 : 0000000000000000 r30 : 0000000000000001 r31 : 0000000000000000 

Call Trace: [<e000000004414910>] sp=0xe0000001104a79c0 bsp=0xe0000001104a1108 
decoded to show_stack [kernel] 0x50 
[<e000000004415140>] sp=0xe0000001104a7b80 bsp=0xe0000001104a10b0 
decoded to show_regs [kernel] 0x7c0 
[<e00000000442fd90>] sp=0xe0000001104a7ba0 bsp=0xe0000001104a1088 
decoded to die [kernel] 0x190 
[<e00000000442fe60>] sp=0xe0000001104a7ba0 bsp=0xe0000001104a1060 
decoded to die_if_kernel [kernel] 0x40 
[<e000000004430af0>] sp=0xe0000001104a7ba0 bsp=0xe0000001104a1048 
decoded to ia64_illegal_op_fault [kernel] 0x50 
[<e000000004403ed0>] sp=0xe0000001104a7cc0 bsp=0xe0000001104a1048 
decoded to dispatch_illegal_op_fault [kernel] 0x2b0 
<0>Kernel panic: not continuing
