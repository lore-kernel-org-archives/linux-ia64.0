From: Keith Owens <kaos@sgi.com>
Date: Wed, 07 Jul 2004 01:23:57 +0000
Subject: Re: watchdog on itanium
Message-Id: <1948.1089163437@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407061812.10444.dsp@llnl.gov>
In-Reply-To: <200407061812.10444.dsp@llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 6 Jul 2004 18:12:10 -0700, 
Dave Peterson <dsp@llnl.gov> wrote:
>I was wondering if anyone has tried implementing a watchdog for
>detecting system hangs on Itanium.  If so, could someone please
>point me to the source code?  If not, is anyone aware of any
>fundamental limitations that would prevent one from implementing
>a watchdog for Itanium?  I recall reading about performance
>monitoring counters in the ia64 documentation from Intel and it
>looked similar to what x86 provides.  Has anyone tried using the
>performance monitoring counters on ia64 to generate periodic
>NMIs for the purpose of implementing a watchdog?

There is no NMI handler on Linux ia64 systems.  Mainly because cli() on
Linux ia64 blocks NMI.  Any useful watchdog would have to generate a
PMI or INIT interrupt.  The kernel has no PMI handler, it has an INIT
monarch handler (but no useful INIT slave handler).  Even the INIT
monarch is not designed to recover.  See this thread from 2001.

http://www.gelato.unsw.edu.au/linux-ia64/0105/1548.html

