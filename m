From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 22 Oct 2002 22:20:52 +0000
Subject: Re: [Linux-ia64] PCI_BUSES_TO_SCAN off by 1?
Message-Id: <marc-linux-ia64-105590709805207@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906005@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906005@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 30 August 2002 3:11 pm, Bjorn Helgaas wrote:
> Along this line, I had been hoping that if we find any PCI root
> bridges via ACPI, we could skip the blind scanning of buses 0-255.

To complete this thread, it looks like we can't do this.  My
i2000 reports PCI root bridges for buses 0, 1, 2, and 3 via
ACPI.  The 460GX chipset, including the CSRs for the AGP
bridge, appears in config space on PCI bus 4.  ACPI doesn't
tell us about bus 4, so we have to do the blind scan to find
that stuff.

Bjorn


