From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 28 Jan 2005 01:24:02 +0000
Subject: Re: anyone using Itanium B-step support?
Message-Id: <1106875442.18514.121.camel@aretha.corp.specifixinc.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-j71OYWKj3/eIm9QzP/79"
List-Id: <linux-ia64.vger.kernel.org>
References: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
In-Reply-To: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
To: linux-ia64@vger.kernel.org


--=-j71OYWKj3/eIm9QzP/79
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-01-27 at 13:56, James E Wilson wrote:
> However, rather than add more ITANIUM_BSTEP_SPECIFIC support to the
> kernel, I think it makes more sense to obsolete it and remove it.

Here is the change I am suggesting.


--=-j71OYWKj3/eIm9QzP/79
Content-Disposition: attachment; filename=patch.bstep.remove
Content-Type: text/x-patch; name=patch.bstep.remove; charset=utf-8
Content-Transfer-Encoding: 7bit

*** Kconfig.orig	Sat Aug 14 03:56:22 2004
--- Kconfig	Thu Jan 27 17:16:51 2005
*************** config IA64_BRL_EMU
*** 134,147 ****
  	depends on ITANIUM
  	default y
  
- config ITANIUM_BSTEP_SPECIFIC
- 	bool "Itanium B-step specific code"
- 	depends on ITANIUM
- 	help
- 	  Select this option to build a kernel for an Itanium prototype system
- 	  with a B-step CPU.  You have a B-step CPU if the "revision" field in
- 	  /proc/cpuinfo has a value in the range from 1 to 4.
- 
  # align cache-sensitive data to 128 bytes
  config IA64_L1_CACHE_SHIFT
  	int
--- 134,139 ----
*** Makefile.orig	Sat Aug 14 03:54:48 2004
--- Makefile	Thu Jan 27 17:17:03 2005
*************** ifeq ($(GCC_VERSION),3)
*** 49,56 ****
   endif
  endif
  
- cflags-$(CONFIG_ITANIUM_BSTEP_SPECIFIC)	+= -mb-step
- 
  CFLAGS += $(cflags-y)
  head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
  
--- 49,54 ----

--=-j71OYWKj3/eIm9QzP/79--

