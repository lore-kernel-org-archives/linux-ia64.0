From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 18:38:47 +0000
Subject: Re: __you_cannot_kmalloc_that_much
Message-Id: <marc-linux-ia64-105604795606878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604765306485@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604765306485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Jun 2003 11:33:59 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> While trying to compile the latest pull from
  Tony> the lia64.bkbits.net:8080/linux-ia64-2.5
  Tony> repository I hit the "you_cannot_kmalloc_that_much"
  Tony> message in the final link.

  Tony> The culprit is in

  Tony> drivers/usb/host/uhci-debug.c

  Tony> which contains:

  Tony> #define MAX_OUTPUT      (PAGE_SIZE * 16)

  Tony> ...

  up-> data = kmalloc(MAX_OUTPUT, GFP_KERNEL);

  Tony> With the default 16k page size we are trying to
  Tony> allocate 256K of memory, which is bigger that the
  Tony> largest size pool in include/linux/kmalloc_sizes.h


  Tony> Do we need a larger pool (I don't think so) or is
  Tony> this allocation excessive?

Clearly the latter.  If it works with 4KB page size on x86, certainly
we don't need 4 or 8 times more space on ia64.

Can you take this up directly with the author of the offending line?

Thanks,

	--david
