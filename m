From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 26 Jun 2002 18:20:28 +0000
Subject: [Linux-ia64] perfmon_mckinley.h for 2.4.18 and 2.5.18 available!
Message-Id: <marc-linux-ia64-105590701905724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Today, Intel released the microarchitecture document for
Itanium2. You can get it from:

	http://developer.intel.com/design/itanium

This means that I can now publish the missing Itanium2
file to get perfmon working on Itanium2 systems. 

You can also download the file from:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/perfmon_mckinley.h

This file must be placed into arch/ia64/kernel and it works
for both 2.4.18 and 2.5.18.

This file ONLY matters if you have *CONFIG_MCKINLEY AND*
CONFIG_PERFMON enabled.

Also note that pfmon-1.0 will run in generic mode 
with a kernel compiled with this file. In generic
mode, you only get CPU_CYCLES and IA64_INST_RETIRED.

I will release pfmon-1.1 with full Itanium2 support 
early next week.

-- 
-Stephane

