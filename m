From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 16 Jun 2006 00:48:38 +0000
Subject: RE: [RFC][PATCH]fix search_extable() to find correct entry
Message-Id: <001101c690de$9ba88590$e434030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44916017.5050006@sdl.hitachi.co.jp>
In-Reply-To: <44916017.5050006@sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Masami Hiramatsu wrote on Thursday, June 15, 2006 6:27 AM
> I found a suspicious buggy code in the linux kernel on IA64 arch.
> As far as I can see, search_extable() doesn't work correctly, because
> the lookup routine expects that the address format of the
> exception_table_entry is "IP + slot", but the compiler (gcc-3.4.5)
> generates it as "IP + (slot << 2)". Thus the lookup routine always
> fails to find the corresponding entry.
> You can check it by dumping __ex_table section of vmlinux.

Chen, Kenneth W wrote on Thursday, June 15, 2006 2:22 PM
> But the tag address in the table is also bundle aligned, which I will
> look a bit more.


I've double checked (triple checked with sample test code below).  It's a
false alarm. Everyone should rest assure that exception table and compiler
do match and generates correct code.  There is no bug AFAICT.


Test code:

#include <linux/config.h>
#include <asm/asmmacro.h>

GLOBAL_ENTRY(ken)
        EX(eh0, ld1 r32 = [r0])
        EX(eh1, ld1 r33 = [r0])
        nop 0
        ;;
[eh0:] br.ret.sptk b0
[eh1:] br.ret.sptk b0

END(ken)


Exception table entry for eh0 and eh1:

0xa0000001004bc828   ffff7518 ffff7524 ffff7511 ffff751d


objdump of test code:

a0000001004b3d40:    ld1 r32=[r0]
a0000001004b3d46:    ld1 r33=[r0]
a0000001004b3d4c:    nop.i 0x0;;
a0000001004b3d50:    br.ret.sptk.few b0
a0000001004b3d56:    br.ret.sptk.few b0
a0000001004b3d5c:    nop.b 0x0;;

