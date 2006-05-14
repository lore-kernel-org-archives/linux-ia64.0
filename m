From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 14 May 2006 22:41:45 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <1147646506.2729.19.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2006-05-14 at 15:34 -0700, H. Peter Anvin wrote:
> 
> I could, but that would defeat the purpose somewhat.
> 
> I believe "make headers_install" isn't "this is what userspace *has* to 
> get from the kernel" (which is, after all, the null set -- people wrote 
> C libraries for DOS for example), but "this is what the kernel provides 
> to userspace."  It's up to userspace to use it or not, depending on the 
> suitability for any one particular userspace.

Yes, but we have to draw the line somewhere. Otherwise we just continue
exporting crap like stomic.h and letting people shoot themselves in the
foot. I'm inclined to agree with hch that elf.h and page.h fall on the
same side of that line as atomic.h -- but since I know that merits some
discussion, it's something I've deferred for now. Let's get the basic
and obvious stuff done first and then we can argue about the remaining
details.

-- 
dwmw2

