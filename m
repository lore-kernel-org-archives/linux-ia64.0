From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Apr 2004 17:42:13 +0000
Subject: Re: [PATCH] ISA stubs for ia64
Message-Id: <16500.15733.693223.140954@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404061630.20264.bjorn.helgaas@hp.com>
In-Reply-To: <200404061630.20264.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 Apr 2004 09:09:12 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Tuesday 06 April 2004 5:18 pm, David Mosberger wrote:
  >> I don't like this patch at all.  The #defines to
  >> unsupported_isa_dma_interface() turn compile-time errors into
  >> potential runtime errors.  With a properly abstracted interface, the
  >> ISA-compatibility-macros should not lead to any code in ISA-free
  >> systems (and hence there would be no possibility of runtime errors).

  Bjorn> True.  I actually started by modifying drivers to use CONFIG_ISA to
  Bjorn> determine whether to use ISA interfaces, but (a) that leads to a lot
  Bjorn> of changes, most of which I can't test and have the potential to break
  Bjorn> other arches, and (b) somebody suggested that ISA is sort of a special
  Bjorn> case because it hasn't been converted to the driver model.

  Bjorn> But I certainly agree that it would be a lot cleaner.

If it's not possible to define ISA-compatibility macros that expand
into no runtime code, I don't see an easy solution.  Perhaps we could
at least provide macros such that a driver _can_ be converted to such
a model.  It will still require fixing some/many/most drivers with
ISA-support, but to get allmodonf to work, we could just disable a
driver altogether if it depends on ISA and the platform doesn't
support ISA.  The cleanup/conversion can then be done incrementally,
as the need arises.

	--david
