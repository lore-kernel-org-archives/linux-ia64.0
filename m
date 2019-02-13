From: Chen Rong <rong.a.chen@intel.com>
Date: Wed, 13 Feb 2019 09:19:36 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <20190213091936.GA22829@shao2-debian>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "IngoMolnar@shao2-debian" <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

Hi all,

Kernel test robot reported a will-it-scale.per_thread_ops -64.1% regression on IVB-desktop for v4.20-rc1.
The first bad commit is: 9bc8039e715da3b53dbac89525323a9f2f69b7b5, Yang Shi <yang.shi@linux.alibaba.com>: mm: brk: downgrade mmap_sem to read when shrinking
(https://lists.01.org/pipermail/lkp/2018-November/009335.html).

============================================compiler/cpufreq_governor/kconfig/mode/nr_task/rootfs/tbox_group/test/testcase/ucode:
  gcc-7/performance/x86_64-rhel-7.2/thread/100%/debian-x86_64-2018-04-03.cgz/lkp-ivb-d01/brk1/will-it-scale/0x20

commit: 
  85a06835f6 ("mm: mremap: downgrade mmap_sem to read when shrinking")
  9bc8039e71 ("mm: brk: downgrade mmap_sem to read when shrinking")

85a06835f6f1ba79 9bc8039e715da3b53dbac89525 
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
    196250 ±  8%     -64.1%      70494        will-it-scale.per_thread_ops
    127330 ± 19%     -98.0%       2525 ± 24%  will-it-scale.time.involuntary_context_switches
    727.50 ±  2%     -77.0%     167.25        will-it-scale.time.percent_of_cpu_this_job_got
      2141 ±  2%     -77.6%     479.12        will-it-scale.time.system_time
     50.48 ±  7%     -48.5%      25.98        will-it-scale.time.user_time
  34925294 ± 18%    +270.3%  1.293e+08 ±  4%  will-it-scale.time.voluntary_context_switches
   1570007 ±  8%     -64.1%     563958        will-it-scale.workload
      6435 ±  2%      -6.4%       6024        proc-vmstat.nr_shmem
      1298 ± 16%     -44.5%     721.00 ± 18%  proc-vmstat.pgactivate
      2341           +16.4%       2724        slabinfo.kmalloc-96.active_objs
      2341           +16.4%       2724        slabinfo.kmalloc-96.num_objs
      6346 ±150%     -87.8%     776.25 ±  9%  softirqs.NET_RX
    160107 ±  8%    +151.9%     403273        softirqs.SCHED
   1097999           -13.0%     955526        softirqs.TIMER
      5.50 ±  9%     -81.8%       1.00        vmstat.procs.r
    230700 ± 19%    +269.9%     853292 ±  4%  vmstat.system.cs
     26706 ±  3%     +15.7%      30910 ±  5%  vmstat.system.in
     11.24 ± 23%     +72.2       83.39        mpstat.cpu.idle%
      0.00 ±131%      +0.0        0.04 ± 99%  mpstat.cpu.iowait%
     86.32 ±  2%     -70.8       15.54        mpstat.cpu.sys%
      2.44 ±  7%      -1.4        1.04 ±  8%  mpstat.cpu.usr%
  20610709 ± 15%   +2376.0%  5.103e+08 ± 34%  cpuidle.C1.time
   3233399 ±  8%    +241.5%   11042785 ± 25%  cpuidle.C1.usage
  36172040 ±  6%    +931.3%   3.73e+08 ± 15%  cpuidle.C1E.time
    783605 ±  4%    +548.7%    5083041 ± 18%  cpuidle.C1E.usage
  28753819 ± 39%   +1054.5%  3.319e+08 ± 49%  cpuidle.C3.time
    283912 ± 25%    +688.4%    2238225 ± 34%  cpuidle.C3.usage
 1.507e+08 ± 47%    +292.3%  5.913e+08 ± 28%  cpuidle.C6.time
    339861 ± 37%    +549.7%    2208222 ± 24%  cpuidle.C6.usage
   2709719 ±  5%    +824.2%   25043444        cpuidle.POLL.time
  28602864 ± 18%    +173.7%   78276116 ± 10%  cpuidle.POLL.usage


We found that the patchset could fix the regression.

tests: 1
testcase/path_params/tbox_group/run: will-it-scale/performance-thread-100%-brk1-ucode=0x20/lkp-ivb-d01

commit: 
  85a06835f6 ("mm: mremap: downgrade mmap_sem to read when shrinking")
  fb835fe7f0 ("locking/rwsem: Ensure an RT task will not spin on reader")

85a06835f6f1ba79  fb835fe7f0adbd7c2c074b98ec  
----------------  --------------------------  
         %stddev      change         %stddev
             \          |                \  
    120736 ± 22%        56%     188019 ±  6%  will-it-scale.time.involuntary_context_switches
      2126 ±  3%         4%       2215        will-it-scale.time.system_time
       722 ±  3%         4%        752        will-it-scale.time.percent_of_cpu_this_job_got
  36256485 ± 27%       -35%   23682989 ±  3%  will-it-scale.time.voluntary_context_switches
      3151 ±  9%        11%       3504        turbostat.Avg_MHz
    229285 ± 32%       -30%     160660 ±  3%  vmstat.system.cs
    120736 ± 22%        56%     188019 ±  6%  time.involuntary_context_switches
      2126 ±  3%         4%       2215        time.system_time
       722 ±  3%         4%        752        time.percent_of_cpu_this_job_got
  36256485 ± 27%       -35%   23682989 ±  3%  time.voluntary_context_switches
        23             643%        171 ±  3%  proc-vmstat.nr_zone_inactive_file
        23             643%        171 ±  3%  proc-vmstat.nr_inactive_file
      3664              12%       4121        proc-vmstat.nr_kernel_stack
      6392               6%       6785        proc-vmstat.nr_slab_unreclaimable
      9991                       10176        proc-vmstat.nr_slab_reclaimable
     63938                       62394        proc-vmstat.nr_zone_active_anon
     63938                       62394        proc-vmstat.nr_active_anon
    386388 ±  9%        -6%     362272        proc-vmstat.pgfree
    368296 ±  9%       -10%     333074        proc-vmstat.numa_hit
    368296 ±  9%       -10%     333074        proc-vmstat.numa_local
      5169 ± 13%       -28%       3745        proc-vmstat.nr_shmem
      1801 ± 21%       -83%        309        proc-vmstat.pgactivate
         0            1e+04      11441        latency_stats.avg.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     13165 ±222%     -1e+04          0        latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
     22499 ±151%     -2e+04        657 ±  7%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
    117414 ±181%     -9e+04      24418 ± 44%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
    666005 ±218%     -7e+05        198 ±141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
   2600097 ±132%     -3e+06        572        latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
  34391390 ±150%     -3e+07      21807 ±141%  latency_stats.avg.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
  34624774 ±149%     -3e+07      37668 ± 58%  latency_stats.avg.max
         0            1e+04      11441        latency_stats.max.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     22499 ±151%     -2e+04        657 ±  7%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     37845 ±222%     -4e+04          0        latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
     80096 ± 59%     -8e+04          0        latency_stats.max.call_rwsem_down_write_failed_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
    177149 ±195%     -2e+05      24418 ± 44%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
    689417 ±209%     -7e+05        200 ±141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
  18679699 ±129%     -2e+07        656        latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
  83587334 ±129%     -8e+07      43457 ±141%  latency_stats.max.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
  84867236 ±126%     -8e+07      59318 ± 86%  latency_stats.max.max
         0            1e+04      11441        latency_stats.sum.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     22499 ±151%     -2e+04        657 ±  7%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     39431 ±222%     -4e+04          0        latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
    216448 ±200%     -2e+05      24418 ± 44%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
    691960 ±208%     -7e+05        397 ±141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
  24239011 ±140%     -2e+07       4768 ± 10%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
 1.771e+08 ±122%     -2e+08      43614 ±141%  latency_stats.sum.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
 1.939e+08 ± 36%     -2e+08          0        latency_stats.sum.call_rwsem_down_write_failed_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
 2.943e+08 ± 51%     -2e+08   51929782        latency_stats.sum.max
    407463 ± 10%      -100%          0        perf-stat.total.page-faults
  74225651 ± 26%      -100%          0        perf-stat.total.context-switches
     55293 ± 25%      -100%          0        perf-stat.total.cpu-migrations
    407463 ± 10%      -100%          0        perf-stat.total.minor-faults


tests: 1
testcase/path_params/tbox_group/run: will-it-scale/performance-thread-100%-brk1-ucode=0x20/lkp-ivb-d01

commit: 
  9bc8039e71 ("mm: brk: downgrade mmap_sem to read when shrinking")
  fb835fe7f0 ("locking/rwsem: Ensure an RT task will not spin on reader")

9bc8039e715da3b5  fb835fe7f0adbd7c2c074b98ec  
----------------  --------------------------  
         %stddev      change         %stddev
             \          |                \  
      3500 ± 36%      5272%     188019 ±  6%  will-it-scale.time.involuntary_context_switches
       483             358%       2215        will-it-scale.time.system_time
       168             346%        752        will-it-scale.time.percent_of_cpu_this_job_got
     71190             180%     199232 ±  4%  will-it-scale.per_thread_ops
    569524             180%    1593862 ±  4%  will-it-scale.workload
     25.85              93%      49.95 ±  3%  will-it-scale.time.user_time
 1.314e+08 ±  3%       -82%   23682989 ±  3%  will-it-scale.time.voluntary_context_switches
     30501 ±  9%       -15%      25813 ±  4%  vmstat.system.in
    799593 ± 10%       -80%     160660 ±  3%  vmstat.system.cs
       887 ± 11%       295%       3504        turbostat.Avg_MHz
     23.60 ± 10%        68%      39.54        turbostat.CorWatt
     28.38 ±  8%        57%      44.43        turbostat.PkgWatt
      3500 ± 36%      5272%     188019 ±  6%  time.involuntary_context_switches
       483             358%       2215        time.system_time
       168             346%        752        time.percent_of_cpu_this_job_got
     25.85              93%      49.95 ±  3%  time.user_time
 1.314e+08 ±  3%       -82%   23682989 ±  3%  time.voluntary_context_switches
         0 ± 44%     46220%        386        proc-vmstat.nr_zone_active_file
         0 ± 44%     46220%        386        proc-vmstat.nr_active_file
        23             643%        171 ±  3%  proc-vmstat.nr_zone_inactive_file
        23             643%        171 ±  3%  proc-vmstat.nr_inactive_file
      3690              12%       4121        proc-vmstat.nr_kernel_stack
      6419               6%       6785        proc-vmstat.nr_slab_unreclaimable
      9961                       10176        proc-vmstat.nr_slab_reclaimable
    229251                      231278        proc-vmstat.nr_zone_unevictable
    229251                      231278        proc-vmstat.nr_unevictable
      1008                        1005        proc-vmstat.nr_page_table_pages
     63178                       62394        proc-vmstat.nr_zone_active_anon
     63178                       62394        proc-vmstat.nr_active_anon
    432061 ± 12%       -11%     385372        proc-vmstat.pgfault
    408099 ± 10%       -11%     362272        proc-vmstat.pgfree
    422206 ±  9%       -11%     373690        proc-vmstat.pgalloc_normal
    382357 ± 11%       -13%     333074        proc-vmstat.numa_hit
    382357 ± 11%       -13%     333074        proc-vmstat.numa_local
      4428 ± 17%       -15%       3745        proc-vmstat.nr_shmem
         0            1e+04      11441        latency_stats.avg.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11180 ±168%     -1e+04        657 ±  7%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     19239 ±223%     -2e+04          0        latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
     63702 ±169%     -4e+04      24418 ± 44%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
     77617 ±205%     -8e+04        510 ± 11%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
   3043762 ±124%     -3e+06        572        latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
  11630441 ±139%     -1e+07      21807 ±141%  latency_stats.avg.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
  12242832 ±129%     -1e+07      37668 ± 58%  latency_stats.avg.max
         0            1e+04      11441        latency_stats.max.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11180 ±168%     -1e+04        657 ±  7%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     19239 ±223%     -2e+04          0        latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
     29152 ± 11%     -3e+04          0        latency_stats.max.call_rwsem_down_write_failed_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     65909 ±164%     -4e+04      24418 ± 44%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
     77617 ±205%     -8e+04        510 ± 11%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
  17301268 ±125%     -2e+07        656        latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
  44248611 ±140%     -4e+07      43457 ±141%  latency_stats.max.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
  46380610 ±130%     -5e+07      59318 ± 86%  latency_stats.max.max
         0            1e+04      11441        latency_stats.sum.msleep.cpuinfo_open.proc_reg_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11180 ±168%     -1e+04        657 ±  7%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     19239 ±223%     -2e+04          0        latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
     74047 ±148%     -5e+04      24418 ± 44%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
     77617 ±205%     -8e+04        510 ± 11%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
  26043088 ±130%     -3e+07       4768 ± 10%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
  82480038 ±152%     -8e+07      43614 ±141%  latency_stats.sum.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
 1.771e+09           -2e+09   51929782        latency_stats.sum.max
 1.771e+09           -2e+09          0        latency_stats.sum.call_rwsem_down_write_failed_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
    420016 ± 12%      -100%          0        perf-stat.total.page-faults
 2.648e+08 ±  3%      -100%          0        perf-stat.total.context-switches
     52212 ± 18%      -100%          0        perf-stat.total.cpu-migrations
    420016 ± 12%      -100%          0        perf-stat.total.minor-faults

Best Regards,
Rong Chen
