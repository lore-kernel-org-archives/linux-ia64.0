From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 22 Oct 2002 22:37:56 +0000
Subject: Re: [Linux-ia64] PCI_BUSES_TO_SCAN off by 1?
Message-Id: <marc-linux-ia64-105590709805208@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906005@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906005@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Oct 2002 16:20:52 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> To complete this thread, it looks like we can't do this.  My
  Bjorn> i2000 reports PCI root bridges for buses 0, 1, 2, and 3 via
  Bjorn> ACPI.  The 460GX chipset, including the CSRs for the AGP
  Bjorn> bridge, appears in config space on PCI bus 4.  ACPI doesn't
  Bjorn> tell us about bus 4, so we have to do the blind scan to find
  Bjorn> that stuff.

We no longer do the blind scan in 2.5.39 and it seems to work fine on
the big sur I tested it on:

	$ uname -v
	#33 SMP Sat Sep 28 10:58:07 PDT 2002
	$ dmesg|fgrep 'Probing PCI'
	PCI: Probing PCI hardware on bus (00)
	PCI: Probing PCI hardware on bus (01)
	PCI: Probing PCI hardware on bus (02)
	PCI: Probing PCI hardware on bus (03)
	PCI: Probing PCI hardware on bus (04)

Could it be that your i2000 has old firmware?  My big sur reports the
following firmware version (via Stephane's smbiosview utility):

	version      : W460GXBS2.86E.0117C.P09.200108091154

  --david

