From: Dmitry Torokhov <dtor_core@ameritech.net>
Date: Mon, 20 Sep 2004 18:33:42 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <200409201333.42857.dtor_core@ameritech.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920093532.D14208@unix-os.sc.intel.com>
In-Reply-To: <20040920093532.D14208@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Monday 20 September 2004 11:35 am, Keshavamurthy Anil S wrote:
> This patch support /sys/firmware/acpi/eject interface where in 
> the ACPI device say "LSB0" can be ejected by echoing "\_SB.LSB0" > 
> /sys/firmware/acpi/eject
> 

I wonder if eject should be an attribute of an individual device and visible
only when device can be ejected. Reading from it could show eject level
(_EJ0/_EJ3 etc).

-- 
Dmitry
