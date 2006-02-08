From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:56:24 +0000
Subject: arch/ia64/kernel/mca.c and CONFIG_ACPI
Message-Id: <10584.1139367384@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If CONFIG_ACPI is no then arch/ia64/kernel/mca.c drops the CPE handler,
but not the CMC handler.  Also the CPE handler uses
acpi_request_vector(), but CMC does not.  Why the differences?

