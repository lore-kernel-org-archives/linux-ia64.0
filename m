From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 23 Feb 2004 18:58:46 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB0E@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sure, we can do that.  It would clean up a chunk of code as well :-)

- Ken


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Monday, February 23, 2004 10:53 AM
To: Chen, Kenneth W
Cc: Jack Steiner; linux-ia64@vger.kernel.org
Subject: RE: HUGEPAGE SIZE a boottime option


>>>>> On Mon, 23 Feb 2004 08:26:32 -0800, "Chen, Kenneth W"
<kenneth.w.chen@intel.com> said:

 >  -(p8)	shr r22=r22,HPAGE_SHIFT-PAGE_SHIFT
 >  +(p8)	shr r22=r22,r27

Nice.

Can't you get rid of CONFIG_HUGETLB_PAGE_SIZE entirely?  Just pick
some default value and let the users override it with a boot
command-line (or runtime) option.  No?

	--david
