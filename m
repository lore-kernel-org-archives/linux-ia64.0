From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 24 May 2003 07:38:07 +0000
Subject: [Linux-ia64] Re: /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723706028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705961@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705961@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 23, 2003 at 04:51:43PM -0700, Luck, Tony wrote:
> > One alternative I considered was to use just do a page table lookup.
> > But I fear that some architectures use direct mapping registers etc.
> > with mappings not in the page tables for the direct mapping, so it 
> > probably won't work for everybody.
> 
> You are right.  IA64 maps the kernel with some locked registers, so
> there are no pagetables to show that the mapping exists.

ARM maps the kernel direct-mapped RAM using 1MB section mappings, which
the normal pgd/pmd/pte macros don't recognise as being valid.

> I don't know ... you'll have to dust off those fixes for /proc to let
> the negative file offsets get as far as the kcore.c code so we can
> see what utilities work.  In practice we probably don't care about
> anything other than gdb.

gdb definitely breaks - that's why I had to do the changes in the first
place.  gdb tries to lseek to negative 64-bit file offsets, which the
kernel rejects with EINVAL iirc.  (Tried it earlier this week.)

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html


