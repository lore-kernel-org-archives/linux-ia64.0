From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 27 Jun 2004 17:42:14 +0000
Subject: Why large stack frame for PAL call
Message-Id: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anyone know why we need such large stack frame for PAL static
call?  PAL isn't even suppose to touch any stack register for static
calling convention.  Is it for legacy reason or something?

GLOBAL_ENTRY(ia64_pal_call_static)
        .prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
        alloc loc1 = ar.pfs,6,90,0,0

GLOBAL_ENTRY(ia64_pal_call_phys_static)
        .prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
        alloc loc1 = ar.pfs,6,90,0,0

96 local registers?

Also caller is support to setup callee's stack frame for PAL stacked
convention?  Wasn't clear from the PAL spec.  Though I couldn't make
up any story why it needs to.


