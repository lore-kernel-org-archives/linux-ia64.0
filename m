From: Keith Owens <kaos@sgi.com>
Date: Wed, 11 Sep 2002 05:51:04 +0000
Subject: Re: [Linux-ia64] [trivial] Request for merging of two sets of redundant SGI IA64Configure.help texts
Message-Id: <marc-linux-ia64-105590701906019@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906017@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906017@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steven Cole <elenstev@mesatop.com> wrote:
>Could one of you help resolve the following very trivial problem.  In
>2.4.20-pre5 Documentation/Configure.help, there exists two
>Configure.help entries for CONFIG_IA64_SGI_SN_SIM and
>CONFIG_IA64_SGI_SN_DEBUG.
>
>The configurators will of course only display the first of the two.
>Would someone please indicate which of the texts is the more accurate or
>combine them as you see fit.  You can send me the results or make up a
>patch yourself.
>
>If this is a moot point, deleting the second text would be the default
>thing to do.

The first set is wrong.  There is also an error in ia64/config.in for
one of these variables.  Patch against 2.4.19.

--- Documentation/Configure.help.orig	Wed Sep 11 15:44:36 2002
+++ Documentation/Configure.help	Wed Sep 11 15:45:24 2002
@@ -24409,16 +24409,6 @@
 
   If you don't know what to do, choose "generic".
 
-CONFIG_IA64_SGI_SN_SIM
-  Build a kernel that runs on both the SGI simulator AND on hardware.
-  There is a very slight performance penalty on hardware for including this
-  option.
-
-CONFIG_IA64_SGI_SN_DEBUG
-  This enables addition debug code that helps isolate
-  platform/kernel bugs. There is a small but measurable performance
-  degradation when this option is enabled.
-
 # Choice: pagesize
 Kernel page size
 CONFIG_IA64_PAGE_SIZE_4KB
--- arch/ia64/config.in.orig	Wed Sep 11 15:45:29 2002
+++ arch/ia64/config.in	Wed Sep 11 15:49:01 2002
@@ -75,7 +75,7 @@
 
 if [ "$CONFIG_IA64_SGI_SN1" = "y" ] || [ "$CONFIG_IA64_SGI_SN2" = "y" ]; then
 	define_bool CONFIG_IA64_SGI_SN y
-	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG n
+	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
 	bool '  Enable autotest (llsc). Option to run cache test instead of booting' \
 			CONFIG_IA64_SGI_AUTOTEST n


