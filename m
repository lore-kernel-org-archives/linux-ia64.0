From: Ray Bryant <raybry@engr.sgi.com>
Date: Tue, 05 Feb 2002 07:13:47 +0000
Subject: Re: [Linux-ia64] cmpxchg patch
Message-Id: <marc-linux-ia64-105590698805989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805982@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805982@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Of course.  I'll give it a try and see what happens.  I hope that
building for a dig machine with 2.4.17 would be a good enough test.  The
easiest machine for me to boot it on would be a SNIA machine though.

Also, I see that previous versions of the in-line asm spinlock code in
IA64 used a proceudure to handle the complicated cases.  However, that
procedure is not part of the source tree at the present time.  I'm
trying to do something similar to create NUMA aware locks that are as
fast (or very nearly so) as the current spin locks, but have the good
NUMA properties of mcs locks.  Any experience you have with creating
spin lock code that calls out to a C procedure to handle the non-common
cases would be appreciated.

David Mosberger wrote:
> 
> >>>>> On Sat, 02 Feb 2002 10:26:42 -0600, Ray Bryant <raybry@engr.sgi.com> said:
> 
>   Ray> It seems to me that the size of the result of
>   Ray> cmpxchg(ptr,old,new) should depend on the size of *ptr and not
>   Ray> the size of old.
> 
>   Ray> Attached is a patch to fix.
> 
> Have you actually tried building a kernel with the patch applied?  I
> think you'll get errors in atomic.h.  I'm willing to entertain a
> better solution, but it needs to be a complete solution.
> 
> Thanks,
> 
>         --david

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant               SGI
512-453-9679 (work)      512-507-7807 (cell)
raybry@sgi.com           raybry@austin.rr.com
     Computers are like air conditioners.
   They stop working when you open Windows.
-----------------------------------------------

