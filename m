From: Mark Haverkamp <markh@osdl.org>
Date: Thu, 17 Jun 2004 17:52:27 +0000
Subject: sys_ioctl export
Message-Id: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The ia64 arch doesn't export sys_ioctl like some other 64 bit
architectures like ppc64, sparc64 and x86_64.  Was this intentional?  If
not, where would be a good place to put the export?  The other
architectures put it in their respective ksysm.c file.  The ia64_ksyms.c
file says not to put exports not in an assembler file. Although
max_low_pfn is exported even though it is in linux/bootmem.h.

Thanks,
Mark.

-- 
Mark Haverkamp <markh@osdl.org>

