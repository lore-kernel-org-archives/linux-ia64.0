From: Yaroslav Halchenko <yoh@onerussian.com>
Date: Sun, 23 Nov 2003 08:52:36 +0000
Subject: Re: weird speed problem
Message-Id: <marc-linux-ia64-106957761119369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. I'm currently running unstable debian with 2.4.20 smp prepackaged
kernel but the problem started appearing before on RH. So I thought may
be you can give me a good guess why this might happen

I have a really weird problem with estimating how fast my itanium is.

I have a really simple/stupid program which is the loop which iterates
1000 times around the point of iterative approximation of PI. 

First I've compiled it under shipped red hat... it ran 12 sec, I was
happy because it took the same amount of time for 64bit amd opteron...
Then I played with how fast ia32 emulation is (took it about 2-3 minutes
for the same but ia32 bit compiled program). But then at some point
after I recompiled it back to ia64 it started running almost as slow as
ia32 though file says
a.out: ELF 64-bit LSB executable, IA-64 (Intel 64 bit architecture)
version 1 (SYSV), for GNU/Linux 2.4.0, dynamically linked (uses shared
libs), not stripped

I reinstalled linux with debian... The same story - that damn program
which runs fast under all other architerctures runs stupidly slow 64bit
on itanium...

What could I screw by checking ia32 emulation so 'thoroughly'??
What can I check? I've checked /proc/acpi/cpu but didn't find anything
usefull/weird there...

P.S. bogomips run from command line reports just ~400 when /proc/cpuinfo
is 1400...

WHAT is WRONG??? Please advise

                                  .-.
=------------------------------   /v\  ----------------------------Keep in touch                    // \\     (yoh@|www.)onerussian.com
Yaroslav Halchenko              /(   )\               ICQ#: 60653192
                   Linux User    ^^-^^    [175555]
             Key  http://www.onerussian.com/gpg-yoh.asc
GPG fingerprint   3BB6 E124 0643 A615 6F00  6854 8D11 4563 75C0 24C8

