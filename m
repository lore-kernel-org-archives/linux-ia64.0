From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Nov 2008 21:12:33 +0000
Subject: RE: [REGRESSION] Minimize per_cpu reservations patch causes NULL
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35BE05E2F@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1225830514.13942.8.camel@localhost.localdomain>
In-Reply-To: <1225830514.13942.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 1) try to get the info regarding offline CPUs earlier either by calling
> acpi_boot_init() earlier (probably not possible prior to calling find_memory())
> or walk a subset of the ACPI tables to get the number of offline CPUs sooner
> (which sounds ugly).
>
>
> 2) after we call acpi_boot_init() go back and setup the per-cpu datastructures
> for the offline CPUs then.  Seems like this might be cleaner but I have not
> investigated the specifics.

What about:

3) Perform the needed allocations when we try to bring the new cpu online?

It is possible that this will fail ... but if you are so low on memory
that you can't allocate a couple of pages for the new cpu, you are in
a world of hurt already and adding a new cpu is liklely to make things
worse.

-Tony
