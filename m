From: Duraid Madina <duraid@octopus.com.au>
Date: Mon, 28 Jun 2004 13:04:03 +0000
Subject: Three random questions
Message-Id: <40E01743.4060309@octopus.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

1) Has anyone pondered writing an HPUX-to-Linux ELF64 object 
demangler/translator? *damn* that aCC is good sometimes..

2) What is the Right Way to get huge pages at the moment? I'm running a 
2.6.5-rc and seem to be running across odd bugs using hugetlbfs.

3) Whatever happened to alloc_hugepages()? That strikes me as vastly (!) 
superior to hugetlbfs, at least for the scientist types who just want to 
escape horrible TLB thrashing.

     Curious,

     Duraid
