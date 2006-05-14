From: "H. Peter Anvin" <hpa@zytor.com>
Date: Sun, 14 May 2006 23:22:41 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <4467BBC1.70802@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Woodhouse wrote:
> 
> Yes, but we have to draw the line somewhere. Otherwise we just continue
> exporting crap like stomic.h and letting people shoot themselves in the
> foot. I'm inclined to agree with hch that elf.h and page.h fall on the
> same side of that line as atomic.h -- but since I know that merits some
> discussion, it's something I've deferred for now. Let's get the basic
> and obvious stuff done first and then we can argue about the remaining
> details.
> 

page.h I agree with.

elf.h I don't.

page.h and atomic.h both have in common that on some architectures, the 
needs of userspace and the needs of the kernel are very different 
(what's atomic in kernel space isn't necessarily atomic in userspace.) 
Similar, PAGE_SIZE makes sense for the kernel, but not for userspace (it 
could vary.)

elf.h is different -- it describes an interface.  As such, it *should* 
be the same on both sides of the universe.

	-hpa

