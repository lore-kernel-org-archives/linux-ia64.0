From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 14 May 2006 22:11:28 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <1147644688.2729.13.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2006-05-14 at 15:03 -0700, H. Peter Anvin wrote:
> Keep in mind that userland isn't necessarily glibc.  In particular,
> for klibc it would be a pain in the arse to have two largely identical
> copies of the same header file in the kernel tree.

You can still use the copy from the kernel tree even if we don't
actually copy it out in 'make headers_install'.

But yes, this is one of the reasons I haven't touched elf.h (yet).

-- 
dwmw2

