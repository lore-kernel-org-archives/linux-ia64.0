From: Keith Owens <kaos@sgi.com>
Date: Fri, 29 Sep 2006 02:18:04 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <14425.1159496284@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Wed, 27 Sep 2006 16:11:00 CST."
             <200609271611.00701.bjorn.helgaas@hp.com> 
References: <200609261354.30722.bjorn.helgaas@hp.com>
In-Reply-To: <200609261354.30722.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Bjorn Helgaas (on Wed, 27 Sep 2006 16:11:00 -0600) wrote:
>On Tuesday 26 September 2006 20:45, Keith Owens wrote:
>> No support for legacy I/O ports could be a bigger problem than just
>> KDB.
>
>On Itanium (and I suppose on x86), ACPI theoretically tells us enough
>that we don't need to assume any legacy resources.  Of course, Linux
>doesn't listen to everything ACPI is trying to tell it.  But that's
>a Linux deficiency we should remedy.
>
>> To fix just KDB, apply this patch over kdb-v4.4-2.6.18-common-1 and
>> add 'kdb_skip_keyboard' to the boot command line on the offending
>> hardware. 
>
>This doesn't feel like the right solution.  Since firmware tells us
>whether the device is present, I think we should rely on that.  If
>you want to use the device before ACPI is initialized, *then* you
>should pass a "kdb_use_keyboard" sort of flag.

I have never been a big fan of ACPI, having seen too many broken ACPI
tables.  But if that is what you want ...

Bjorn, could you apply my previous patch anyway, boot your problem
system with kdb_skip_keyboard, drop into KDB and
'md4c1 acpi_kbd_controller_present'.  That will quickly confirm if acpi
is detecting the absence of the keyboard on your system.

