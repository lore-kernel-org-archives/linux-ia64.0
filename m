From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 14 Jan 2002 23:36:53 +0000
Subject: Re: [Linux-ia64] ACPI power button events
Message-Id: <marc-linux-ia64-105590698805824@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805822@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805822@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" wrote:
> 
> Hi,
> 
> On Mon, 14 Jan 2002 15:01:24 -0800
> Michael Madore <mmadore@turbolinux.com> wrote:
> 
> > Hi,
> >
> > Is pressing the power button on a Big Sur workstation supposed to write
> > anything to /proc/acpi/event?  It doesn't seem to on my system.
> 
> I tested the same and got the same result.
> I suppose BigSur doesn't support the button feature in its
> firmware.
> 
> If it does, you should see "ACPI: Power Button (FF) found" in
> boot message and you will see a /proc/acpi/button directory.

Yes, I see this message upon boot, and the /proc/acpi/button directory
is created.

> If the button event is properly processed, you can see
> "button power 00000080 00000000"
> line when you cat /proc/acpi/event.

Nothing seems to get written to the event file.

Mike

