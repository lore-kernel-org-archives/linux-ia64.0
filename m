From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Mon, 10 Nov 2003 18:02:29 +0000
Subject: RE: discontig patch question
Message-Id: <marc-linux-ia64-106848783529939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



> > 
> > Why is MAX_ORDER 19 on IA64?
> 
> For hugetlbfs, afaik.  But it should only be 18 according to 
> arch/ia64/Kconfig.

That is correct. For the support of 4G hugepage size (when the normal
page size is 16K).  Kernel actually takes looks at MAX_ORDER -1 (and not
MAX_ORDER).
