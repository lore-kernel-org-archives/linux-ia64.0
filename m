From: Jonathan Case Nicklin <nicklin@missioncriticallinux.com>
Date: Tue, 19 Sep 2000 11:45:21 +0000
Subject: [linux-ia64] Predication vs. Branching
Message-Id: <marc-linux-ia64-105590678205502@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This might not be the appropriate forum, but what the heck. Does anyone
have
a definitive answer on what happens to predicated instructions that are
not
executed (ie where in the pipeline are they discarded). The reason I ask

this is because i am curious about the threshold where it becomes better

to branch around a section of code rather than predicate it.

Best Regards,
Jonathan Nicklin



