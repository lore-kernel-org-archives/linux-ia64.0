From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 09 Mar 2004 20:32:24 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <404E29D8.8030303@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

H. J. Lu wrote:
> 
> getpagesize () isn't hardcoded to 4K in glibc. You can change it with
> AT_PAGESZ. The problem is the x86 executable is aligned at 4K page
> size, which is specified by the i386 ABI. The dynamic linker in glibc
> won't load the normal x86 executables with a bigger page size. I have
> a glibc patch which allows >4K page size. It may work for you.

I did some very light testing with HJ's glibc patch with this kernel 
change a few months ago and didn't find any obvious breakages. YMMV.

	-Arun

--- 1.21/fs/binfmt_elf.c        Sat May  4 10:05:24 2002
+++ edited/fs/binfmt_elf.c      Fri Jun 13 12:25:10 2003
@@ -184,7 +184,7 @@
         }
         sp -= DLINFO_ITEMS*2;
         NEW_AUX_ENT( 0, AT_HWCAP, hwcap);
-       NEW_AUX_ENT( 1, AT_PAGESZ, ELF_EXEC_PAGESIZE);
+       NEW_AUX_ENT( 1, AT_PAGESZ, PAGE_SIZE);
         NEW_AUX_ENT( 2, AT_CLKTCK, CLOCKS_PER_SEC);
         NEW_AUX_ENT( 3, AT_PHDR, load_addr + exec->e_phoff);
         NEW_AUX_ENT( 4, AT_PHENT, sizeof (struct elf_phdr));

