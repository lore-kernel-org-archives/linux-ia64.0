From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Sep 2003 22:06:08 +0000
Subject: Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106444124817462@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106441927021899@msgid-missing>
In-Reply-To: <marc-linux-ia64-106441927021899@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon,

Could you please make it VERY clear that the system call numbers the
patch is using are NOT OFFICIAL numbers and are therefore likely to
change and/or collide unless and until they get accepted into the
official tree?

BTW: What do cpusets provide that couldn't be done with user-level
tools on top of the existing sched_setaffinity() system call?

Thanks,

	--david
