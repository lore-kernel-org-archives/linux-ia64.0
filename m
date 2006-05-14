From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 14 May 2006 21:17:03 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <20060514211703.GB25945@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 14, 2006 at 08:13:05PM +0100, David Woodhouse wrote:
> In the long term I think we want to drop page.h and elf.h from the list
> of files which are exported to userspace altogether.

elf.h shouldn't be exported to userspace at all.  there's a separate incarnation
of elf.h in userland, so anyone importing the kernel one is plain stupid.

similarly no one should be using page.h, there is nothing in there userspace
should ever look at

