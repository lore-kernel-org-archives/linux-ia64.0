From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Apr 2008 18:54:13 +0000
Subject: RE: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <1FE6DD409037234FAB833C420AA843EC0105AE07@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As an alternative, could kdump_on_fatal_mca be turned on by 
> default in Altix (in the Altix specific boot code)?  Then
> we could set our default without impacting other vendors.

This is a sysctl variable ... are there any cases where we
set these to different default values for different platforms?

It would seem better for the kernel to set the default value
to the most useful one, and for system owners that don't want
the default behaviour to just add an entry to /etc/sysctl.conf
to set their preference.

I'm not sure how we decide what is the most useful default.
So far SGI are voting for enabling dumping for MCA, and
Fujitsu have implicitly voted to disable (as that is what
Seto-san's patch sets).  Any other opinions?

-Tony
