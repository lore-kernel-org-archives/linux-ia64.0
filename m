From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Feb 2004 02:09:00 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB2C@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My apology for any oversight, that we would like to thank Jack
Steiner for his initiative on this feature and his initial cool
working patch.

- Ken


-----Original Message-----
From: Chen, Kenneth W 
Sent: Wednesday, February 25, 2004 5:26 PM
To: linux-ia64@vger.kernel.org
Cc: 'David Mosberger'
Subject: RE: HUGEPAGE SIZE a boottime option


We believe we have resolved all the remain issues, all critical
speed path has been taken care of, i.e., vhpt hander and context
switch.  There should be no performance penalty with this dynamic
hugetlb page size feature.

David, this is our final tested patch.

- Ken
