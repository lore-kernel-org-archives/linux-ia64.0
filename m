From: Ashok Raj <ashok.raj@intel.com>
Date: Thu, 13 May 2004 04:44:16 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040512214416.A12395@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 12, 2004 at 08:51:07PM -0700, Paul Jackson wrote:
> Could someone explain to me who's doing what with cpu, memory and node hotplug?
Paul back in action :-)
> 
> In particular, I haven't noticed much interaction between some cpu
> hotplug work that Ashok has been posting on linux-ia64 and/or lkml, and
> either of the email lists lhns-devel or linux-hotplug-devel.  And I also

You dont see any interaction between the cpu hotplug and the one tokunaga-san
is posting because they can be done independently. So here is the scope,
i will try to keep it short and sweet.!

CPU hotplug - Ashok(intel for IA64) Primarily does logical cpuonline/offline
	support to work with base support released by rusty from 2.6.5
	PPC64 - Joel Schoop, Vatsa (IBM), x86 (Rusty/Vatsa)
	ACPI support for cpu hotplug - Anil Keshavamurty (intel) base line 
	emulation and ACPI patches are ready, we are reviewing it internally 
	and it should make its way to acpi lists sometime in the next 2 weeks.
	(on major changes.. just extensions to acpi already in base kernel)
Memory hotplug - Dave Hansen et all (mostly IBM) + Matt Tolentino (Intel)
		Goto-san (fujitsu) + Takahashi/Iwamoto San (VA Linux)
		disscussed in lhms (sourceforgelist)
	Matt is also co-ordinating ACPI based memory hotplug support for 
	the work that he requires as necessary.

Node Hotplug support - Tokunaga-san (fujitsu) mostly concentrating on 
		ACPI based numa node hotplug. This work is independent
of rest of the hotplug (atleast mostly) and would invoke other module
hotplug code as required.  (roughly @10000 ft level)

Iam not sure what specifically you are looking for, please post your specific 
request to the appropriate lists and iam sure you will get hooked up.

lhcs - cpu hotplug list
lhms - memory hotplug
lhns - newly launched node hotplug

all of them hosted from sourceforge.

Hope this helps.
> just noticed the thread on lkml by Keiichiro, with comments from Dave,
> mentioning Matthew, hinting at additional interactions that might be
> desirable between various efforts here.  I even see some SGI work here.
> 
> Perhaps if I had been following this for a while, it would all make sense.
> But I haven't been, and it doesn't.


Cheers,
ashok
