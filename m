From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 06 Jun 2002 02:01:06 +0000
Subject: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905645@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> The latest ia64 kernel patch is at
David> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

David>         linux-2.5.18-ia64-020530.diff.gz

Thanks David, but it doesn't compile for me.  I'm seeing these
problems
	-- perfmon_itanium.h is missing.  I used the one from the 2.4
	   tree.
	   
	-- With CONFIG_GENERIC, sba_iommu.c still doesn't compile
	because of the removal of the address field from the scatterlist.
	-- Again with CONFIG_GENERIC, there are problems:

include/asm/machvec.h:83:12: warning: pasting "machvec_hpsim" and "."
does not give a valid preprocessing token 
include/asm/machvec_init.h:26: initializer element is not constant
include/asm/machvec_init.h:26: (near initialization for `machvec_hpsim.dma_supported')
include/asm/machvec_init.h:26: `__ia64_mmiob' undeclared here (not in a function)
include/asm/machvec_init.h:26: initializer element is not constant

etc.

	-- I think you need this little patch in ia64/kernel/signal.c
	otherwise the usual case will fall off the bottom of the
	function without a return value.

--- /tmp/geta23662	Wed Jun  5 15:31:23 2002
+++ linux-2.5.18-patched/arch/ia64/kernel/signal.c	Wed Jun  5 15:31:22 2002
@@ -146,6 +146,7 @@
 	if (from->si_code < 0) {
 		if (__copy_to_user(to, from, sizeof(siginfo_t)))
 			return -EFAULT;
+		return 0;
 	} else {
 		int err;
 

	 -- asm/suspend.h doesn't exist, so do_mounts.c won't
	 compile.  I just created an empty file.

	 -- With CONFIG_DIG  I managed to get a compile, but haven;t
	 yet had a chance to try it.

--
Peter C					    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.



