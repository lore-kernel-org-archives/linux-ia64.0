From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 17:47:55 +0000
Subject: Re: [2.6 PATCH] Altix update
Message-Id: <16435.42315.529207.505662@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>
In-Reply-To: <200402181441.i1IEfIWX024531@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: akpm@osdl.org, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 08:41:18 -0600 (CST), Pat Gefre <pfg@sgi.com> said:

  Pat> Andrew, Here's a small mod for Altix. It breaks up our 'pci
  Pat> fixup' function and has some other smallish clean ups.

  Pat> For the ia64 crowd I've added 'platform_data' back into
  Pat> include/asm-ia64/pci.h

Please don't send such patches to Andrew.  I don't want to have
divergence on fundamental ia64 data structures.

  Pat> Can you take this ?

Feel free to send me incremental ia64 patches.  I asked you to send
the monster SN2 update patch to Andrew because I didn't want to get
stuck with it in my tree.  But now that that is taken care of, I'm
perfectly happy to handle your incremental patches.

	--david
