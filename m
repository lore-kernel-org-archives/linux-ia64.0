From: "Niels Christiansen" <nchr@us.ibm.com>
Date: Wed, 30 Jan 2002 06:58:26 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the output I got on a different IA64 system (with gcc 3.0.3),
where the program compiled.  You definitely have an alignment problem.

edges           poptime         walktime                edges found
a.out(14573): unaligned access to 0x600000000000ba4c, ip=0x40000000000074a1
a.out(14573): unaligned access to 0x600000000000ba3c, ip=0x40000000000074c0
a.out(14573): unaligned access to 0x600000000000ba4c, ip=0x4000000000006df1
a.out(14573): unaligned access to 0x600000000000ba4c, ip=0x4000000000006f01
a.out(14573): unaligned access to 0x600000000091c15c, ip=0x4000000000006fc0
a.out(14573): unaligned access to 0x600000000091c15c, ip=0x4000000000007020
a.out(14573): unaligned access to 0x60000000011528ac, ip=0x4000000000007301
a.out(14573): unaligned access to 0x600000000054dbfc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x600000000054db3c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x600000000054da7c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x600000000054d2fc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x600000000071307c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000712e9c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000001ccdf4c, ip=0x40000000000025d1
a.out(14573): unaligned access to 0x6000000001ccdf5c, ip=0x40000000000026a1
a.out(14573): unaligned access to 0x60000000001ec9cc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000001dd93c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000001dd87c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000001d9bec, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000db02ac, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000d7406c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000d73fac, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000d73eec, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000007915bc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000007914fc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000006a08bc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000006a07fc, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x60000000013b54fc, ip=0x4000000000001d50
a.out(14573): unaligned access to 0x60000000013b550c, ip=0x4000000000001c60
a.out(14573): unaligned access to 0x60000000013b550c, ip=0x4000000000001d50
a.out(14573): unaligned access to 0x600000000065bb9c, ip=0x4000000000000f80
a.out(14573): unaligned access to 0x6000000000ddd24c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000dd5a4c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000dd598c, ip=0x4000000000005dd0
a.out(14573): unaligned access to 0x6000000000dd58cc, ip=0x4000000000005dd0
200000          36000000                12000000                1468642 -
Done!

This is the profile for your process:

LTC Linprof Version 1.0.3 using Symlib/Linux Version 1.0.3 -- Jan 24 2002
15:06:09

Details for Process 14573 Task 14573 /home/nchris/test/why_systime/a.out

                  ---- Listed by function ----
  Ticks %of Tid %of Tot  Mode   Function [Source] {binary}
------- ------- -------  ------ --------------------------------------
  10283   21.72    5.21  user   __do_global_ctors_aux
[/usr/src/build/45425-ia64/BUILD/glibc-2.2.4/build-ia64-linux/csu/crti.S]
/home/nchris/test/why_systime/a.out}
   5908   12.48    3.00  kernel __copy_user []
   4791   10.12    2.43  kernel ia64_handle_unaligned []
   4696    9.92    2.38  kernel __cyg_profile_func_enter []
   4471    9.44    2.27  kernel dispatch_unaligned_handler [ivt.S]
   4416    9.33    2.24  kernel __cyg_profile_func_exit []
   3065    6.47    1.55  kernel save_switch_stack []
   1576    3.33    0.80  kernel emulate_load_int [unaligned.c]
   1238    2.62    0.63  kernel setreg [unaligned.c]
   1123    2.37    0.57  kernel load_switch_stack [entry.S]
    925    1.95    0.47  kernel within_logging_rate_limit [unaligned.c]
    640    1.35    0.32  kernel ia64_prepare_handle_unaligned []
    546    1.15    0.28  user   _ZN14VertexIterator7GetNextEv []
{/home/nchris/test/why_systime/a.out}
    468    0.99    0.24  user   _ZN4Edge16AddVertexMappingEP6VertexP5Graphb
[] {/home/nchris/test/why_systime/a.out}
    460    0.97    0.23  user   _ZN6Vertex14AddEdgeMappingEP4EdgeP5Graphb
[] {/home/nchris/test/why_systime/a.out}
    458    0.97    0.23  user   ibase []
{/home/nchris/test/why_systime/a.out}
    456    0.96    0.23  user   _ZNK14VertexIterator5GetAtEv []
{/home/nchris/test/why_systime/a.out}
    364    0.77    0.18  kernel ia64_leave_kernel []
    224    0.47    0.11  user   _ZNK4Edge17GetVertexIteratorEv []
{/home/nchris/test/why_systime/a.out}
    196    0.41    0.10  user   _Z21PrintRelatedVertexIDsP5GraphP6Vertex []
{/home/nchris/test/why_systime/a.out}
    148    0.31    0.08  user   _Z8PopulateP5Graph []
{/home/nchris/test/why_systime/a.out}
    126    0.27    0.06  user   _ZNK12EdgeIterator5GetAtEv []
{/home/nchris/test/why_systime/a.out}
    113    0.24    0.06  kernel emulate_store_int [unaligned.c]
    110    0.23    0.06  user   _ZN12EdgeIterator7GetNextEv []
{/home/nchris/test/why_systime/a.out}
     76    0.16    0.04  user   __umoddi3 [] {/usr/lib/libgcc_s.so.1}
     74    0.16    0.04  user   _ZN4EdgeC1Ev []
{/home/nchris/test/why_systime/a.out}
     71    0.15    0.04  kernel getreg [unaligned.c]
     46    0.10    0.02  kernel clear_page []
     46    0.10    0.02  user   _ZN5Graph16AddVertexMappingEP4EdgeP6Vertexb
[] {/home/nchris/test/why_systime/a.out}
     27    0.06    0.01  user   main []
{/home/nchris/test/why_systime/a.out}
     21    0.04    0.01  user   _ZN5Graph7AddEdgeEjj []
{/home/nchris/test/why_systime/a.out}
     21    0.04    0.01  kernel _ltr_64 []
     20    0.04    0.01  user   __divdi3 [] {/usr/lib/libgcc_s.so.1}
     20    0.04    0.01  user   _ZN5Graph9GetVertexEj []
{/home/nchris/test/why_systime/a.out}
     17    0.04    0.01  user   _ZN5Graph9AddVertexEj []
{/home/nchris/test/why_systime/a.out}
     13    0.03    0.01  kernel rmqueue [page_alloc.c]
     11    0.02    0.01  user   _ZN14VertexIteratorC1EPK4Edge []
{/home/nchris/test/why_systime/a.out}
     10    0.02    0.01  user   __gmon_start__ []
{/home/nchris/test/why_systime/a.out}
      6    0.01    0.00  kernel __free_pages_ok [page_alloc.c]
      6    0.01    0.00  user   memmove [] {/lib/libc-2.2.4.so}
      4    0.01    0.00  kernel do_wp_page [memory.c]
      4    0.01    0.00  user   _ZN6VertexC1Ev []
{/home/nchris/test/why_systime/a.out}
      3    0.01    0.00  kernel handle_mm_fault []
      3    0.01    0.00  user   _ZN12EdgeIteratorC1EPK6Vertex []
{/home/nchris/test/why_systime/a.out}
      3    0.01    0.00  kernel sys_ioctl []
      3    0.01    0.00  kernel find_vma_prev []
      3    0.01    0.00  user   _dl_lookup_symbol [] {/lib/ld-2.2.4.so}
      3    0.01    0.00  kernel ltr_spin_unlock []
      2    0.00    0.00  user   _ZNK6Vertex15GetEdgeIteratorEv []
{/home/nchris/test/why_systime/a.out}
      2    0.00    0.00  kernel __scsi_end_request [scsi_lib.c]
      2    0.00    0.00  kernel __lru_cache_del []
      1    0.00    0.00  kernel unlock_page []
      1    0.00    0.00  user   chunk_alloc [malloc.c] {/lib/libc-2.2.4.so}
      1    0.00    0.00  kernel ltr_spin_lock_entry []
      1    0.00    0.00  user   _dl_relocate_object [] {/lib/ld-2.2.4.so}
      1    0.00    0.00  kernel scsi_old_done []
      1    0.00    0.00  user   _dl_lookup_versioned_symbol []
{/lib/ld-2.2.4.so}
      1    0.00    0.00  kernel memset []
      1    0.00    0.00  kernel __alloc_pages []
      1    0.00    0.00  kernel batch_entropy_store []
      1    0.00    0.00  kernel ia64_do_page_fault []
      1    0.00    0.00  user   chunk_free [malloc.c] {/lib/libc-2.2.4.so}
      1    0.00    0.00  kernel page_fault [ivt.S]
      1    0.00    0.00  user   _dl_fini [libgcc2.c] {/lib/ld-2.2.4.so}
      1    0.00    0.00  kernel demine_args [ivt.S]
      1    0.00    0.00  user   __malloc [fde-glibc.c] {/lib/libc-2.2.4.so}
      1    0.00    0.00  user   __libc_malloc [] {/lib/libc-2.2.4.so}
      1    0.00    0.00  user   __umoddi3 [libgcc2.c] {/lib/ld-2.2.4.so}
      1    0.00    0.00  user   __sbrk [] {/lib/libc-2.2.4.so}
      1    0.00    0.00  kernel do_anonymous_page [memory.c]
      1    0.00    0.00  kernel __up_write []
      1    0.00    0.00  kernel do_no_page [memory.c]
------- ------- -------
  47339  100.00   24.00

                  ---- Listed by binary ----
  Ticks %of Tid %of Tot  Binary
------- ------- -------  --------------------------------------
  33515   70.80   16.99  Kernel
  13710   28.96    6.95  /home/nchris/test/why_systime/a.out
     96    0.20    0.05  /usr/lib/libgcc_s.so.1
     11    0.02    0.01  /lib/libc-2.2.4.so
      7    0.01    0.00  /lib/ld-2.2.4.so


          --------------------------------------------------------
          LTC Linprof Version 1.0.3 - Totals by Process and TaskID
          --------------------------------------------------------

                ----Kernel----- -----User------ -----Total-----
Process    Task   Ticks %of Tot   Ticks %of Tot   Ticks %of Tot
Executing...
------- ------- ------- ------- ------- ------- ------- -------
-------------------
      0       0   82288   41.72       0    0.00   82288   41.72
      0       9       3    0.00       0    0.00       3    0.00
      1       1       0    0.00       1    0.00       1    0.00
/lib/ld-2.2.4.so
     10      10   49722   25.21       0    0.00   49722   25.21
     12      12      27    0.01       0    0.00      27    0.01
    543     543     163    0.08       3    0.00     166    0.08
/lib/ld-2.2.4.so
    548     548       4    0.00       1    0.00       5    0.00
/lib/ld-2.2.4.so
    814     814       1    0.00       2    0.00       3    0.00
/lib/ld-2.2.4.so
  14452   14452       6    0.00       0    0.00       6    0.00
/lib/ld-2.2.4.so
    138     138    1154    0.59       0    0.00    1154    0.59
    139     139      30    0.02       0    0.00      30    0.02
    140     140      21    0.01       0    0.00      21    0.01
  14515   14515       5    0.00       1    0.00       6    0.00
/lib/ld-2.2.4.so
  14572   14572       9    0.00       0    0.00       9    0.00
/lib/ld-2.2.4.so
  14573   14573   33515   16.99   13824    7.01   47339   24.00
/home/nchris/test/why_systime/a.out
  14574   14574       2    0.00       0    0.00       2    0.00
/lib/ld-2.2.4.so
  14575   14575    4925    2.50       0    0.00    4925    2.50
/lib/ld-2.2.4.so
  14576   14576    3582    1.82       0    0.00    3582    1.82
/lib/ld-2.2.4.so
  14577   14577    3850    1.95       0    0.00    3850    1.95
/lib/ld-2.2.4.so
  14578   14578    3449    1.75       0    0.00    3449    1.75
/lib/ld-2.2.4.so
  14579   14579       1    0.00       0    0.00       1    0.00
/lib/ld-2.2.4.so
  14580   14580      56    0.03     584    0.30     640    0.32
/usr/bin/perl
  14581   14581       8    0.00       2    0.00      10    0.01
/usr/sbin/lintrace


