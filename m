From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 07 Aug 2003 21:36:36 +0000
Subject: Re: [PATCH] sn2 pci fixes (among others)
Message-Id: <marc-linux-ia64-106029222015065@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106028902811432@msgid-missing>
In-Reply-To: <marc-linux-ia64-106028902811432@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch is fine with me (since it touches SGI files only), but one tip:
in the future, you may want to use diffstat -p1 so that the useful
part of the common path-name prefix is maintained.

	--david

>>>>> On Thu, 7 Aug 2003 13:42:56 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> sn2 still doesn't use ACPI to describe PCI busses on the system (I'm
  Jesse> working on it), so we have to do it the old fashioned way.  This patch
  Jesse> also includes a few other fixes.

  Jesse> io/hwgfs/interface.c           |    5 -
  Jesse> io/machvec/pci.c               |   85 +++--------------------
  Jesse> io/machvec/pci_bus_cvlink.c    |  151 ++++++++++++++---------------------------
  Jesse> io/platform_init/sgi_io_init.c |   31 --------
  Jesse> kernel/sn2/cache.c             |    6 +

  Jesse> Thanks,
  Jesse> Jesse
