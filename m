From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 27 Mar 2004 00:00:55 +0000
Subject: Re: [RFC] ACPI IRQ proposal
Message-Id: <200403261700.55781.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403231537.14505.bjorn.helgaas@hp.com> <20040326.143930.41646618.maeda@jp.fujitsu.com> <20040326.175630.74755524.t-kochi@bq.jp.nec.com>
In-Reply-To: <20040326.175630.74755524.t-kochi@bq.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Cc: maeda.naoaki@jp.fujitsu.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

On Friday 26 March 2004 1:56 am, Takayoshi Kochi wrote:
> The polarity and trigger are programmed in iosapic when MADT
> parsing is done, so we don't want to force 'ACPI_ACTIVE_LOW,
> ACPI_LEVEL_SENSITIVE' when SCI is enabled.

Yup, I just completely threw out the MADT parsing, which was
a mistake.  Obviously we have to keep track of what's there.
It's a shame it's currently all in architecture code, even though
it should really be platform-independent.

> So maybe acpi_register_gsi() would take only one argument (u32 gsi)
> and the acpi_register_gsi() by itself will derive polarity and trigger
> from override table or iosapic_intr_info[]?

But it doesn't seem right to me to for the arch code to have to keep
track of the polarity/trigger stuff.  Ideally I think ACPI should extract
that from the PRT (as it does today) and from the static tables (as
the arch code does today), then tell the arch code once via
acpi_register_gsi().

But in the short term, I think I'll just leave the non-PRT stuff pretty
much as it is today, and focus on cleaning up the PRT handling a bit.
