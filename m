From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 07 Nov 2004 14:43:15 +0000
Subject: Re: [ACPI] A GPE block driver
Message-Id: <20041107144315.GC23303@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041106064442.GA21423@parcelfarce.linux.theplanet.co.uk> <20041106074900.GA29632@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041106074900.GA29632@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

On Sat, Nov 06, 2004 at 07:49:00AM +0000, Matthew Wilcox wrote:
> Here's the driver.  I can't actually test it until someone goes into
> the server room to push a button on the machine.
> 
> I do suspect there to be a problem though.  I get the message:
> GSI 120 (level, low) -> CPU 3 (0x0c02) vector 63
> but there is no entry in /proc/interrupts for vector 63.  I think the
> right thing to do would be to add a request_irq() somewhere in the
> acpi_install_gpe_block() call path.  FADT GPE blocks don't need this --
> they use the sci_irq.  But other blocks can use their own IRQ.

OK, the problem was more detailed and subtle than that.  osl.c assumes
there will be only one interrupt, which is not true in the presence of
GPE blocks.  So I rewrote the interrupt handler.  I'll send two follow-up
mails to this; the first will be the changes I propose for the ACPI core
and the second will be the new GPE block driver which has several bugs fixed
over the one I posted yesterday.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
