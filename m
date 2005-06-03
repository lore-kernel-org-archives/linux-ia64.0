From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 03 Jun 2005 09:02:26 +0000
Subject: Initialization of cr.dcr
Message-Id: <42A01CA2.8010209@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

playing around with speculation I found that on initialization dcr.dm is 
not set, while the comment says "Initialize default control register to 
defer all speculative faults". To be conform to the comment (and also to 
the expected behavior) the value IA64_DCR_DM should be added in 
arch/ia64/kernel/setup.c.

Christian

