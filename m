From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 21 Sep 2004 00:52:05 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface
Message-Id: <1095727925.8780.58.camel@mythbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>
	 <200409201333.42857.dtor_core@ameritech.net>
	 <20040920122404.B15677@unix-os.sc.intel.com>
	 <200409201812.45933.dtor_core@ameritech.net>
In-Reply-To: <200409201812.45933.dtor_core@ameritech.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, 2004-09-20 at 18:12 -0500, Dmitry Torokhov wrote: 
> 
> Hi Anil,
> 
> I obviously failed to deliver my idea :) I meant that I would like add eject
> attribute (along with maybe status, hid and some others) to kobjects in
> /sys/firmware/acpi tree.
> 

Dmitry,

   See the patch I just posted to acpi-devel and lkml (Subject:
[PATCH/RFC] exposing ACPI objects in sysfs).  It exposes acpi objects as
you describe.   Something simple like:

 # cat /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/_EJ0

Will call the _EJ0 method on the ACPI device.  You can evaluate eject
dependencies using the _EJD method.

	Alex



