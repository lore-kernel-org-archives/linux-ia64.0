From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 05 Jun 2000 20:42:25 +0000
Subject: Re: [Linux-ia64] Two IA-64 Linux bugs
Message-Id: <marc-linux-ia64-105590678205117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Sun, 4 Jun 2000, Wan-Teh Chang wrote:

> System info:
> [nspr@tl2 unix]$ uname -a
> Linux tl2.compile.sourceforge.net 2.3.99-pre6-000501-18smp
> #1 SMP Sat May 6 21:30:48 PDT 2000 ia64 unknown
> 
> Bug #2: sysconf(_SC_NPROCESSORS_ONLN) returns 0.
> It should return the number of processors online.

I've fixed that in the "official" glibc tree one week ago.  It's been
fixed in HJ's tree a few weeks ago (but I don't know how he did it).

This is implemented by counting the lines starting with "CPU#" in
/proc/cpuinfo.  If the kernel guys change the format of that file, it
might break again.

Dan



