From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 05 Mar 2003 22:54:16 +0000
Subject: [Linux-ia64] RHAS Errata e25 perfmon update
Message-Id: <marc-linux-ia64-105590709805978@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To All,

If you are using RedHat Advanced Server 2.1 (Derry) and the latest
Errata which comes with a kernel labeled e.25 you will have problems
if you try to use perfmon. Due to some bugs in perfmon, the entire
subsystem was disabled. As a consequence, all software relying
on this subsystem will not work. This includes pfmon, but also
PAPI-based software.

I have generated a patch which fixes the problem AND also updates
RHAS perfmon to version 1.3 similar to what we have in 2.4.20 or higher. 
This includes new features such as sampling period randomizations and
idle task exclusion in system-wide mode.

The patch must be applied on top of the e.25 kernel source tree.
You will need to reconfigure the kernel via make menuconfig 
(or equivalent) to re-enable perfmon,i.e., CONFIG_PERFMON must be
set.

The patch can be downloaded from the perfmon website at:

	http://www.hpl.hp.com/research/linux/perfmon

-- 
-Stephane

