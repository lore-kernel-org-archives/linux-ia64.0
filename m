From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Apr 2004 23:18:50 +0000
Subject: Re: [PATCH] ISA stubs for ia64
Message-Id: <16499.15066.967913.431674@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404061630.20264.bjorn.helgaas@hp.com>
In-Reply-To: <200404061630.20264.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Apr 2004 16:30:20 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> These stubs allow us to build all the old drivers that assume
  Bjorn> ISA is present.  (Many of these support both ISA and PCI
  Bjorn> adapters, so we do actually want them.)

  Bjorn> With this patch and the others I just posted (hw_random,
  Bjorn> simscsi, gen_rtc), we can build allmodconfig on ia64.

I don't like this patch at all.  The #defines to
unsupported_isa_dma_interface() turn compile-time errors into
potential runtime errors.  With a properly abstracted interface, the
ISA-compatibility-macros should not lead to any code in ISA-free
systems (and hence there would be no possibility of runtime errors).

	--david
