From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 15 Oct 2003 02:15:48 +0000
Subject: Re: GENERIC still failing?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Message-Id: <marc-linux-ia64-106618419811909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
To: linux-ia64@vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 14, 2003 at 05:22:05PM -0700, Jesse Barnes wrote:
> Looks like CONFIG_NUMA and CONFIG_DISCONTIGMEM are missing from the
> config being built.  A generic kernel won't work without them.

mea culpa, as usual. Is there some way to make it when you select
generic it always requires CONFIG_NUMA/DISCONTIGMEM?

Also, trying to look at the help text, it seems that the sub-items of
a 'choice' in Kconfig can't have individual help texts?

For example 
 
choice
	prompt "IA-64 processor type"
	---help---
	 this will show when you select help on 'IA-64 processor type'
config ITANIUM
	bool "Itanium"
	---help---
	 this text appears not to show when you select help on 'Itanium' 
	 in the choice.
endchoice

I'm not sure if this is the desired effect, but certainly some of the
help texts appear mis-placed under an option of the choice rather than
at the choice it's self (see attached for example).

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="Kconfig.patch"

===== arch/ia64/Kconfig 1.47 vs edited =====
--- 1.47/arch/ia64/Kconfig	Sat Oct 11 09:17:05 2003
+++ edited/arch/ia64/Kconfig	Wed Oct 15 12:07:07 2003
@@ -36,27 +36,22 @@
 choice
 	prompt "IA-64 processor type"
 	default ITANIUM
-
-config ITANIUM
-	bool "Itanium"
 	help
 	  Select your IA-64 processor type.  The default is Intel Itanium.
 	  This choice is safe for all IA-64 systems, but may not perform
 	  optimally on systems with, say, Itanium 2 or newer processors.
 
+config ITANIUM
+	bool "Itanium"
+
 config MCKINLEY
 	bool "Itanium 2"
-	help
-	  Select this to configure for an Itanium 2 (McKinley) processor.
 
 endchoice
 
 choice
 	prompt "IA-64 system type"
 	default IA64_GENERIC
-
-config IA64_GENERIC
-	bool "generic"
 	---help---
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -74,7 +69,12 @@
 	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant
 	  systems.
 
-	  If you don't know what to do, choose "generic".
+	  If you don't know what to do, choose "generic".  Note that
+	  "generic" also requires  you enable NUMA support and Discontiguous 
+	  memory support.
+
+config IA64_GENERIC
+	bool "generic"
 
 config IA64_DIG
 	bool "DIG-compliant"
@@ -97,9 +97,6 @@
 choice
 	prompt "Kernel page size"
 	default IA64_PAGE_SIZE_16KB
-
-config IA64_PAGE_SIZE_4KB
-	bool "4KB"
 	---help---
 	  This lets you select the page size of the kernel.  For best IA-64
 	  performance, a page size of 8KB or 16KB is recommended.  For best
@@ -114,6 +111,9 @@
 	  64KB               Requires Itanium 2 or newer processor.
 
 	  If you don't know what to do, choose 16KB.
+
+config IA64_PAGE_SIZE_4KB
+	bool "4KB"
 
 config IA64_PAGE_SIZE_8KB
 	bool "8KB"

--6TrnltStXW4iwmi0--
