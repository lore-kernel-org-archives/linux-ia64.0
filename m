From: Russell King <rmk@arm.linux.org.uk>
Date: Fri, 23 May 2003 21:11:13 +0000
Subject: [Linux-ia64] Re: /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723706019@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705961@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705961@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 23, 2003 at 12:13:04PM -0700, Luck, Tony wrote:
> Not a lot of replies to this on the list, but I did notice
> that the lse-tech IRC discussion mentioned me by name, saying
> that I had a proposal for a fix ... and Andrew has stuck my
> name against this in the must-fix list for 2.6.  So, not wanting
> to be the person who is holding up 2.6 ... here's what I am
> proposing.

This is what I currently have hacked into kcore.c which works (but
*will* break for non-ARM stuff.)

I suspect the easiest thing may be to arrange for the discontig direct
mapped memory blocks to appear on the vmlist and then remove the special
case for the direct mapped RAM.  I don't see why architecture support
needs to come into the picture really.

I don't believe any races here are that important (except of course
ensuring that we produce consistent data for a particular read() and
not oopsing the kernel) - take a moment to think where the information
/proc/kcore provides ends up and realise that as soon as it hits
userspace, you can't rely on it.  eg, Today, if you're using it and
you insert a module, the structure of the file changes, and gdb's
idea of offsets of data into the "core" becomes invalid.

--- orig/fs/proc/kcore.c	Sat Nov  2 18:58:18 2002
+++ linux/fs/proc/kcore.c	Mon May 19 23:30:41 2003
@@ -99,7 +99,13 @@
 }
 #else /* CONFIG_KCORE_AOUT */
 
+#define KCORE_BASE	(PAGE_OFFSET - 0x01000000)
+#define in_vmlist_region(x) (((x) >= KCORE_BASE && (x) < PAGE_OFFSET) || ((x) >= VMALLOC_START && (x) < VMALLOC_END))
+
+#ifndef KCORE_BASE
 #define	KCORE_BASE	PAGE_OFFSET
+#define in_vmlist_region(x) ((x) >= VMALLOC_START && (x) < VMALLOC_END)
+#endif
 
 #define roundup(x, y)  ((((x)+((y)-1))/(y))*(y))
 
@@ -394,7 +400,7 @@
 		tsz = buflen;
 		
 	while (buflen) {
-		if ((start >= VMALLOC_START) && (start < VMALLOC_END)) {
+		if (in_vmlist_region(start)) {
 			char * elf_buf;
 			struct vm_struct *m;
 			unsigned long curstart = start;


-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html


