From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Jul 2006 18:16:27 +0000
Subject: RE: NUMA but not SMP
Message-Id: <617E1C2C70743745A92448908E030B2A3006BD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Suddenly this is a problem.  Generic UP kernel fails to build
>> with an "Undefined: __inc_zone_state", which shows up because
>> the __inc_zone_state function is defined inside some #if SMP
>> code, but used inside some #if NUMA code in mm/vmstat.c
>
> My fault. Does this fix it:

Yes, that fixes it.

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
