From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jul 2003 22:54:27 +0000
Subject: RE: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951943520407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 15:47:34 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> We could plan ahead for hypothetical future multi-page users by
  Tony> defining a "size" argument to alloc/free

Let's stick with a tried-and-true malloc/free-like interface (nobody
every gets size arguments to free() right, do they?).

  Tony> but keep our (your) life simple for now by only implementing
  Tony> the one-page-at-a-time usage model.

Sure, that sounds reasonable.

	--david
