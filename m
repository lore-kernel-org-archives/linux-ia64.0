From: Matthew Wilcox <willy@debian.org>
Date: Fri, 08 Nov 2002 19:01:10 +0000
Subject: Re: [Linux-ia64] Newbie questions
Message-Id: <marc-linux-ia64-105590709805370@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Nov 09, 2002 at 12:21:40AM +0530, CH Gowri Kumar wrote:
> I wrote the above program and compiled it and found the appropriate codes
> for the instructions using objdump -d and wrote the following program
> 
> char sc[] ="\x0a"
>            "\x10"
>            "\x00"
>            "\x18\x00\x21\x00\x92\x00\x00\x42\xe0\x11\x00\x20\x84\x0a";
>        main()
>        {
>          void (*fp)(void);
>          fp = (void*)sc;
>          fp();
>       }
> 
> But this program on execution gives me the error:
> "Illegal instruction (core dumped)"
> (A similar program for IA-32 worked well.)

function pointers on ia64 are "fat" -- that is, they are not the address
of the function, they are the address of a function descriptor which
contains (iirc) the GP and the address of the function.  i believe glibc
pokes around with this kind of thing, so you may wish to look at the
ia64 assembly code in there to see how it does it.

-- 
Revolutions do not require corporate support.

