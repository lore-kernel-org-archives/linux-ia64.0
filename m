From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 07 Mar 2001 20:34:00 +0000
Subject: Re: [linux-ia64] re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This is really a question about throw/catch on g++.

I am not a g++ expert.  The best place to find g++ experts is on the FSF
gcc mailing lists.  For instance, gcc-bugs@gcc.gnu.org.

>I wonder if your description of NYI is the reason for the failure?

I don't know what "NYI" means.

>I am running gnupro-1117-6 (gcc version 2.96-ia64-000717 snap 001117)
>on Redhat 7.0 fisher (kernel 2.4.0-0.99.11smp) on a lion processor
>the following program runs o.k. with ./a.out 5 - but fails with ./a.out 6

I reproduced the problem easily enough with the old compiler release.
Take a quick stab with the debugger, I see that the gp value in r1 is wrong
which is curious.  I will have to look into this some more.  I would guess
that there might be a problem with the backing store/stacked registers in the
gcc unwinder.  That is one way to explain why it works with 5 nesting levels,
but not at 6 nesting levels.

A more interesting question is whether or not this testcase works with the
gcc-3 pre-release branch.  Unfortunately, your testcase will not compile with
gcc-3.  I get an error complaining that cout is undeclared.  I don't know
enough about C++ to know how to fix this.  This means I can't check to see
if the problem has already been fixed.  Can you provide me with a testcase
that works with gcc-3?

Jim

