From: Sylvain Jeaugey <sylvain.jeaugey@bull.net>
Date: Fri, 07 Nov 2003 08:13:11 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106824271316473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 6 Nov 2003, Matthew Wilcox wrote:

> > ACPI: SRAT Processor (id[0x00] eid[0x00]) in proximity domain 0 enabled
> > ACPI: SRAT Processor (id[0x20] eid[0x00]) in proximity domain 0 enabled
[...]
> > ACPI: SRAT Processor (id[0x00] eid[0x5e]) in proximity domain 47 enabled
> > ACPI: SRAT Processor (id[0x20] eid[0x5e]) in proximity domain 47 enabled
> 
> ... for example ;-)  96 lines which honestly tell me nothing.
> 
> > ACPI: SRAT Memory (0x0000003000000000 length 0x0000001000000000 type 0x1) in proximity domain 0 enabled
> > ACPI: SRAT Memory (0x000000b000000000 length 0x0000001000000000 type 0x1) in proximity domain 1 enabled
> [ snip 44 lines ]
> > ACPI: SRAT Memory (0x0000173000000000 length 0x0000001000000000 type 0x1) in proximity domain 46 enabled
> > ACPI: SRAT Memory (0x000017b000000000 length 0x0000001000000000 type 0x1) in proximity domain 47 enabled
> 
> ... and again.
> 
These lines show you the numa topology of your machine (in our case, we 
have 2 CPUS per domain, and a memory area).
This is quite a big piece of information about hardware. Even if it is 
quite long, I think it should be part of the ACPI information.

Sylvain

