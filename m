From: Jack Steiner <steiner@sgi.com>
Date: Thu, 06 Jan 2011 17:09:42 +0000
Subject: Very large memory configurations:   > 16 TB
Message-Id: <20110106170942.GA8253@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, mingo@elte.hu
Cc: linux-ia64@vger.kernel.org



SGI is currently developing an x86_64 system with more than 16TB of memory per
SSI. As far as I can tell, this should be supported. The relevant definitions
such as MAX_PHYSMEM_BITS appear ok.


One area of concern is page counts. Exceeding 16TB will also exceed MAX_INT
page frames. The kernel (at least in all places I've found) keep pagecounts
in longs.

Have I missed anything? Should this > 16TB work? Are there any kernel problems or
problems with user tools that anyone knows of.

Any help or pointers to potential problem areas would be appreciated...

---
Jack Steiner (steiner@sgi.com)
SGI - Silicon Graphics, Inc. 
