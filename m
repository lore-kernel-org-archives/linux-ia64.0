From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Jun 2003 18:33:59 +0000
Subject: __you_cannot_kmalloc_that_much
Message-Id: <marc-linux-ia64-105604765306485@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While trying to compile the latest pull from
the lia64.bkbits.net:8080/linux-ia64-2.5
repository I hit the "you_cannot_kmalloc_that_much"
message in the final link.

The culprit is in

	drivers/usb/host/uhci-debug.c

which contains:

#define MAX_OUTPUT      (PAGE_SIZE * 16)

	...

	up->data = kmalloc(MAX_OUTPUT, GFP_KERNEL);

With the default 16k page size we are trying to
allocate 256K of memory, which is bigger that the
largest size pool in include/linux/kmalloc_sizes.h


Do we need a larger pool (I don't think so) or is
this allocation excessive?

-Tony
