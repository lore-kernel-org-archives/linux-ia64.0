From: William Cohen <wcohen@redhat.com>
Date: Wed, 05 Apr 2006 18:39:18 +0000
Subject: Re: 2.6.17-rc1 perfmon2 new code base + libpfm available
Message-Id: <44340ED6.2060208@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000508030400010306050906"
List-Id: <linux-ia64.vger.kernel.org>
References: <20060405154319.GD6232@frankl.hpl.hp.com>
In-Reply-To: <20060405154319.GD6232@frankl.hpl.hp.com>
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------000508030400010306050906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephane Eranian wrote:

> The new version of the library, libpfm, includes the following changes:
> 
> 	- updated to match 2.6.17-rc1 new system call numbers
> 
> 	- modified pfmlib.h to use 64-bit integer for generic PMC register
> 	  (submitted by Kevin Corry from IBM)

Hi Stephane,

There isn't an perfmon_x86_64.h file anymore. Shouldn't the Makefile 
eliminate that? The stock "make install" fails because that file doesn't 
exist. I think the attached patch fixes this problem.

-Will

--------------000508030400010306050906
Content-Type: text/x-patch;
 name="x86_64_merge.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x86_64_merge.diff"

--- libpfm-3.2-060405/include/Makefile.orig	2006-04-05 14:09:32.000000000 -0400
+++ libpfm-3.2-060405/include/Makefile	2006-04-05 14:35:09.000000000 -0400
@@ -40,7 +40,6 @@
 
 ifeq ($(CONFIG_PFMLIB_ARCH_X86_64),y)
 HEADERS += perfmon/pfmlib_os_x86_64.h   \
-	   perfmon/perfmon_x86_64.h     \
 	   perfmon/pfmlib_comp_x86_64.h
 endif
 

--------------000508030400010306050906--
