From: suganuma <suganuma@hpc.bs1.fc.nec.co.jp>
Date: Tue, 18 Feb 2003 02:16:11 +0000
Subject: Re: [Linux-ia64] Re: 2.5.59 & mmap_sem deadlock ?
Message-Id: <marc-linux-ia64-105590709805866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805865@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805865@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think copy_page_range() should check that the pfn is valid or not
before calling pfn_to_page(), or make pfn_to_page() to return
some pointer indicating "invalid_page" when argument is invalid pfn.

Anyway, I don't think it's good idea to consider that all addresses
outside of physical memory range belongs to last node.

Regards,
Kimi

On Mon, 17 Feb 2003 18:38:46 +0100 (NFT)
Xavier Bru  <Xavier.Bru@bull.net> wrote:

> 
> Looking a little more into the problem, I could understand why this
> appears only with CONFIG_NUMA set.
> I found that the page fault occurs upon duplication of the vm_area 
> corresponding to the PCI I/O space.
> 
> The PCI I/O space is mmapped using /dev/mem by  the libc ioperm() code.
> 
> On the platform (4 * 64 GB nodes), the I/O space is mapped at address
> (relatively standard) 0xffffc000000, that means outside the 256 GB
> RAM, behind the 3rd node. (Unlike the PCI memory space that is mapped
> in node 0)).
> 
> The copy_page_range() routine uses pfn_to_page() that handles memory
> maps on a per-node basis:
> 
> #define pfn_to_page(pfn)	(struct page *)(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
> 
> #define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> DIG_BANKSHIFT]
> 
> nid is wrongly computed in this case.
> 
> Do you think that assuming that all physical addresses > 256 GB is in
> last present node could solve the problem ?
> Thanks in advance.
> Xavier
> 
> ---- traces 
> 
> open("/dev/mem", O_RDWR|O_SYNC)         = 5
> mmap(NULL, 67108864, PROT_READ|PROT_WRITE, MAP_SHARED, 5, 0xffffc000000) = 0x2000000000400000
> 
> $3 = {dst = 0xe0000010015ecc80, src = 0xe0000010fff8de80, 
>   vma = 0xe0000020d1bc7000, address = 0x2000000000400000, 
>   end = 0x2000000004400000, src_pgd = 0xe000001091a54800, 
>   dst_pgd = 0xe00000103f470800, src_pmd = 0xe0000010b4c94000, 
>   dst_pmd = 0xe0000010c8094000, src_pte = 0xe00000102bc68800, 
>   dst_pte = 0xe0000010c3e50800, page = 0xe0000010009b8030
> 
> 2000000000400000-2000000004400000 rw-s 00000ffffc000000 08:03 98347      /dev/mem
> 2000000004400000-2000000004410000 rw-s 00000000000a0000 08:03 98347      /dev/mem
> 2000000004500000-2000000004900000 rw-s 00000000fc000000 08:03 98347      /dev/mem
> 2000000004900000-2000000004904000 rw-s 00000000fd1fc000 08:03 98347
> /dev/mem
> 
> Xavier Bru writes:
>  > 
>  > Hi,
>  > 
>  > Running 2.5.59 ia64 kernel with CONFIG_NUMA set, it seems that the Xserver
>  > sometimes deadlocks on the mmap_sem.
>  > I am wondering if having a page fault in copy_page_range() is at the
>  > origin of the problem or there is a recursion problem with the lock:
>  > 
>  > dup_mmap
>  > 	down_write(&oldmm->mmap_sem);
>  > 	copy_page_range
>  > 		ia64_do_page_fault
>  > 			down_read(&mm->mmap_sem);
>  > 
>  > traces ----------------------------------------------------------------------
>  > 
>  > [0]kdb> btp 1125 
>  > 0xe0000001dc258000 00001125 00001115  0  003  stop  0xe0000001dc258600 X
>  > 0xe000000004468d90 schedule+0xa90
>  >         args (0x9556958095595657, 0x4000, 0x0, 0xa0000000000127d8, 0xe000000182344e90)
>  >         kernel <NULL> 0x0 0xe000000004468300 0x0
>  > 0xe0000000046497a0 __down_read+0x1c0
>  >         args (0xe0000001dc258000, 0x2, 0xe0000001dc25f9e8, 0xe0000000044499e0, 0x58f)
>  >         kernel <NULL> 0x0 0xe0000000046495e0 0x0
>  > 0xe0000000044499e0 ia64_do_page_fault+0x220
>  >         args (0xe0000001bc992a80, 0x80400000000, 0xe0000001dc25fa80, 0xe0000001ffff1e40, 0x20)
>  >         kernel <NULL> 0x0 0xe0000000044497c0 0x0
>  > 0xe00000000440d6a0 ia64_leave_kernel
>  >         args (0xe0000001bc992a80, 0x80400000000, 0xe0000001dc25fa80)
>  >         kernel <NULL> 0x0 0xe00000000440d6a0 0x0
>  > 0xe0000000044ba070 copy_page_range+0x4d0
>  >         args (0xe0000001fc74f680, 0xe0000001bc992a80, 0xe000001001f28428, 0x100ffffc0005b1, 0xe0000001c0500800)
>  >         kernel <NULL> 0x0 0xe0000000044b9ba0 0x0
>  > 0xe000000004471830 dup_mmap+0x4d0
>  >         args (0xe0000001fc74f680, 0xe0000001bc992ab8, 0xe000001001f28400, 0xe000003007832300, 0xe000001001f28450)
>  >         kernel <NULL> 0x0 0xe000000004471360 0x0
>  > 0xe00000000446ef40 copy_mm+0x1c0
>  >         args (0xe0000001fc74f680, 0xfffffffffffffff4, 0xe0000001bc992a80, 0xe0000001b1c980b0, 0xe0000001b1c980a8)
>  >         kernel <NULL> 0x0 0xe00000000446ed80 0x0
>  > [0]more> 
>  > 0xe0000000044700c0 copy_process+0x800
>  >         args (0x11, 0x0, 0xe0000001dc25fe70, 0x10, 0xe0000001b1c98118)
>  >         kernel <NULL> 0x0 0xe00000000446f8c0 0x0
>  > 0xe000000004470f10 do_fork+0x70
>  >         args (0x11, 0x0, 0xe0000001dc25fe70, 0x10, 0x4000000000153830)
>  >         kernel <NULL> 0x0 0xe000000004470ea0 0x0
>  > 0xe00000000440d020 sys_clone+0x60
>  >         args (0x11, 0x0, 0x4000000000153830, 0xc00000000000040d, 0xe00000000440d680)
>  >         kernel <NULL> 0x0 0xe00000000440cfc0 0x0
>  > 0xe00000000440d680 ia64_ret_from_syscall
>  >         args (0x11, 0x0)
>  >         kernel <NULL> 0x0 0xe00000000440d680 0x0
>  > 
>  > (gdb) print *(struct task_struct *)0xe0000001dc258000
>  > $1 = {state = 2, thread_info = 0xe0000001dc258fd0, usage = {counter = 7}, 
>  >   flags = 256, ptrace = 0, lock_depth = -1, prio = 116, static_prio = 120, 
>  >   run_list = {next = 0xe000000004b08f08, prev = 0xe000000004b08f08}, 
>  >   array = 0x0, sleep_avg = 1953, sleep_timestamp = 604406, policy = 0, 
>  >   cpus_allowed = 18446744073709551615, time_slice = 111, first_time_slice = 0, 
>  >   tasks = {next = 0xe000002001740078, prev = 0xe0000001cb2d0078}, 
>  >   ptrace_children = {next = 0xe0000001dc258088, prev = 0xe0000001dc258088}, 
>  >   ptrace_list = {next = 0xe0000001dc258098, prev = 0xe0000001dc258098}, 
>  >   mm = 0xe0000001bc992a80, active_mm = 0xe0000001bc992a80, 
>  > ...
>  > (gdb) print *(struct mm_struct *)0xe0000001bc992a80
>  > $2 = {mmap = 0xe0000001c0537e00, mm_rb = {rb_node = 0xe0000001c0537d30}, 
>  >   mmap_cache = 0x0, free_area_cache = 2305843009213693952, 
>  >   pgd = 0xe0000001c2764000, mm_users = {counter = 4}, mm_count = {
>  >     counter = 1}, map_count = 57, mmap_sem = {activity = -1, wait_lock = {
>  > 						XXXXXXXXXXX
>  >       lock = 0}, wait_list = {next = 0xe0000001dc25f9d0, 
>  >       prev = 0xe0000001c374fd10}}, page_table_lock = {lock = 1}, mmlist = {
>  > 							XXXX
>  > 
>  > -- 
>  > 
>  >  Sinc蓿es salutations.
>  > _____________________________________________________________________
>  >  
>  > Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
>  > tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
>  > fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
>  > addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
>  > _____________________________________________________________________
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
suganuma <suganuma@hpc.bs1.fc.nec.co.jp>


