From: Einar Saltnes <eisa@scali.no>
Date: Tue, 17 Oct 2000 14:25:51 +0000
Subject: Re: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205575@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205567@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205567@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> >>>>> On Fri, 13 Oct 2000 11:55:10 +0200, Einar Saltnes <eisa@scali.no> said:
> 
>   Einar> However, there are some problems with the system clock. The
>   Einar> BIOS clock seems to run OK, but in linux the clock seems to
>   Einar> stop after some random time. When using "date", time stands
>   Einar> still after some random time! This gives me some trouble
>   Einar> using other utilities e.g. ping and even shutdown.  This
>   Einar> shows only on the dual B1-stepping box and not the UP
>   Einar> A2-stepping box. It can run OK for a few minutes or for some
>   Einar> hours.  Anyone got a clue?
> 
> Doesn't sound familiar.  It's very unlikely to be a hardware problem
> because the kernel's timer tick runs off the CPU cycle counter.  Where
> did you get the test9 kernel from and what version of the toolchain
> was used to compile it?
> 
Source tarball was downloaded from ftp.kernel.org. The ia64 patch was
downloaded from the same site. Kernel was compiled in the RedHat
Developers Distribution of 0825 environment with a test9 kernel.
Toolchain version is

: eisa@scali9-12:eisa; rpm -qi gnupro
Name        : gnupro                       Relocations: /usr 
Version     : 0501                              Vendor: Red Hat, Inc.
Release     : 2                             Build Date: Thu 01 Jun 2000
12:45:11 AM MEST
Install date: Tue 17 Oct 2000 02:10:41 PM MEST      Build Host:
boris.devel.redhat.com
Group       : Development/Tools             Source RPM:
gnupro-0501-2.src.rpm


: eisa@scali9-12:eisa; gcc -v
Reading specs from
/usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/specs
gcc version 2.9-ia64-000216-final


: eisa@scali9-12:eisa; rpm -qi glibc
Name        : glibc                        Relocations: (not
relocateable)
Version     : 2.1.3                             Vendor: Red Hat, Inc.
Release     : 0.0622.3                      Build Date: Sat 19 Aug 2000
11:55:26 PM MEST
Install date: Tue 03 Oct 2000 05:51:18 PM MEST      Build Host:
boris.devel.redhat.com
Group       : System Environment/Libraries   Source RPM:
glibc-ia64-2.1.3-0.0622.3.src.rpm


I see in my config file that I have enabled both the BSTEP_- and the
B0STEP_SPECIFIC settings. As you point out only BSTEP_ should be
enabled.

----------

OK, I have compiled a new kernel with only BSTEP_ enabled. Same story.
Using "date" I observe that time stops approx 20 minutes after boot of
the new kernel.
However, "cat /proc/efirtc" seems to show correct numbers. BTW, is this
the output of the HWclock? Is this the same source as "date" gets its
numbers from?


Thanks!

Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

