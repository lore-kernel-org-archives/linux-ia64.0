From: Keith Owens <kaos@sgi.com>
Date: Fri, 10 Nov 2006 04:23:20 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <14134.1163132600@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 26 Sep 2006 13:54:30 CST."
             <200609261354.30722.bjorn.helgaas@hp.com> 
References: <200609261354.30722.bjorn.helgaas@hp.com>
In-Reply-To: <200609261354.30722.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Bjorn Helgaas (on Tue, 26 Sep 2006 13:54:30 -0600) wrote:
>get_kbd_char() in arch/ia64/kdb/kdba_io.c does "inb(KBD_STATUS_REG)".
>
>But we don't know whether there's even an i8042 keyboard controller
>present.  On HP ia64 boxes, there is no i8042, and trying to read
>from it can cause an MCA.
>
>This depends on the specific platform and how it is configured.  I
>observed this MCA while booting the SLES10 install kernel on an
>HP rx7620 in "default" acpiconfig mode.  The supported acpiconfig
>mode on this box is "single-pci-domain", which also puts some
>legacy ports into "soft-fail" mode, where the read will just return
>0xff instead of causing an MCA.  But I think it's wrong to blindly
>poke around in I/O port space.

Bjron, could you try kdb-v4.4-2.6.19-rc5-{common,ia64}-2 on your
problem system?  I changed kdb so it only uses the keyboard if at least
one console matches the pattern /^tty[0-9]*$/.  IOW, if the user
specifies an i8042 style console on the command line (or uses the
default with CONFIG_VT=y) then kdb will attempt to use that keyboard.
Otherwise kdb ignores a VT style console, even when the kernel is
compiled with CONFIG_VT=y.

