From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Apr 2008 21:59:38 +0000
Subject: RE: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <1FE6DD409037234FAB833C420AA843EC01094FF6@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony, (if there are no other votes until your poll closing)
> would you apply my patch modifying the default to 1?
> Or I need to resend you all just modified the one byte?

Change is not even one byte ... just one bit ('0' = 0x30,
'1' = 0x31 :-)

I made the change and committed it to my "test" branch.

-Tony
