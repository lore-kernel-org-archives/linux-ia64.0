From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 22 Oct 2002 01:30:49 +0000
Subject: [Linux-ia64] Re: PCI hotplug changes for 2.5.39 or later
Message-Id: <marc-linux-ia64-105590709805204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805195@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805195@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 18 Oct 2002 04:10:56 -0700, "Lee, Jung-Ik" <jung-ik.lee@intel.com> said:

  JI> The following patch fixes ia64 kernel dump on Hot-Add of PCI
  JI> bridge cards.  pcibios_fixup_bus(); pci_do_scan_bus(); on
  JI> Hot-Add of bridge adapter;

The patch was broken because your mailer wrapped long lines (the
"pcibios_fixup_pbus_ranges() declaration got wrapped).  I fixed this
by hand, but please make sure this won't happen again in the future.

Thanks,

	--david

