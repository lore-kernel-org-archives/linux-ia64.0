From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 14 Mar 2006 22:25:53 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060314222553.GX1653@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <20060314215922.GA12257@suse.de>
In-Reply-To: <20060314215922.GA12257@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, maule@sgi.com

On Tue, Mar 14, 2006 at 01:59:22PM -0800, Greg KH wrote:
> Ugh.  What is the file that is causing the problem?  What is "include2"
> in your directory path above?

you get include2 when you specify a different object directory:

$ ls obj
Makefile        arch    drivers  include2  kernel  net       sound
Module.symvers  block   fs       init      lib     scripts   usr
System.map      crypto  include  ipc       mm      security  vmlinux

