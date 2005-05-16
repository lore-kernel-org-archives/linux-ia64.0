From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 16 May 2005 04:42:07 +0000
Subject: Re: [Fwd: RE: elf header bits for page migration support......]
Message-Id: <20050516044207.GA26403@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4287A223.6010804@sgi.com>
In-Reply-To: <4287A223.6010804@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 15, 2005 at 11:29:55PM -0500, Ray Bryant wrote:
> H. J. Lu wrote:
> 
> >
> >I didn't follow the whole thread very closely. But I can say
> >
> >1. We should use a dummy segement instead of bits in ELF header.
> >2. ld.so has no problems with more than one PT_LOAD segment. Most
> >of binaries/DSOs have 2: one is readonly and executable, the other
> >is read and write.
> >
> >If you want to modify ld.so to support your scheme, you can mark it
> >any PT_XXX you want. If you don't need/want to modify ld.so, you can
> >use a new PT_XXX and deal it in the user code. Ld.so will ignore the
> >unknow PT_XXX. The static linker can provide _start/_end symbols for
> >the new PT_XXX segment.
> >
> >
> >H.J.
> >
> 
> If we use a new segment at the end of the file (Jack had suggested this),
> then don't we have to scan the entire file before we find out that the 
> executable has this special section?  That makes it hard, because we call
> mmap() in ld.so and execve() [inside the kernel] as each segment is
> encountered.  So we need to know before that mmap() call is made whether
> or not the migration attribute needs to be added to that mmap'd region.

All necessary information of any segment should be in the ELF program
header. Looking it up is very straight forward in kernel and ld.so.


H.J.
