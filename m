From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 30 Aug 2002 22:28:51 +0000
Subject: Re: [Linux-ia64] PCI_BUSES_TO_SCAN off by 1?
Message-Id: <marc-linux-ia64-105590701906008@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906005@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906005@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 30 Aug 2002 15:11:20 -0600
Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:

> > Is there any reason we don't scan the last PCI bus on IA64?
> > arch/ia64/kernel/pci.c has PCI_BUSES_TO_SCAN set to 255 instead
> > of 256, which prevents the kernel from scanning bus 255.  This
> > causes is some problems since some of our machines (ie, the
> > Itanium2 "tiger") place chipset registers in PCI config space on
> > the last PCI bus.
> 
> I agree, it sounds like an off-by-one error.
> 
> Along this line, I had been hoping that if we find any PCI root
> bridges via ACPI, we could skip the blind scanning of buses 0-255.
> It sounds like skipping the blind scan might break tiger, though.

AFAIK, tiger defines PCI bus 255 as a host-bus bridge in ACPI.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


