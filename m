From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 19:17:51 +0000
Subject: Re: [Linux-ia64] Modifing memory attributes needs cache flush
Message-Id: <marc-linux-ia64-105590698805792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805781@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805781@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 09 Jan 2002 17:39:38 +0900 (JST), Takanori Kawano <t-kawano@ebina.hitachi.co.jp> said:

  Takanori>  If software modifies the memory attributes for a page,
  Takanori> software must flush any processor cache copies with the
  Takanori> Flush Cache(fc) instruction for the following memory
  Takanori> attribute changes: speculative/non-speculative,
  Takanori> cacheable/uncacheable(for transitions from cacheable to
  Takanori> uncacheable), and coherency. Software must flush any
  Takanori> coalescing buffers if a page is changes from coalescing to
  Takanori> any other attribute.

  Takanori> Does anybody know why the current code doesn't flush
  Takanori> cache?

Well, the kernel is supposed to use each page in a consistent fashion
(no change of attributes).  Though this isn't enforced anywhere (see
earlier discussion about write-coalescing mappings.  We need a general
solution for this eventually.  For now, it will have to be dealt with
on a case-by-case basis, I think.

	--david

