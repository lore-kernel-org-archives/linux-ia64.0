From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 11 Nov 2002 18:48:27 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 11 Nov 2002 09:49:49 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Yes, but for the kernel it is allowed also without the
  Christian> patch and the the user could insert a duplicate mapping
  Christian> for the same physical page but this useless for him
  Christian> because of the access rights and also the kernel would
  Christian> not use these pages (because the kernel has no knowledge
  Christian> of this pages).

Useless to the user, but dangerous to the health of the machine!
Please note that attribute aliasing can lead to a machine-check and
therefore is an absolute no-no (the machine check could be triggered
either by a hardware-prefetch or due to speculative memory accesses
inside the kernel).

	--david

