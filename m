From: "bob_zhang2004" <bob_zhang2004@tom.com>
Date: Fri, 25 Jun 2010 06:43:07 +0000
Subject: Re: Re: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11 ia64)power off failrue when "shut
Message-Id: <201006251443030205791@tom.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201006242333018701088@tom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: "len.brown" <len.brown@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

Hi, 

	I have a queston not confirm, thanks for answering. 
from acpi sepc 2.0a

7.3.3 \_GTS (Going To Sleep)
_GTS is an optional control method. If it exists, OSPM must execute the _GTS control method just prior to
setting the sleep enable (SLP_EN) bit in the PM1 control register when entering the S1, S2, S3, and S4
sleeping states and when entering S5 for orderly shutdown. _GTS allows ACPI system firmware to perform
any required system specific functions prior to entering a system sleep state. OSPM will set the sleep
enable (SLP_EN) bit in the PM1 control register immediately following the execution of the _GTS control
method without performing any other physical I/O or allowing any interrupt servicing. The sleeping state
value (1, 2, 3, 4, or 5) is passed as an argument to the _GTS control method. The _GTS method must not
attempt to directly place the system into a sleeping state. OSPM performs this function by setting the sleep
enable bit upon return from _GTS. In the case of entry into the S5 soft off state however, _GTS may indeed
perform operations that place the system into the S5 state as OSPM will not regain control.
The _GTS method must be self-contained (not call other methods). Additionally, _GTS may only access
OpRegions that are currently available (see the _REG method for details).
--------
my questions are followings :

1, 
especially , this sentense ,

 "OSPM will set the sleep enable (SLP_EN) bit in the PM1 control register immediately following the execution of the _GTS control
method without performing any other physical I/O or allowing any interrupt servicing."

in fact ,before power supply is off , linux kernel will shutdown all devices by calling driver->shutdown() function. 
if shutdown () failure, device will not be power off state. in this case, after setting  the sleep enable (SLP_EN) bit   ,what will happen ? 
Should the power supply be off ?  



