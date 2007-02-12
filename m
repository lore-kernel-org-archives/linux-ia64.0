From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 12 Feb 2007 23:55:02 +0000
Subject: Re: 2.6.19 - MCA in dmi_scan on an Orca
Message-Id: <200702121655.02855.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80702121134u47c08388s762bce2c712c0f8e@mail.gmail.com>
In-Reply-To: <5e0a1fd80702121134u47c08388s762bce2c712c0f8e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 12 February 2007 12:34, Karthik Gopalakrishnan wrote:
> When I booted 2.6.19 on an IA Superdome (Orca), the kernel caused an
> MCA around the "dmi_scan" function. When I set "CONFIG_DMI = n", it
> was automatically set back to "y" during the build. I had to
> workaround the problem by commenting out
> "core_initcall(run_dmi_scan)". On doing so, the MCA went away.
> 
> So, my questions are:
> 1. Does the Orca actually have a DMI Interconnect, or is the Kernel
> detecting it wrongly?
> 2. Is there a cleaner way to disable DMI in such situations?

How much memory is in your Superdome?  If you have "only" 2GB of
memory, you might be running into this issue:  In such a partition,
firmware puts the SMBIOS table in a granule that is not fully-
populated by WB memory, so the kernel maps the SMBIOS table with
a UC mapping.  But Superdome doesn't support UC accesses to memory,
so you get an MCA.

We really ought to just fail the mapping attempt, but the kernel
isn't smart enough to do that yet.  And I hate to have this special
case where machines with 2GB or less or memory can't read the SMBIOS
table, while larger-memory machines can.  So we just decided to make
those "small-memory" configs unsupported.

If you collect the address of the SMBIOS table and compare it with
the output of "memmap" from the EFI shell, you should be able to
tell whether this is the problem.  The SMBIOS table needs to live
in a 16MB (or 64MB, depending on whether you set CONFIG_IA64_GRANULE_16MB
or CONFIG_IA64_GRANULE_64MB) granule that is fully-populated with
WB memory.

Bjorn
