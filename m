From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 20 May 2004 04:55:06 +0000
Subject: Re: Kill warnings in 2.6.6
Message-Id: <16556.14890.981448.853905@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

Peter> === arch/ia64/kernel/machvec.c 1.7 vs edited === ---
Peter> 1.7/arch/ia64/kernel/machvec.c Thu Mar 18 16:57:15 2004 +++
Peter> edited/arch/ia64/kernel/machvec.c Tue May 18 13:00:35 2004 @@
Peter> -61,6 +61,9 @@ } EXPORT_SYMBOL(machvec_timer_interrupt);
Peter> 
Peter> +struct device; +struct scatterlist; + void
Peter> machvec_dma_sync_single (struct device *hwdev, dma_addr_t
Peter> dma_handle, size_t size, int dir)

David> Where does this get rid of a warning?  A driver or something
David> else?

Building in ../build/ia64/linux-2.6-quickfix
  Using /home/peterc/kernels/linux-2.6-quickfix as source for kernel
make[2]: `arch/ia64/kernel/asm-offsets.s' is up to date.
  CHK     include/asm-ia64/offsets.h
  CHK     include/linux/compile.h
  CC      arch/ia64/kernel/machvec.o
/home/peterc/kernels/linux-2.6-quickfix/arch/ia64/kernel/machvec.c:65:
warning: `struct device' declared inside parameter list
/home/peterc/kernels/linux-2.6-quickfix/arch/ia64/kernel/machvec.c:65:
warning: its scope is only this definition or declaration, which is
probably not what you want
/home/peterc/kernels/linux-2.6-quickfix/arch/ia64/kernel/machvec.c:72:
warning: `struct scatterlist' declared inside parameter list
/home/peterc/kernels/linux-2.6-quickfix/arch/ia64/kernel/machvec.c:72:
warning: `struct device' declared inside parameter list

Using gcc 3.3.3, configured as ZX1, McKinley.

If you configure with GENERIC, then asm/machvec.h is included which
has declarations for struct device, etc, but without GENERIC the
definitions are missing.
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
