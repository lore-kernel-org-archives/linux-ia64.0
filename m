From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Fri, 08 Nov 2002 19:03:40 +0000
Subject: [Linux-ia64] Newbie questions
Message-Id: <marc-linux-ia64-105590709805369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805370@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805370@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello all,
I am a post-graduate student trying to write a JIT compiler for .NET CLR
on Linux,IA-64.

I have some queries related to IA-64 assembly programming

I plan to write the JIT this way:
I generate the native code directly (instead of assembly language and
then using assembler)for a particular method and jump to the address
of the starting memory location where I have generated the native code. I
have written a small program to check whether such a thing is feasible, 
which is as follows:

#include<unistd.h>
int main()
{
  __asm__("
      mov r32
      mov r1525
      break 0x100000"
  );
}

I wrote the above program and compiled it and found the appropriate codes
for the instructions using objdump -d and wrote the following program

char sc[] ="\x0a"
           "\x10"
           "\x00"
           "\x18\x00\x21\x00\x92\x00\x00\x42\xe0\x11\x00\x20\x84\x0a";
       main()
       {
         void (*fp)(void);
         fp = (void*)sc;
         fp();
      }

But this program on execution gives me the error:
"Illegal instruction (core dumped)"
(A similar program for IA-32 worked well.)

I couldn't figure out what could be the problem.
I also tried using "br instruction" approach instead of the function
pointer approach, but couldn't succeed.

Can anyone explain why it is failing or atleast give me pointers where to
look for?

Thanks in advance.
Gowri Kumar


