From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Tue, 09 Mar 2004 22:49:26 +0000
Subject: RE: crash on SysRq : Show Memory
Message-Id: <200403092249.i29MnQm30840@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
In-Reply-To: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Aron Griffis wrote on Tue, March 09, 2004 1:36 PM
> > Looks like it passed beyond show_free_areas(), faulting IP was
> > in the while loop accessing mem_map variable.

> How did you determine that?

Do objdump on vmlinux, then look at the disassembled code at
faulting IP:

Show_mem+0x100
a00000010003cd00:    [MMI]       ld4.acq r21=[r16];;

It is page faulting on r16, lookup r16 in the panic dump, it shows:
r16 : a0007fffff0fffb0, which basically points to a page struct in
the mem_map array, you might want to verify whether that address is
valid or not.

Exam the code up/down a little bit, you would realize the while loop
is in between show_mem+0xe0 and show_mem+0x1dc, variable i is stored
in r17/r3, lookup up these instructions to see how the pointer is
calculated with index i:
(i*5*16 + base mem_map, sizeof(struct page) = 80).

a00000010003cce6:                  sxt4 r23=r17;;
a00000010003ccec:                  shladd r22=r23,2,r23;;
a00000010003ccf0:      [MMI]       shladd r16=r22,4,r19;;

Anyway, hope you get the idea ....

- Ken


