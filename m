From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 31 Jul 2003 03:54:02 +0000
Subject: Re: serial legacy ports and ACPI
Message-Id: <marc-linux-ia64-105962365319200@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105761215001812@msgid-missing>
In-Reply-To: <marc-linux-ia64-105761215001812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Bjorn> I like the idea of this, but 1) You might pass it by the ACPI
Bjorn> folks to make sure this is the intent of the spec (sure looks
Bjorn> reasonable to me, though).  2) I don't really like the
Bjorn> implementation in the sense that a) The spec suggests that
Bjorn> LEGACY_DEVICES might also cover things other than serial ports,
Bjorn> i.e., a legacy LPT port, so: b) I think the check should go in
Bjorn> arch/.../acpi.c.  We did something similar for keyboard
Bjorn> detection (see acpi_kbd_controller_present), and I think it
Bjorn> worked out pretty well.

Hi Bjorn,

I had a chat with Grant and Matthew about is a little while ago (and
possibly a few other people whom I can't remember right now) and we
basically came to a similar conclusion. Once I find a bit more time,
I'd like to introduce an interface along the lines of

        legacy_device_present(LEGACY_{IDE,SERIAL,PARALLEL})

This could be quite useful for other architectures as well I believe.

Cheers,
Jes
