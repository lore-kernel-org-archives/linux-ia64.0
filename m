From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Mon, 08 Jun 2015 14:57:09 +0000
Subject: Generic kernel features that need architecture(ia64) support
Message-Id: <5575AD45.5080607@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

If there is anything wrong, please report it in this thread:
https://marc.info/?t3332955700003


The meaning of entries in the tables is:

    | ok |  # feature supported by the architecture
    |TODO|  # feature not yet supported by the architecture
    | .. |  # feature cannot be supported by the hardware

#
# Kernel feature support matrix of the 'ia64' architecture:
#
      time/ irq-time-acct        :  ..  |            HAVE_IRQ_TIME_ACCOUNTING #  arch supports precise IRQ time accounting
      core/ generic-idle-thread  :  ok  |             GENERIC_SMP_IDLE_THREAD #  arch makes use of the generic SMP idle thread facility
      core/ tracehook            :  ok  |                 HAVE_ARCH_TRACEHOOK #  arch supports tracehook (ptrace) register handling APIs
     debug/ kprobes              :  ok  |                        HAVE_KPROBES #  arch supports live patched kernel probe
     debug/ kretprobes           :  ok  |                     HAVE_KRETPROBES #  arch supports kernel function-return probes
        io/ dma-api-debug        :  ok  |                  HAVE_DMA_API_DEBUG #  arch supports DMA debug facilities
        io/ dma_map_attrs        :  ok  |                      HAVE_DMA_ATTRS #  arch provides dma_*map*_attrs() APIs
        io/ sg-chain             :  ok  |                   ARCH_HAS_SG_CHAIN #  arch supports chained scatter-gather lists
   locking/ rwsem-optimized      :  ok  |               Optimized asm/rwsem.h #  arch provides optimized rwsem APIs
      time/ modern-timekeeping   :  ok  |            !ARCH_USES_GETTIMEOFFSET #  arch does not use arch_gettimeoffset() anymore
      time/ virt-cpuacct         :  ok  |            HAVE_VIRT_CPU_ACCOUNTING #  arch supports precise virtual CPU time accounting
        vm/ numa-memblock        :  ok  |              HAVE_MEMBLOCK_NODE_MAP #  arch supports NUMA aware memblocks
        vm/ PG_uncached          :  ok  |               ARCH_USES_PG_UNCACHED #  arch supports the PG_uncached page flag
      core/ BPF-JIT              : TODO |                        HAVE_BPF_JIT #  arch supports BPF JIT optimizations
      core/ jump-labels          : TODO |                HAVE_ARCH_JUMP_LABEL #  arch supports live patched, high efficiency branches
     debug/ gcov-profile-all     : TODO |           ARCH_HAS_GCOV_PROFILE_ALL #  arch supports whole-kernel GCOV code coverage profiling
     debug/ KASAN                : TODO |                     HAVE_ARCH_KASAN #  arch supports the KASAN runtime memory checker
     debug/ kgdb                 : TODO |                      HAVE_ARCH_KGDB #  arch supports the kGDB kernel debugger
     debug/ kprobes-on-ftrace    : TODO |              HAVE_KPROBES_ON_FTRACE #  arch supports combined kprobes and ftrace live patching
     debug/ optprobes            : TODO |                      HAVE_OPTPROBES #  arch supports live patched optprobes
     debug/ stackprotector       : TODO |              HAVE_CC_STACKPROTECTOR #  arch supports compiler driven stack overflow protection
     debug/ uprobes              : TODO |               ARCH_SUPPORTS_UPROBES #  arch supports live patched user probes
     debug/ user-ret-profiler    : TODO |           HAVE_USER_RETURN_NOTIFIER #  arch supports user-space return from system call profiler
        io/ dma-contiguous       : TODO |                 HAVE_DMA_CONTIGUOUS #  arch supports the DMA CMA (continuous memory allocator)
       lib/ strncasecmp          : TODO |             __HAVE_ARCH_STRNCASECMP #  arch provides an optimized strncasecmp() function
   locking/ cmpxchg-local        : TODO |                  HAVE_CMPXCHG_LOCAL #  arch supports the this_cpu_cmpxchg() API
   locking/ lockdep              : TODO |                     LOCKDEP_SUPPORT #  arch supports the runtime locking correctness debug facility
   locking/ queued-rwlocks       : TODO |             ARCH_USE_QUEUED_RWLOCKS #  arch supports queued rwlocks
   locking/ queued-spinlocks     : TODO |           ARCH_USE_QUEUED_SPINLOCKS #  arch supports queued spinlocks
      perf/ kprobes-event        : TODO |      HAVE_REGS_AND_STACK_ACCESS_API #  arch supports kprobes with perf events
      perf/ perf-regs            : TODO |                      HAVE_PERF_REGS #  arch supports perf events register access
      perf/ perf-stackdump       : TODO |           HAVE_PERF_USER_STACK_DUMP #  arch supports perf events stack dumps
     sched/ numa-balancing       : TODO |        ARCH_SUPPORTS_NUMA_BALANCING #  arch supports NUMA balancing
   seccomp/ seccomp-filter       : TODO |            HAVE_ARCH_SECCOMP_FILTER #  arch supports seccomp filters
      time/ arch-tick-broadcast  : TODO |             ARCH_HAS_TICK_BROADCAST #  arch provides tick_broadcast()
      time/ clockevents          : TODO |                 GENERIC_CLOCKEVENTS #  arch support generic clock events
      time/ context-tracking     : TODO |               HAVE_CONTEXT_TRACKING #  arch supports context tracking for NO_HZ_FULL
        vm/ ELF-ASLR             : TODO |              ARCH_HAS_ELF_RANDOMIZE #  arch randomizes the stack, heap and binary images of ELF binaries
        vm/ huge-vmap            : TODO |                 HAVE_ARCH_HUGE_VMAP #  arch supports the ioremap_pud_enabled() and ioremap_pmd_enabled() VM APIs
        vm/ ioremap_prot         : TODO |                   HAVE_IOREMAP_PROT #  arch has ioremap_prot()
        vm/ pmdp_splitting_flush : TODO |    __HAVE_ARCH_PMDP_SPLITTING_FLUSH #  arch supports the pmdp_splitting_flush() VM API
        vm/ pte_special          : TODO |             __HAVE_ARCH_PTE_SPECIAL #  arch supports the pte_special()/pte_mkspecial() VM APIs
        vm/ THP                  : TODO |      HAVE_ARCH_TRANSPARENT_HUGEPAGE #  arch supports transparent hugepages
