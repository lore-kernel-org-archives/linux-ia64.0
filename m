From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 29 Sep 2006 16:57:41 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <200609291057.41529.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14425.1159496284@kao2.melbourne.sgi.com>
In-Reply-To: <14425.1159496284@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday 28 September 2006 20:18, Keith Owens wrote:
> I have never been a big fan of ACPI, having seen too many broken ACPI
> tables.  But if that is what you want ...

There's always broken firmware, but I think on the whole, it's better
than just assuming that tomorrow's system will be the same as yesterday's.
I think a big reason for broken tables is the fact that ignore many of
them, so the breakage is never discovered.

> Bjorn, could you apply my previous patch anyway, boot your problem
> system with kdb_skip_keyboard, drop into KDB and
> 'md4c1 acpi_kbd_controller_present'.  That will quickly confirm if acpi
> is detecting the absence of the keyboard on your system.

My system says:

  acpi_parse_fadt: acpi_kbd_controller_present 0
