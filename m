From: Grant Grundler <iod00d@hp.com>
Date: Mon, 28 Feb 2005 18:50:26 +0000
Subject: Re: Badness in iosapic_unregister_intr
Message-Id: <20050228185026.GD27433@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 28, 2005 at 06:06:00PM +0000, Matthew Wilcox wrote:
> 
> Not sure where the problem lies on this one ...
> 
> On an hp rx4640, at shutdown of an unmodified 2.6.11-rc5 kernel, I get:
> 
> Rebooting... ACPI: PCI interrupt for device 0000:a1:04.0 disabled
> iosapic_unregister_intr(4294967295) unbalanced

4294967295 can't be a valid GSI.
Need a stack trace to see who is calling iosapic_unregister_intr.

grant
