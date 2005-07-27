From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Jul 2005 21:14:03 +0000
Subject: RE: [patch] properly stop devices before poweroff
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F040022CC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050429061825.36f98cc0.akpm@osdl.org>
In-Reply-To: <20050429061825.36f98cc0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@osdl.org>, kaneshige.kenji@jp.fujitsu.com, ambx1@neo.rr.com, greg@kroah.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Brown, Len" <len.brown@intel.com>

>> The remaining problem is cause by the order of the calls in sys_reboot:
>> 
>>                 device_suspend(PMSG_SUSPEND);
>>                 device_shutdown();
>> 
>> The call to device_suspend() shuts down the mpt/fusion 
>driver.  But then
>> device_shutdown() calls sd_shutdown() which prints:
>> 
>>   Synchronizing SCSI cache for disk sdb
>
>Okay, looks to me like sd_shutdown should be done from
>device_suspend(), not device_shutdown [because it needs scsi subsystem
>to be functional]. Also for reboot we probably want PMSG_FREEZE (not
>PMSG_SUSPEND), to keep it slightly faster.

Are you going to work on making those changes?

-Tony
