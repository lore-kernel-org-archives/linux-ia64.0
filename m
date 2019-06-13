From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Thu, 13 Jun 2019 17:57:45 +0000
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <e5f45089-c3aa-4d78-2c8d-ed22f863d9ee@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>, linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@synopsys.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>

+CC Masami San

On 6/13/19 3:07 AM, Anshuman Khandual wrote:
> Questions:
> 
> AFAICT there is no equivalent of erstwhile notify_page_fault() during page
> fault handling in arc and mips archs which can call this generic function.
> Please let me know if that is not the case.

For ARC do_page_fault() is entered for MMU exceptions (TLB Miss, access violations
r/w/x etc). kprobes uses a combination of UNIMP_S and TRAP_S instructions which
don't funnel into do_page_fault().

UINMP_S leads to

instr_service
   do_insterror_or_kprobe
      notify_die(DIE_IERR)
         kprobe_exceptions_notify
            arc_kprobe_handler


TRAP_S 2 leads to

EV_Trap
   do_non_swi_trap
      trap_is_kprobe
         notify_die(DIE_TRAP)
            kprobe_exceptions_notify
               arc_post_kprobe_handler

But indeed we are *not* calling into kprobe_fault_handler() - from eithet of those
paths and not sure if the existing arc*_kprobe_handler() combination does the
equivalent in tandem.

-Vineet
