From: dann frazier <dannf@debian.org>
Date: Mon, 23 Oct 2006 19:10:24 +0000
Subject: Re: ia64 userspace kernel headers
Message-Id: <20061023191024.GD764@colo>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Oct 21, 2006 at 12:34:24AM -0400, Jeff Bailey wrote:
> Heya Dann!  I'm hoping you can help me with this, or punt me to the
> right person.
> 
> The exported userspace headers from 2.6.18 and 2.6.19-rc1 cause the
> klibc build to fail at:
> 
> gcc_intrin.h:register unsigned long ia64_r13 asm ("r13")
> __attribute_used__;
> 
> because __attribute_used__ isn't defined.  linux/compiler-gcc4.h isn't
> part of the exported set (and isn't actually included directly by this
> header, which I suspect it should be).  I'm not clear that
> asm/intrinsics.h is generally expected to be needed, and if so how much.
> I'm hoping you know the headers well enough to know if that define and
> the following section of gcc_intrin.h can be just marked #ifdef
> __KERNEL__ to solve the problem.

hey Jeff,
  I don't have much knowledge in this area, I'll have to defer you to
the linux-ia64 list (cc'd)

-- 
dann frazier

