From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 16 Apr 2003 21:09:38 +0000
Subject: Re: [Linux-ia64] ia32 subsystem in 2.5.67
Message-Id: <marc-linux-ia64-105590723705515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705513@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

Hi David,

> It looks like dynamic x86 binaries have a problem once again (or
> still).  If I try to run any shared x86 binaries, I get:
> 
> 	$ ls.x86
> 	ls.x86: error while loading shared libraries: librt.so.1: cannot map zero-fill pages: Error 14
> 
> Would someone take a look?

We saw this behavior with 2.5.59 also. The attached work around should
take care of the problem temporarily. Last time this happened, IA-32
programs were doing mmaps, whose size was one page bigger than the
size of the underlying file (even after rounding up the file size).

I never got a chance to figure out why glibc was doing mmaps with the
"wrong" size. Also, I failed to reproduce the problem with a more
recent (RH 8.0) glibc.

Which version of IA-32 glibc were you using ?

        -Arun

--- linux-2.5.59/arch/ia64/ia32/sys_ia32.c-	Wed Apr 16 13:39:59 2003
+++ linux-2.5.59/arch/ia64/ia32/sys_ia32.c	Wed Apr 16 13:40:15 2003
@@ -245,8 +245,7 @@
 		return -ENOMEM;
 
 	if (old_prot)
-		if (copy_from_user(page, (void *) PAGE_START(start), PAGE_SIZE))
-			return -EFAULT;
+		copy_from_user(page, (void *) PAGE_START(start), PAGE_SIZE);
 
 	down_write(&current->mm->mmap_sem);
 	{


