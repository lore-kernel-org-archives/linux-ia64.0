From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 27 Apr 2006 23:51:18 +0000
Subject: RE: [patch] update sn2 defconfig
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0658F43D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq07j5bs50k.fsf@jaguar.mkp.net>
In-Reply-To: <yq07j5bs50k.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Shouldn't we have this at 10 so we get the most exposure possible.
>
> I'd be fine with that, I just stuck with the default.

I took this patch as-is ... if you wanto bump this to 10, send
another patch.

>>> -# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
>>> +CONFIG_INFINIBAND_IPOIB_DEBUG=y
>> 
>> Why turn on debugging for everyone?
>
> I didn't do anything there, It was the Infinibug stuff that turned it
> on itself.

I tried to turn it off, and it came right back on again. This
is "default y" in drivers/infiniband/ulp/ipoib/Kconfig, but also

 bool "... " if EMBEDDED

EMBEDDED is "n" ... so I've no idea.

-Tony
