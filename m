From: "Yu, Luming" <luming.yu@intel.com>
Date: Sat, 13 Mar 2004 02:20:46 +0000
Subject: RE: cat /proc/acpi/events bad for your system's health!
Message-Id: <3ACA40606221794F80A5670F0AF15F8401CBB74E@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16455.50905.681007.50048@napali.hpl.hp.com>
In-Reply-To: <16455.50905.681007.50048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
>   Luming> I confirm this issue here on tiger with 2.6.4-rc3 kernel ,
>   Luming> but 2.4 is ok.  Not sure this is a regression.
> 
>   >>  OK.  I assume you (or Len) will take care of it?
> 
> 
>   Luming> The following patch make crash on my tiger gone.  However I
>   Luming> didn't dig out the true culprit.  Maybe this is due to
>   Luming> excessive optimization.
> 
>   Luming> BTW, my gcc version is 3.2.3 .
> 
> The patch is fine as a temporary workaround, but surely we need to
> find out the root cause of this problem.  It sounds like there is a
> race somewhere.  I suppose it's possible that it's a compiler problem,
> but I rather doubt it.  Are you doing to dig deeper into it?  If not,
> please let me know.
> 
> 	--david
> 
The main difference with 2.4 is signal_pending. From ACPI log, I also
noticed that
the thread waiting on acpi_bus_event_queue didn't resume proberly,
because there
is no exit message of acpi_bus_receive_event in ACPI log  as expected if
you turn on
full debug flag of acpi.

PS. I don't have access to the machine right now. 

--Luming
