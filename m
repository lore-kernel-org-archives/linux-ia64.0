From: "MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com>
Date: Wed, 14 May 2003 15:47:23 +0000
Subject: RE: [Linux-ia64] libc umount and umount2 can't both be right
Message-Id: <marc-linux-ia64-105590723705795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> > In libc, umount and umount2 are the same code.  They both use
> > syscall number 1044 without introducing a call layer. 
> 
> looks like a typo in libc to me
> 
> -i
> ianw@gelato.unsw.edu.au
> http://www.gelato.unsw.edu.au

I don't think it was a typo.

The problem is that 2.4 IA64 kernels don't have a umount2
entry point.  They have a single entry point to provide
functionality for both umount and umount2 in the library.

Since the single kernel entry point expects two parameters,
the library needs to supply the second parameter (0) in the
case of umount, where the user only supplies the first
one.

Bob Montgomery, HP

> 
> --- libc/sysdeps/unix/sysv/linux/ia64/syscalls.list.old 
> 2003-05-14 09:10:04.000000000 +1000
> +++ libc/sysdeps/unix/sysv/linux/ia64/syscalls.list     
> 2003-05-14 09:09:40.000000000 +1000
> @@ -1,6 +1,6 @@
>  # File name    Caller  Syscall name    # args  Strong name   
>   Weak names
>   
> -umount2                -       umount          2       
> __umount2       umount2
> +umount2                -       umount2         2       
> __umount2       umount2
>   
>  # Whee! 64-bit systems naturally implement llseek.
>  llseek         EXTRA   lseek           C:3     __libc_lseek  
>   __lseek lseek __libc_lseek64 __llseek llseek __lseek64 lseek64
> 

