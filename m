From: Matthew Wilcox <willy@debian.org>
Date: Wed, 10 Dec 2003 20:50:30 +0000
Subject: hardware random number generator?
Message-Id: <marc-linux-ia64-107108953504700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


config HW_RANDOM
        tristate "Intel/AMD/VIA HW Random Number Generator support"
        depends on (X86 || IA64) && PCI
        ---help---
          This driver provides kernel-side support for the Random Number
          Generator hardware found on Intel i8xx-based motherboards,
          AMD 76x-based motherboards, and Via Nehemiah CPUs.

Why IA64 too?  This file contains the code:

static inline u32 xstore(u32 *addr, u32 edx_in)
{
        u32 eax_out;

        asm(".byte 0x0F,0xA7,0xC0 /* xstore %%edi (addr=%0) */"
                :"=m"(*addr), "=a"(eax_out)
                :"D"(addr), "d"(edx_in));

        return eax_out;
}

which doesn't compile on ia64.  I think it should be unselectable.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
