From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Jun 2007 16:45:52 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <617E1C2C70743745A92448908E030B2A01A88A6F@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Raising the PAGE_SIZE to 64k does generate a couple of
new warnings in the build:

drivers/usb/core/devio.c:632: warning: comparison is always false due to limited range of data type
fs/fat/inode.c:1227: warning: comparison is always false due to limited range of data type

Both of these are due to range comparisons of u16 data types
with PAGE_SIZE.  They both look harmless ... we'll get an
infinitessimal performance boost from the compiler dropping
the code, but it is annoying to add these to the (already
large) list of warnings to ignore.

Anyone got any cute ideas on how to make these warnings
go away?

-Tony
