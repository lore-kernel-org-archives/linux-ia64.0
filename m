From: nomura@hpc.bs1.fc.nec.co.jp
Date: Tue, 31 Jul 2001 10:06:28 +0000
Subject: Re: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005966@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This isn't right.  There is no way a VA->PA translation can set bit 63
> so address 0x80000ffffc000000 could only be generated in physical
> mode, which Linux (almost) never uses.  The address 0xffffc000000 is
> correct since Linux will access the memory range only through uncached
> space (region 6).

I didn't talk about VA-PA translation nor I/O memory range access by linux.
'mapping' was the wrong word, I'm afraid.

I mean ar.k0 seems to be used by SAL in physical mode and setting ar.k0 to
cached attribute is problematic.
I think setting bit63 to 1 (i.e. physical mode uncached) is better and safer
solution than just putting cached attribute physical address in ar.k0, unless
anyone or any part of code suffers from the bit.

Here is the updated patch which does not remove ia64_set_kr but set
uncached attribute bit on ia64_iobase in efi_get_iobase().
How about it?

--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.


Index: arch/ia64/kernel/efi.c
=================================RCS file: /home/cvsadm/cvsroot/linux/arch/ia64/kernel/efi.c,v
retrieving revision 1.1.1.7.6.1
diff -u -r1.1.1.7.6.1 efi.c
--- arch/ia64/kernel/efi.c	2001/07/27 06:54:28	1.1.1.7.6.1
+++ arch/ia64/kernel/efi.c	2001/07/31 07:37:49
@@ -473,7 +473,7 @@
 		if (md->type = EFI_MEMORY_MAPPED_IO_PORT_SPACE) {
 			/* paranoia attribute checking */
 			if (md->attribute = (EFI_MEMORY_UC | EFI_MEMORY_RUNTIME))
-				return md->phys_addr;
+				return (1UL<<63) | md->phys_addr; /* Bit63=1: Uncached */
 		}
 	}
 	return 0;

