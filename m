From: Jonathan Thackray <jthackray@zeus.com>
Date: Fri, 02 Nov 2001 15:03:37 +0000
Subject: [Linux-ia64] Upgrading from 2.4.3
Message-Id: <marc-linux-ia64-105590698805434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Can anyone tell me what firmware / BIOS is needed for newer kernels?
I'm attempting to upgrade our LION currently running 2.4.3
(Red Hat Linux release 7.0.98 (Wolverine))

I've compiled 2.4.13, installed it, but it panics when booting,
somewhere after scanning the PCI bus. I've also burnt Debian woody for
ia64 onto CD, but this just hangs when booting (it prints some kernel
messages then hangs). Our BIOS / firmware is on BIOS 69, and I've
attempted to upgrade, but our I/O card is 'legacy', so BIOS 69 is the
latest it can run.

Can I run newer kernels, or will I have to get a new box?
/proc/cpuinfo says:

processor  : 0
vendor     : GenuineIntel
family     : IA-64
model      : Itanium
revision   : 2
archrev    : 0
features   : standard
cpu number : 0
cpu regs   : 4
cpu MHz    : 666.738000
itc MHz    : 666.738000
BogoMIPS   : 442.49

Thanks,
Jon.

-- 
Jonathan Thackray         Zeus House, Cowley Road, Cambridge CB4 OZT, UK
Software Engineer                   +44 1223 525000, fax +44 1223 525100
Zeus Technology                                         http://zeus.com/


