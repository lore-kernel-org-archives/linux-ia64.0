From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Jan 2014 20:10:54 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DBA26A@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I assume it is best to first make -O1 work and then progress to -O2 later?

Depends on whether you have a need to debug this on gcc4.6

It seems that newer gcc (4.8.2) works again (see the Mikael/Mikulas
thread on "ski" on this mailing list.  I also managed to build a kernel
with gcc 4.8.2 and boot it on my rx2600.

-Tony
