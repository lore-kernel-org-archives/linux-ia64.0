From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 25 Jan 2005 21:15:58 +0000
Subject: Re: Questionable code in pci_sal_read
Message-Id: <20050125211558.GY31455@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek6q1o7p2.fsf@sykes.suse.de>
In-Reply-To: <jek6q1o7p2.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 25, 2005 at 12:47:03PM -0800, Luck, Tony wrote:
> So you (and Matthew Wilcox) are advocating this change?
>  
> -	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 4095))
> +	if ((seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))

Yes.

> "seg", "bus", etc. are all "int" ... should we be extra paranoid
> and check for negative values (or change the definitions to unsigned),
> or is that over the top?

I believe Bjorn has a patch to change the pci_raw_ops to use unsigned int.
Best to send that separately though.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
