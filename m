From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 31 Jul 2000 23:16:08 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205254@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Dan,

> I can't see any *good* reason for storing integers into void pointers,
> if those integers aren't valid memory addresses.
> 
> The C language definition requires a diagnostic in this case,
> regardless of any size issues and gcc emits this diagnostic even on
> x86, where the two types have the same size: 
> 
>     ues12:~/tmp 68> cat test.c
>     int main()
>     {
>         void *p = 123;
>         return 0;
>     }
>     ues12:~/tmp 69> gcc test.c
>     test.c: In function `main':
>     test.c:3: warning: initialization makes pointer from integer without a cast
>     ues12:~/tmp 70> uname -a
>     Linux ues12 2.2.12-20 #1 Mon Sep 27 10:40:35 EDT 1999 i686 unknown
> 
> If you want to shut up such warnings, do what gcc suggests: cast the
> integer to void *.

Sorry, my original post was a little unclear.  The compiler spits out a
warning even if the programmer uses a cast.

Mike



