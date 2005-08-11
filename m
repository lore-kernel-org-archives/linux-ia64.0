From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 11 Aug 2005 15:14:27 +0000
Subject: Re: [PATCH] update CONFIG_PCI description
Message-Id: <20050811151427.GC28067@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809203800.GA28917@lst.de>
In-Reply-To: <20050809203800.GA28917@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 09, 2005 at 10:38:00PM +0200, Christoph Hellwig wrote:
> The current one doesn't even make sense anymore on i386 where it
> apparently came from.
> +	  There is no IA64 hardware without PCI/PCI-X/PCI-Express busses.
> +	  Say Y here unless running on the HP simulator.
>  

Hm, I thought I already updated that one.  I think it's bad style to write
in the negative like that ... how about:

	All IA-64 machines use PCI/PCI-X/PCI Express busses.  Unless you
	are using a simulator without PCI support, you should say Y here.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
