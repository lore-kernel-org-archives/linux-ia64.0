From: Jan Schreckenbach <linux@sap.com>
Date: Fri, 14 Mar 2003 12:33:12 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yep, I'm doing some benchmark stuff with SAP/SAPDB and the performance
is not as good as I expected. CONFIG_HUGETLB_PAGE=y is standard on a
SLES8 kernel (2.4.19-SMP). I changed the page size from 16K to 64K
and the performance increase was 2-3 percent. Changing  Huge TLB Page 
Size" seems not to have any effect.

I think I looked at almost all possible bottlenecks (database, SAP
internal buffer, parameter of SAP's own memory layer etc.). Everything
here seems to be OK, so the bottleneck must be the code produced by
the gcc or the OS itselves. I'm calling readprofile -r before the run
end readprofile after the run. These are the first lines of the output
with a standard kernel:

2110715 cpu_idle                                 5996.3494
  12975 sock_poll                                 81.0938
   9523 fget                                      42.5134
  36903 tcp_poll                                  33.9182
    532 ia64_ret_from_syscall                     16.6250
   2477 remove_wait_queue                         11.0580
   2518 add_wait_queue                             9.8359
   7177 break_fault                                8.3067
   3210 find_vma_prev                              6.2695
   2143 unlock_page                                5.5807
   3051 __find_lock_page_helper                    5.2969
   3350 do_gettimeofday                            4.7585
  11122 sys_semop                                  4.4559
    937 page_waitqueue                             4.1830
    741 __find_lock_page                           3.8594
    616 demine_args                                3.8500
   3322 try_atomic_semop                           3.8449
    673 shmem_nopage                               3.5052
   1489 update_queue                               3.3237
  13440 schedule                                   3.2558
   2630 fput                                       3.1611
   3914 do_select                                  3.0578
    459 clear_page                                 2.8687
    175 ia64_page_valid                            2.7344
   5166 try_to_wake_up                             2.6038
    310 __free_pages                               2.4219
   1053 __pollwait                                 2.3504
    940 ipcperms                                   2.0982
   1187 __wake_up                                  2.0608

with a kernel with 64K pagesize the output is:

2102011 cpu_idle                                 5971.6222
  12492 sock_poll                                 78.0750
  10001 fget                                      44.6473
  27396 tcp_poll                                  25.1801
    577 ia64_ret_from_syscall                     18.0312
   2468 remove_wait_queue                         11.0179
   9641 smp_call_function                         10.3890
   2455 add_wait_queue                             9.5898
   7334 break_fault                                8.4884
  10955 sys_semop                                  4.3890
   2891 do_gettimeofday                            4.1065
   3358 try_atomic_semop                           3.8866
    548 demine_args                                3.4250
  13989 schedule                                   3.3888
   1613 find_vma_prev                              3.1504
   3991 do_select                                  3.1180
   2525 fput                                       3.0349
   1299 update_queue                               2.8996
    636 page_waitqueue                             2.8393
   1492 __find_lock_page_helper                    2.5903
    247 flush_icache_range                         2.5729
   4868 try_to_wake_up                             2.4536
    146 wake_up_process                            2.2812
   1021 ipcperms                                   2.2790
    429 shmem_nopage                               2.2344
    968 __pollwait                                 2.1607
    137 ia64_page_valid                            2.1406
    819 unlock_page                                2.1328
    402 __find_lock_page                           2.0938

I'm far from being an expert in kernel stuff, but I don't see a
big difference.

Jan


Grant Grundler wrote:
> On Wed, Mar 12, 2003 at 09:40:55AM -0800, David Mosberger wrote:
> 
>>On the other hand, the performance measurements I have done with 64KB
>>page size suggested that the page size could become the sweet-spot
>>much sooner than I had expected.
> 
> 
> 
> For Oracle/SAP, wouldn't "HUGETLB_PAGE" cover most of the same problems?
> I suspect that's all Jan (SAP) might need but don't know exactly what
> problem Jan is trying to address. Jan?
> 
> grant
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

-- 
_______________________________________________________________________

THE BEST RUN E-BUSINESSES RUN SAP
_______________________________________________________________________

Jan Schreckenbach                      email: Jan.Schreckenbach@sap.com
SAP AG Walldorf/Baden, Germany         Phone: +49 6227  7-47474
LinuxLab                               Fax  : +49 6227 78-31414

SAP LinuxLab support address: linux@sap.com


