From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 18 Sep 2002 16:42:26 +0000
Subject: Re: [Linux-ia64] Problem with 2.4.19 and ACPI
Message-Id: <marc-linux-ia64-105590701906040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906039@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906039@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Unfortunately, the detection of the end of resources loops on the
> ACPI_RSTYPE_END_TAG item due to a wrong size provided in this item,
> and sytem does not boot.

Can you try Takayoshi's patch
(https://external-lists.vasoftware.com/archives//linux-ia64/2002-August/003889.html)
instead?  That changes acpi_get_crs_addr() to bail out when it
sees an ACPI_RSTYPE_END_TAG, so we shouldn't care about the
size.

Bjorn


