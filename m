From: dann frazier <dannf@dannf.org>
Date: Mon, 31 May 2004 04:48:43 +0000
Subject: IA64_GENERIC vs. NUMA/DISCONTIG/VIRTUAL_MEM_MAP
Message-Id: <20040531044843.GA25705@dannf.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hey,
  It was requested that I turn on DISCONTIGMEM in my builds for Debian, in order to support
Altix boxes.  This option is not currently selectable w/ a 2.6.6 "Generic" kernel, but
it is with all other flavors.

  I dug around to see if this is intentional, and found evidence[1] that it is not.
From what I can grok from Documentation/kbuild/kconfig-language.txt, select will force
these options off - maybe "depends on" is what was intended?
I tried creating a patch w/ this change, but found that adding thse deps creates a
recursive dependency tree that breaks Kconfig, since DISCONTIGMEM depends on
(IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC).

  What is the desired behavior?  Should generic kernels require these options?
Should we force these options on for platforms that support them, and therefore
make them non-user configurable?  Should we just turn them on by default, and 
allow users to disable them?

[1] 
|Age  	Author  	Annotate  	Comments
|8 months 	jbarnes@com[davidm] 	1.48 	ia64: force on appropriate generic options
|
|
|--- 1.47/arch/ia64/Kconfig	Sun May 30 21:34:28 2004
|+++ 1.48/arch/ia64/Kconfig	Sun May 30 21:34:28 2004
|@@ -57,6 +57,10 @@
| 
| config IA64_GENERIC
| 	bool "generic"
|+	select NUMA
|+	select ACPI_NUMA
|+	select VIRTUAL_MEM_MAP
|+	select DISCONTIGMEM
| 	---help---
| 	  This selects the system type of your hardware.  A "generic" kernel
| 	  will run on any supported IA-64 system.  However, if you configure
