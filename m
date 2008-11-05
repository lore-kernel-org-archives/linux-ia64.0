From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 05 Nov 2008 23:07:37 +0000
Subject: Re: [REGRESSION] Minimize per_cpu reservations patch causes NULL
Message-Id: <1225926457.1605.29.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1225830514.13942.8.camel@localhost.localdomain>
In-Reply-To: <1225830514.13942.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 2008-11-04 at 15:28 -0500, Doug Chapman wrote:
> So, it seems the options to fix this that I can think of are:
> 
> 1) try to get the info regarding offline CPUs earlier either by calling
> acpi_boot_init() earlier (probably not possible prior to calling find_memory())
> or walk a subset of the ACPI tables to get the number of offline CPUs sooner
> (which sounds ugly).

This ended up being a clean way to resolve this.  I just posted the patch, see
the "[PATCH][IA64] fix boot panic caused by offline CPUs" posting.

- Doug


