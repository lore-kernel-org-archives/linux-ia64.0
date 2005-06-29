From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 29 Jun 2005 21:17:07 +0000
Subject: Re: problem booting -mm2 kernel on rx2600
Message-Id: <200506291517.07088.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 29 June 2005 3:08 pm, Luck, Tony wrote:
> >No.  Current upstream + the patch you mention boots fine for me no
> >zx2000, both with "console=ttyS0" and with no "console=" argument
> >at all.
> >
> >How does it fail for you?
> 
> It just hangs after the "uncompressing" message.  But when I added
> 
> 	console=uart,mmio,0xff5e0000
> 
> to see what was going on, it came all the way up!!!

What "console=" argument do you normally use?  What is your
EFI console configuration (particularly ConOut)?

IIUC, your kernel works fine without Mark's patch, and fails
with it.  Right?

Documentation/ia64/serial.txt has some troubleshooting hints,
but I didn't expect Mark's patch to make a difference in this
area.
