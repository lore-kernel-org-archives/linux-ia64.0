From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 15 Dec 2005 14:33:35 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <43A17EBF.50607@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:

> 
> You ought to just describe this hardware in the ACPI namespace
> and use acpi_bus_register_driver() to bind the drivers.

ACPI support is in the process of being implemented.
Currently, there is no ACPI DSDT table being created on
SN systems.

P.
