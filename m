From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 24 Oct 2001 11:26:59 +0000
Subject: Re: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805379@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 24, 2001 at 11:30:33AM +0100, Richard Hirst wrote:
> When using mmap() I sometimes see parts of my image on the screen before
> it crashes, and the pattern of bits that are drawn (or not) indicate
> that some small blocks of data (cachelines?) are not written to the
> video memory while other similar sized blocks are written.  As the system
> crashes so badly, I guess the missing blocks are written elsewhere.

This patch solves the problem.  Still surprised that cached accesses to
the video memory crash the machine though..

Richard


--- drivers/video/fbmem.c-	Wed Oct 24 15:17:36 2001
+++ drivers/video/fbmem.c	Wed Oct 24 14:50:50 2001
@@ -605,6 +605,8 @@
 	vma->vm_flags |= VM_IO;
 #elif defined(__sh__)
 	pgprot_val(vma->vm_page_prot) &= ~_PAGE_CACHABLE;
+#elif defined(__ia64__)
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 #else
 #warning What do we have to do here??
 #endif

