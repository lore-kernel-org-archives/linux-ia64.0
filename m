From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Fri, 02 Nov 2001 22:34:26 +0000
Subject: RE: [Linux-ia64] Upgrading from 2.4.3
Message-Id: <marc-linux-ia64-105590698805438@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805434@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805434@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jonathan,

I would request you to file QuAD case so that support team at Intel can
review your current hardware level and determine MAX BIOS level that you can
use.  Hope this helps.

Thanks
Sunil

-----Original Message-----
From: Doug Beattie [mailto:dbb@caldera.com]
Sent: Friday, November 02, 2001 8:21 AM
To: Jonathan Thackray
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Upgrading from 2.4.3


Jonathan:

It appears your processor stepping is older that is being supported
now days.

Caldera supports only B3 and higher stepping and I believe the other
vendors do the same. Updating the BIOS will not help in this case.
Getting the source and rebuilding with switches for older processors
may help if you find a release that still has the switches/code to
support you.

Doug

Jonathan Thackray wrote:
> 
> Hi,
> 
> Can anyone tell me what firmware / BIOS is needed for newer kernels?
> I'm attempting to upgrade our LION currently running 2.4.3
> (Red Hat Linux release 7.0.98 (Wolverine))
> 
> I've compiled 2.4.13, installed it, but it panics when booting,
> somewhere after scanning the PCI bus. I've also burnt Debian woody for
> ia64 onto CD, but this just hangs when booting (it prints some kernel
> messages then hangs). Our BIOS / firmware is on BIOS 69, and I've
> attempted to upgrade, but our I/O card is 'legacy', so BIOS 69 is the
> latest it can run.
> 
> Can I run newer kernels, or will I have to get a new box?
> /proc/cpuinfo says:
> 
> processor  : 0
> vendor     : GenuineIntel
> family     : IA-64
> model      : Itanium
> revision   : 2
> archrev    : 0
> features   : standard
> cpu number : 0
> cpu regs   : 4
> cpu MHz    : 666.738000
> itc MHz    : 666.738000
> BogoMIPS   : 442.49
> 
> Thanks,
> Jon.
> 
> --
> Jonathan Thackray         Zeus House, Cowley Road, Cambridge CB4 OZT, UK
> Software Engineer                   +44 1223 525000, fax +44 1223 525100
> Zeus Technology                                         http://zeus.com/
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Douglas B. Beattie
------------------
Linux Test Architect - Caldera, Inc.
dbb@caldera.com

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

