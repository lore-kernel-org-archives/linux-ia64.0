From: navin <navin@students.iiit.net>
Date: Wed, 07 May 2003 17:52:58 +0000
Subject: Re: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 May 2003, David Mosberger wrote:

>>>>>> On Wed, 7 May 2003 21:33:11 +0530 (IST), navin <navin@students.iiit.net> said:
>
>  navin> Also from some of the previous posts i found that if i am
>  navin> building on a pentium or some other machine there is a trick
>  navin> involved.Andreas Jaegar told me that i had to install-headers
>  navin> before compiling the bootstrap gcc.He said to contact you
>  navin> guys as i don't have the headers for ia64.I have the sources
>  navin> for kernel which contain asm-ia64 and glibc-2.3.I don't know
>  navin> how to avoid the error.
>
>Have you tried NUE?  It's available here:
>
>  http://www.software.hp.com/products/LIA64/overview2a.htm
>

Yeah i have tried NUE.It is good and gcc is 2.95 something and glibc 
2.0. 
	I even tried copying the nue ia64-hp-something headers files and 
giving gcc the option with --header to that directory but it messed up as 
i previously mentioned

I don't know what the error is.Can you tell me where i can find the docs 
or how do i build the parallel glibc and gcc . It is nasty but it works.
I saw this on earlier lists other ports but hardly found the procedure.

The problem is that building an alpha target is easy .But when i apply 
the same rules to ia64 it breaks.GCC breaks.



