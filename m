From: Ville Herva <vherva@niksula.hut.fi>
Date: Thu, 27 Dec 2001 11:16:53 +0000
Subject: [Linux-ia64] Re: 2.4.16 + ia64-011128: Unable to execute a "rwx" program
Message-Id: <marc-linux-ia64-105590698805721@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 27, 2001 at 11:45:01AM +0200, you [Ville Herva] claimed:
> 
> with 2.4.17rc2 + ia64-011214 an the symptoms are similar, but "strace ldd
> ./prog" crashes the machine (hard lockup, only alt-sysrq-b works.) With

Ok, the crash is propably because I weeded ptrace.c rejects by hand. I'll
try 2.4.17+011228 as soon as it compiles (somebody send be a faster box...
;)

The exec failure happens with 2.4.8-mandrake as well. Strange.

With "/lib/ld-linux-ia64.so.2 ./prog" it _seems_ to start, but it dies of
SIGSEGV right away (which of course could be a bug in my prog, although it
doesn't even reach the printf in the beginning on main()). I'll try to
debug.



-- v --

v@iki.fi

