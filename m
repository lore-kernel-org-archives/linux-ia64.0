From: Keith Owens <kaos@sgi.com>
Date: Thu, 03 Jan 2002 08:35:30 +0000
Subject: [Linux-ia64] Re: is casting of function descriptor assignments for ia64 ONLY a good idea?
Message-Id: <marc-linux-ia64-105590698805734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Jan 2002 21:46:35 -0800, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>SUMMARY:
>
>	Keith Owens just pointed out that ia64 function descriptor assignments MUST be cast:
>
>		 pointer = ((unsigned long *)(&my_printf))[0])
>
>	howerver it appears that other platforms MUST NOT be cast.
>
>I was wondering if that a good idea. It seems it might require hacking 
>a lot of existing code.

The problem only arises if you want to print or store the location of
the function code.  That is very rare, most of the time you just pass
function pointers around and let the compiler handle their format.
Think of a function pointer as an opaque cookie.

>Why is this necessary for just ia64? 

Not just ia64, powerpc 64 as well.  You are assuming that all pointers
are the same format when that is not guaranteed by the C standard.  On
most architectures they are the same, you can convert a function
pointer to a void pointer and back again but it is not defined
behaviour.

On IA64 and PPC64 the function pointer does not reference the function
itself, instead it points to a function descriptor.  The function
descriptor contains a pointer to the function code plus additional data
such as a pointer to the global data to be used when the function is
called.  This is mandated by the architecture software ABI.

I had to solve this problem for my dynamic syscall patch[1] because the
syscall table points directly to the function code in the kernel, not
to the function descriptor, even on ia64.  I define DYNAMIC_SYSCALL_T
and DYNAMIC_SYSCALL_FUNCADDR() which are asm specific.  On most
systems, funcaddr is a noop.  For i386

#define DYNAMIC_SYSCALL_T              long
#define DYNAMIC_SYSCALL_FUNCADDR(f)    (DYNAMIC_SYSCALL_T)(f)

but on ia64 it does real work

#define DYNAMIC_SYSCALL_T              long long
#define DYNAMIC_SYSCALL_FUNCADDR(f)    ({DYNAMIC_SYSCALL_T *fp = (DYNAMIC_SYSCALL_T *)(f); fp[0];})

BTW, the lack of a true descriptor for syscall entries is one reason
why trying to put syscalls in modules is a non-starter.  The ia64
syscall handler assumes that all syscall code is in the kernel using
the constant kernel global data pointer, so there is no need to change
the environment on a syscall.  But syscalls in modules require a
different environment and there is nowhere to store the extra data in
the syscall table.

[1] http://marc.theaimsgroup.com/?l=linux-kernel&m0902118219570&w=2


