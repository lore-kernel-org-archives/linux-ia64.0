From: Matthew Wilcox <willy@debian.org>
Date: Fri, 07 Nov 2003 17:24:56 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106825306426816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 07, 2003 at 09:13:11AM +0100, Sylvain Jeaugey wrote:
> On Thu, 6 Nov 2003, Matthew Wilcox wrote:
> These lines show you the numa topology of your machine (in our case, we 
> have 2 CPUS per domain, and a memory area).
> This is quite a big piece of information about hardware. Even if it is 
> quite long, I think it should be part of the ACPI information.

Yes, but do we need to know it at boot time, or should it be available
in some other way (eg /proc/acpi/srat or something).  I would argue
that is more useful than seeing it in dmesg.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
