From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:54:43 +0000
Subject: [Linux-ia64] Re: [proposal] 4-level page-table for Linux/IA64
Message-Id: <marc-linux-ia64-105590698805600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:07:04 +0800 , "Tang, Yu" <yu.tang@intel.com> said:

  Yu> hi david: I have one proposal here.  i don't know whether it has
  Yu> been raised before. if so, sorry for that; And here we go:

Unless I'm missing something, what you're proposing is not a 4-level
page table but a segmented address space.  The total mappable space
*at any given time* will still be limited to what you get with a
normal 3-level page table.  I doubt that's the right direction to go.

	--david

