From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 15 Feb 2006 19:16:02 +0000
Subject: RE: missing entries in fsys.S
Message-Id: <200602151916.k1FJG2g09449@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060215143359.GB14787@frankl.hpl.hp.com>
In-Reply-To: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Wednesday, February 15, 2006 8:28 AM
> I would certainly renamed
> the syscall_last to NR_fsyscalls_lat or something like this.

How does the following patch look?  Is it better?


[patch] beautify coding style for zeroing end of fsyscall_table entries.
        Remove misleading __NR_syscall_last and add more comments.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.16-rc3/arch/ia64/kernel/fsys.S.orig	2006-02-15 11:39:52.221926956 -0800
+++ linux-2.6.16-rc3/arch/ia64/kernel/fsys.S	2006-02-15 12:05:28.789290945 -0800
@@ -878,8 +878,10 @@ fsyscall_table:
 	data8 0				// timer_delete
 	data8 0				// clock_settime
 	data8 fsys_clock_gettime	// clock_gettime
-	#define __NR_syscall_last	1255
 
-	.space 8*(NR_syscalls + 1024 - __NR_syscall_last), 0
+	// fill in zeros for the remaining entries
+	.zero:
+	.space fsyscall_table + 8*NR_syscalls - .zero, 0
 
-	.org fsyscall_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
+	// guard against failures to increase NR_syscalls
+	.org fsyscall_table + 8*NR_syscalls

