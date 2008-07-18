From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Jul 2008 22:44:21 +0000
Subject: RE: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3065E3A0D@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+       if (!time_after(delta_itm + new_itm, ia64_get_itc()))
>+               stolentick = ia64_get_itc() - new_itm;
>+
>+       do_div(stolentick, NS_PER_TICK);
>
>
> Which makes me assume that ia64_get_itc() is returning nanoseconds; does
> it do the adjustment from the itc's actual rate to nanoseconds?  Could
> it also apply an offset?

No. ia64_get_itc() does no scaling it returns the raw value from
the cr.itc register which increments at a frequency that the OS
discovers using a PAL call.

I'm not quite sure what the above code thinks it is doing. NS_PER_TICK
may have been poorly named???

-Tony
