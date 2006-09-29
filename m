From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 29 Sep 2006 18:01:10 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <20060929180110.GA4021@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14425.1159496284@kao2.melbourne.sgi.com> <200609291057.41529.bjorn.helgaas@hp.com>
In-Reply-To: <200609291057.41529.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Keith Owens <kaos@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Sep 29, 2006 at 10:57:41AM -0600, Bjorn Helgaas wrote:
>   acpi_parse_fadt: acpi_kbd_controller_present 0

The logic in the kernel seems backwards here though.  We start
by assuming there is a keyboard, then when parsing the FADT
we reset this assumption if the BAF_8042_KEYBOARD_CONTROLLER
bit isn't set.  Which in turn forced SGI to include some
workaround code for their older PROM (which doesn't provide
the FADT table).

There's also a risk that if some code might get added that
runs before we parse FADT that could be confused into thinking
that the keyboard is present.

Wouldn't it be simpler/better to assume there is no keyboard until
we find positive evidence that there is one?

-Tony
