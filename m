From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 12 Feb 2002 18:17:42 +0000
Subject: RE: [Linux-ia64] __clone not defined??
Message-Id: <marc-linux-ia64-105590698806039@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806038@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806038@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The problem is that the __clone interface assumed that the location of the
stack for a new thread could be specified with a single stack pointer.  On
Itanium, this is not true, since the register stack engine needs its own
stack and stack pointer.

The corresponding call is __clone2().

The interface is 

/* int  __clone2(int (*fn) (void *arg), void *child_stack_base,         */
/*               size_t child_stack_size, int flags, void *arg) */

Note the extra child_stack_size argument, which allows the implementation to
divide the region into the two needed stacks.  Otherwise it's identical to
__clone().  The source is at

http://sources.redhat.com/cgi-bin/cvsweb.cgi/libc/sysdeps/unix/sysv/linux/ia
64/clone2.S?rev=1.3&content-type=text/x-cvsweb-markup&cvsroot=glibc

There is some discussion at 

http://sources.redhat.com/ml/libc-hacker/2000-06/msg00129.html

I admit a man page would be nice. 

(In 99.9% of cases, user code should really call pthread_create() instead,
which does the right thing.)

Hans

> -----Original Message-----
> From: Ray Bryant [mailto:raybry@engr.sgi.com]
> Sent: Tuesday, February 12, 2002 10:02 AM
> To: linux-ia64
> Subject: [Linux-ia64] __clone not defined??
> 
> 
> I was trying to compile the chat_c benchmark under IA64 Linux (RedHat
> 7.1) and I get an undefined reference to __clone.  (chat_c calls
> __clone() directly.)  Anyone have any tips on how to fix this?
> -- 
> Best Regards,
> Ray
> -----------------------------------------------
> Ray Bryant               SGI
> 512-453-9679 (work)      512-507-7807 (cell)
> raybry@sgi.com           raybry@austin.rr.com
>      Computers are like air conditioners.
>    They stop working when you open Windows.
> -----------------------------------------------
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

