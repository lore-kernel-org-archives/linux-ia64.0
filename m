From: Matthew Wilcox <willy@debian.org>
Date: Wed, 15 Oct 2003 17:20:09 +0000
Subject: Re: [PATCH] fix serial port naming
Message-Id: <marc-linux-ia64-106623858629708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106623720527866@msgid-missing>
In-Reply-To: <marc-linux-ia64-106623720527866@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 10:54:36AM -0600, Bjorn Helgaas wrote:
> This also fixes a long-standing serial device naming issue:
> ttyS0-ttyS3 were always reserved for the compiled-in
> COM ports, even if they weren't present in the box.
> Any additional PCI or ACPI ports appeared starting at
> ttyS4 (except for the special case of things described
> in the HCDP).   Now we'll just name ttyS devices in the
> order they're discovered, without any holes for non-existent
> devices.

Oh good; this was even worse on 2.6 where we would number the two serial
ports on a zx2000 ttyS0 and ttyS14.  That caused me much crawling about
on the floor with serial cables until I realised I'd pointed minicom at
ttyS1 which wasn't there any more.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
