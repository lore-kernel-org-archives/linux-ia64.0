From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 08 Nov 2000 22:16:52 +0000
Subject: Re: [Linux-ia64] test10 bug on SW IO TLB
Message-Id: <marc-linux-ia64-105590678205674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205667@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205667@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 08 Nov 2000 18:28:17 +0900, Hirofumi Fujita <fujita@kanagawa.hitachi.co.jp> said:

  Hirofumi> Hi, there seems to be a bug on software IO TLB buffer.

  Hirofumi> Kernel command line option `swiotlb=' is ignored when the
  Hirofumi> bounce buffer for SW IO TLB is allocated.

  Hirofumi> Following is a patch to this.  But the call to
  Hirofumi> setup_swiotlb should be in some file in arch/ia64/kernel/
  Hirofumi> , i guess.

Good point, though it's too arch-dependent to put it in init/main.c.
I moved it to arch/ia64/mm/init.c.  It does make some sense to put it
there as it's memory related and requires bootmem and should be early
enough that no drivers that need the sw I/O TLB are active yet.

	--david

