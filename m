From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 30 Nov 2001 05:43:18 +0000
Subject: Re: [Linux-ia64] about linux/ia64 mm
Message-Id: <marc-linux-ia64-105590698805563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805562@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Nov 2001 23:19:53 +0800, "=?gb2312?B?zMYg0+4=?=" <ytang5@hotmail.com> said:

  Tang> hi all, i was a little confused by linux/ia64 mm; as i know,
  Tang> linux requires physical memory to be mapped contiguously to
  Tang> kernel space( don't care highmem); and PAGE_OFFSET is defined
  Tang> to 0xe000000000000000 in linux/ia64; that's region 7, its page
  Tang> size is fixed to 64M(2.4.12). how could __get_free_pages()
  Tang> allocate such a big _page_? it's absolutely impossible.  so i
  Tang> think i made a big mistake somewhere, would someone help me
  Tang> out?  thx :-)

The page allocator works at the page frame level, which can be
configured to have a size of 4, 8, 16, or 64KB.  The large TLB
mappings are used merely to access the underlying memory (think of it
as a physical address space with a non-zero starting address).

	--david

