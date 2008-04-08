From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Apr 2008 17:51:42 +0000
Subject: RE: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <1FE6DD409037234FAB833C420AA843EC0105ACCB@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think kdump_on_fatal_mca should be set to 1 by default. Fatal
> mca is exactly the case where we need a dump to analyze the problem.

I'm not so sure.  If the fatal MCA was caused by the s/w doing something
wrong (e.g. accessing non-existant memory), then a dump is useful to find out
what went wrong.

But if the MCA was caused by some h/w error (e.g. 2xECC bit error in kernel
memory), then a dump won't help.

Perhaps the dump would help distinguish the s/w case from the h/w case?

-Tony
