From: Ray Bryant <raybry@engr.sgi.com>
Date: Mon, 16 May 2005 04:29:55 +0000
Subject: Re: [Fwd: RE: elf header bits for page migration support......]
Message-Id: <428821C3.60804@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4287A223.6010804@sgi.com>
In-Reply-To: <4287A223.6010804@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

H. J. Lu wrote:

> 
> I didn't follow the whole thread very closely. But I can say
> 
> 1. We should use a dummy segement instead of bits in ELF header.
> 2. ld.so has no problems with more than one PT_LOAD segment. Most
> of binaries/DSOs have 2: one is readonly and executable, the other
> is read and write.
> 
> If you want to modify ld.so to support your scheme, you can mark it
> any PT_XXX you want. If you don't need/want to modify ld.so, you can
> use a new PT_XXX and deal it in the user code. Ld.so will ignore the
> unknow PT_XXX. The static linker can provide _start/_end symbols for
> the new PT_XXX segment.
> 
> 
> H.J.
> 

If we use a new segment at the end of the file (Jack had suggested this),
then don't we have to scan the entire file before we find out that the 
executable has this special section?  That makes it hard, because we call
mmap() in ld.so and execve() [inside the kernel] as each segment is
encountered.  So we need to know before that mmap() call is made whether
or not the migration attribute needs to be added to that mmap'd region.

Also, I suppose it possible to use the linker to add the special
section some other place in the file (?).  We would have to then relink
every application in the system that could be part of a migratable
program.  I'm not sure how feasble that might be, but I can
investigate if our customer can deal with this.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
