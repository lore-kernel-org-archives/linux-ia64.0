From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Wed, 04 May 2005 08:50:17 +0000
Subject: CONFIG_FORCE_MAX_ZONEORDER default value
Message-Id: <200505040850.CAA10967@udlkern.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I was wondering why CONFIG_FORCE_MAX_ZONEORDER was changed from 19 (in 2.4)
to 18 (in 2.6). Note that this value sets the maximum number of orders,
i.e. the actual maximum order is one less, i.e. 17. For the 16Kb default
page size this gives you a maximum page size of 2Gb, which isn't
particularly useful on ia64 since that size is not supported. The only
reason I can see 18 being useful would be to allow for 1Gb huge pages
on a system where PAGE_SIZE is set to 8Kb.

Anyway, with the default page size being 16K, it seems that it would
be more appropriate for CONFIG_FORCE_MAX_ZONEORDER to be either 17 (for
a 1 Gb max huge page size) or 19 (to support the maximum 4 Gb page size
available on Itanium 2 systems).

Is there another consideration that I've missed?

John Marvin
