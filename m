From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 10 Nov 2006 04:28:03 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <20061110042803.GU16952@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609261354.30722.bjorn.helgaas@hp.com> <14134.1163132600@kao2.melbourne.sgi.com>
In-Reply-To: <14134.1163132600@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Nov 10, 2006 at 03:23:20PM +1100, Keith Owens wrote:
> Bjron, could you try kdb-v4.4-2.6.19-rc5-{common,ia64}-2 on your
> problem system?  I changed kdb so it only uses the keyboard if at least
> one console matches the pattern /^tty[0-9]*$/.  IOW, if the user
> specifies an i8042 style console on the command line (or uses the
> default with CONFIG_VT=y) then kdb will attempt to use that keyboard.
> Otherwise kdb ignores a VT style console, even when the kernel is
> compiled with CONFIG_VT=y.

If I'm using an HP Integrity system with a USB keyboard, won't I still
have a console that matches ^tty[0-9]*$ ?
