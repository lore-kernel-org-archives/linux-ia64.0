From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Jul 2003 00:05:04 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952369523859@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 18:56:15 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> If granularity is bytes, we need to support page-aligned
  Jack> allocations. Fetchop pages are mmap'ed to user space.

I see.  But then EFI-page-aligned memory won't do you no good either
(i.e., you'd need a PAGE_SIZE-based allocator).  Alternatively, just
allocated PAGE_SIZE+1 extra bytes and do the alignment yourself?

	--david
