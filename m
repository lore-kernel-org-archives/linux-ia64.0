From: Richard Hirst <rhirst@linuxcare.com>
Date: Sun, 04 Nov 2001 22:06:37 +0000
Subject: Re: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805440@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 24, 2001 at 04:21:08PM -0700, David Mosberger wrote:
> >>>>> On Wed, 24 Oct 2001 12:26:59 +0100, Richard Hirst <rhirst@linuxcare.com> said:
> 
>   Richard> This patch solves the problem.  Still surprised that cached
>   Richard> accesses to the video memory crash the machine though..
> 
> My understanding is that Merced doesn't handle cache line sized
> transactions to the PCI bus.  Instead of going uncached, you might be
> able to use write-combining (for the video framebuffer, not for memory
> mapped control registers).  That can give you noticably better
> performance.

Yes, write combining works.  Could you include this in your tree
please, (patch is from a 2.4.9 tree)

Thanks,
  Richard



--- linux/drivers/video/fbmem.c.ori	Mon Nov  5 01:53:01 2001
+++ linux/drivers/video/fbmem.c	Mon Nov  5 01:53:05 2001
@@ -605,6 +605,8 @@
 	vma->vm_flags |= VM_IO;
 #elif defined(__sh__)
 	pgprot_val(vma->vm_page_prot) &= ~_PAGE_CACHABLE;
+#elif defined(__ia64__)
+	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 #else
 #warning What do we have to do here??
 #endif

