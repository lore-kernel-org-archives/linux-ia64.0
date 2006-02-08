From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 08 Feb 2006 03:22:42 +0000
Subject: Re: arch/ia64/kernel/mca.c and CONFIG_ACPI
Message-Id: <1139368962.26420.144.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <10584.1139367384@kao2.melbourne.sgi.com>
In-Reply-To: <10584.1139367384@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-02-08 at 13:56 +1100, Keith Owens wrote:
> If CONFIG_ACPI is no then arch/ia64/kernel/mca.c drops the CPE handler,
> but not the CMC handler.  Also the CPE handler uses
> acpi_request_vector(), but CMC does not.  Why the differences?

   Probably a bug, because we could still poll for CPEs w/o ACPI.
Originally the CPE handler was only interrupt driven and the interrupt
is described as a platform interrupt source via ACPI.  So it made sense
then.  CMC have never had an ACPI dependency since the architecture
defines their setup and not the platform.

	Alex

