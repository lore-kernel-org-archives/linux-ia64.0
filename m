From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Apr 2004 17:14:57 +0000
Subject: RE: [PATCH] switching between CPEI&CPEP
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6FFD59A8@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HVW00DA36CQCF@fjmail502.fjmail.jp.fujitsu.com>
In-Reply-To: <0HVW00DA36CQCF@fjmail502.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>>> On Fri, 09 Apr 2004 16:05:14 +0900, Hidetoshi Seto 
><seto.hidetoshi@jp.fujitsu.com> said:
>
>  Hidetoshi> Hi, all, I've already sent this patch, but receiving no
>  Hidetoshi> feedback, so I try again.

David Mosberger replied:
>MCA seems to have become an orphan.  Tony, are you still the 
>owner/maintainer of that code?

Yes, I'm still taking reponsibility for the MCA code ... I did a
round of private feedback to these patches to Seto-san, and I forgot
that the list hasn't seen any response from me.

Seto-san is definitely heading in the right direction with this
patch, and I encourage anyone with error injection capability
to take his patch for a spin in their lab.  If there is some
positive feedback, then these are good canditates to get into
the base.

-Tony
