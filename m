From: Ray Bryant <raybry@engr.sgi.com>
Date: Fri, 14 Feb 2003 20:05:53 +0000
Subject: Re: [Linux-ia64] Preempt problems
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------368267C4A7B46F3CFB8C9B2E"
Message-Id: <marc-linux-ia64-105590709805856@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------368267C4A7B46F3CFB8C9B2E
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Stephane Eranian wrote:
> 
> Peter,
> 
> On Tue, Feb 04, 2003 at 07:17:01AM +1100, Peter Chubb wrote:
> >
Stephane,

Does the deadlock you describe here look at all like the bug report that
Jack Steiner has submitted for our Altix kernel?
(We're using the O(1) scheduler and pfmon.)  (It certainly sound
similar.) Details attached.

Is anyone working this issue that you know of?

> 
> As for perfmon, there are some known issues with perfmon and the O(1)
> scheduler (deadlocks during ctxsw in SMP). I am not sure it affects your
> particular test case. I had postponed fixing this because I am working on
> a new perfmon code base for 2.5 in which (hopefully) all problems are gone.
> However a somewhat related issue came up last week and I decided to fix
> some of the problems. I will try to give a new patch to David this week.
> 
> As for preemption and perfmon, I haven't had a chance to look at the patch
> yet. There are some assumptions about not being preemptable at several places.
> 
> --
> -Stephane
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Best Regards,
Ray
-----------------------------------------------
                  Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--------------368267C4A7B46F3CFB8C9B2E
Content-Type: text/plain; charset=us-ascii;
 name="perfmon.deadlock"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="perfmon.deadlock"

From: pv@relay.sgi.com (steiner@sgi.com)
Subject: BUG 881594 - Deadlock in perfmon - pfm_fetch_regs()
To: raybry@sgi.com, steiner@sgi.com
Status:   
X-Mozilla-Status: 8001
X-Mozilla-Status2: 00000000
X-UIDL: 3bd895570000681c

View Incident: http://co-op.engr.sgi.com/BugWorks/code/bwxquery.cgi?search=Search&wlong=1&view_type=Bug&wi=881594

Submitter : steiner                   Submitter Domain : sgi.com            
Assigned Engineer : raybry            Assigned Engineer Domain : sgi.com    
Assigned Group : linux-mckinley       Category : software                   
Reported by Customer : F              Priority : 2                          
Project : snlinux                     Status : open                         
Description :
Ferarri hung this morning running a mixture of
        0xe000003068b40000 00024267 00024266  0  006  stop  0xe000003068b407d0 code3
        0xe00000305c608000 00024273 00024250  0  000  stop  0xe00000305c6087d0 pfmon
        0xe00000300c738000 00024275 00010688  0  000  stop  0xe00000300c7387d0 go.bottle
        0xe000003051018000 00024278 00010688  0  000  stop  0xe0000030510187d0 go.bottle
        0xe000003020058000 00024281 00010688  0  000  stop  0xe0000030200587d0 go.bottle
        0xe00000306c6e8000 00024284 00010688  0  006  stop  0xe00000306c6e87d0 go.bottle
        0xe000003049098000 00024287 00010688  0  000  stop  0xe0000030490987d0 go.bottle
        0xe000003021558000 00024274 00024273  0  000  stop  0xe0000030215587d0 code3
        0xe00001b030900000 00024295 00024284  0  006  stop  0xe00001b0309007d0 pfmon
        0xe00001b03ad30000 00024296 00024295  0  005  stop  0xe00001b03ad307d0 code3
        0xe00000302a240000 00024297 00024278  0  000  stop  0xe00000302a2407d0 pfmon
        0xe000003028980000 00024298 00024275  0  000  stop  0xe0000030289807d0 pfmon

From the leds, it appeared that cpu 2 & 3 were hard hung & not processing interrupts.
I nmi'ed the system.  Cpu 2 was hung here (I think this is right - 90% confidence. Someone
reset the system before I finished digging out the info I needed):


     1  99  1  smp_call_function_single
     7  ??  2      pfm_fetch_regs
     8  ??  3          pfm_load_regs
     9  ??  4              ia64_load_extra
    10  ??  5                  __switch_to
    11  ??  6                      switch_to
    12  ??  7                          context_switch
    13  ??  8                              schedule


cpu 2 was in the function smp_call_function_single spinnning with interrupts disabled trying to
lock call_lock. Cpu 3 was hung the same way that cpu was hung.

Another cpu was holding the call_lock & was waiting for cpu 2 to respond to an IPI. Since
cpu 2 was spinning with interrupts disabled, it was not responding.
The cpu holding the lock was here:
        0xe002000000045af0 smp_call_function+0x470
        0xe002000000045350 smp_flush_tlb_all+0x30
        0xe002000000051550 flush_tlb_range+0x50
        0xe002000000125090 swap_out+0x9f0
        0xe002000000126350 shrink_cache+0xb70
        0xe0020000001269e0 shrink_caches+0x100
        0xe002000000126ad0 try_to_free_pages+0x70
        0xe002000000128b40 balance_classzone+0xe0
        0xe0020000001295c0 __alloc_pages+0x420
        0xe0020000001297c0 __get_free_pages+0xc0
        0xe002000000120260 kmem_cache_grow+0x280
        0xe002000000121580 kmem_cache_alloc+0x460
        0xe00200000033fc60 kmem_zone_zalloc+0xa0
        0xe0020000002d5980 xfs_efd_init+0x80
        0xe00200000030e030 xfs_trans_get_efd+0x30
        0xe00200000029cf40 xfs_bmap_finish+0x1a0
        0xe0020000002e5cb0 xfs_itruncate_finish+0x2d0
        0xe002000000318640 xfs_inactive+0x5e0
        0xe00200000033ea20 vn_rele+0x140
        0xe00200000033c9f0 linvfs_clear_inode+0x30
        0xe0020000001741d0 clear_inode+0x370
        0xe002000000175d70 iput+0x4b0
        0xe002000000170160 d_delete+0x180
        0xe00200000015c690 vfs_unlink+0x650
        0xe00200000015c930 sys_unlink+0x210
        0xe00200000000ea00 ia64_ret_from_syscall

I dont believe that pfm_fetch_regs should be calling smp_call_function_single unless
interrupts are enabled.

--------------368267C4A7B46F3CFB8C9B2E--


