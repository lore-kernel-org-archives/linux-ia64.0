From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Tue, 16 Mar 2004 03:20:57 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040316.122057.00477633.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <JP20040316093003.3103921@pst.fujitsu.com>
	<20040316015401.GF9931@wotan.suse.de>
	<20040316.113209.63031370.taka@valinux.co.jp>
In-Reply-To: <20040316.113209.63031370.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ak@suse.de
Cc: n-yoshida@pst.fujitsu.com, raybry@sgi.com, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hello,

> Yes, you are true.
> In the fault handler, we should use find_lock_page() instead of
> find_get_page() to find a hugepage associated with the fault address.

Sorry, locking page is not needed.

> After that pte_none(*pte) should be called again to check whether 
> some races has happened.

While checking, mm->page_table_lock have to be locked.

