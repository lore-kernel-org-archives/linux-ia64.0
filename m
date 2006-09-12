From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Sep 2006 20:23:54 +0000
Subject: RE: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <617E1C2C70743745A92448908E030B2A833C02@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hmmm. I may have answered at least part of my question. It appears that the boot cpu
> cannot exit back to the SAL slave loop since it was never in the slave loop to start with.
>
> This will take some thought..... More later.

Yes.  cpu0 is a special case as there is no way to return it to SAL.
Linux hotplug code has a hack where we borrow the return details from
some other cpu in the case that someone wants to take cpu0 offline.
Will this work for Altix?  Would we have to be careful to get the
return details from some other cpu on the same node?

-Tony
