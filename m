From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 28 Jun 2004 17:36:45 +0000
Subject: RE: Three random questions
Message-Id: <200406281735.i5SHZ3Y02989@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40E01743.4060309@octopus.com.au>
In-Reply-To: <40E01743.4060309@octopus.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Duraid Madina wrote on Monday, June 28, 2004 6:04 AM
> 2) What is the Right Way to get huge pages at the moment? I'm running a
> 2.6.5-rc and seem to be running across odd bugs using hugetlbfs.

Check out Documentation/vm/hugetlbpage.txt in the kernel source tree for
a detailed explanation.  If you found any bug in this area, please report
to the mailing list.  We fixed a few bugs last week. So might be good to
try latest kernel.


> 3) Whatever happened to alloc_hugepages()? That strikes me as vastly (!)
> superior to hugetlbfs, at least for the scientist types who just want to
> escape horrible TLB thrashing.

This was debated on the linux kernel mailing list extensively in the past,
check out the archive.


