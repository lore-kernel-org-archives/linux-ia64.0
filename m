From: Dave Peterson <dsp@llnl.gov>
Date: Wed, 07 Jul 2004 01:12:10 +0000
Subject: watchdog on itanium
Message-Id: <200407061812.10444.dsp@llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I was wondering if anyone has tried implementing a watchdog for
detecting system hangs on Itanium.  If so, could someone please
point me to the source code?  If not, is anyone aware of any
fundamental limitations that would prevent one from implementing
a watchdog for Itanium?  I recall reading about performance
monitoring counters in the ia64 documentation from Intel and it
looked similar to what x86 provides.  Has anyone tried using the
performance monitoring counters on ia64 to generate periodic
NMIs for the purpose of implementing a watchdog?


Thanks,

Dave Peterson
