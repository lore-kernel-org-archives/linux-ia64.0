From: Matthew Wilcox <willy@debian.org>
Date: Tue, 02 Mar 2004 16:00:08 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040302160008.GJ25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 01, 2004 at 05:30:18PM -0800, David Mosberger wrote:
> >>>>> On Mon, 1 Mar 2004 16:05:32 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> This patch reorganises sal.c and adds a small amount of new
>   Matthew> functionality.
> 
> The patch breaks UP kernels because SMP_IRQ_REDIRECTION and SMP_IPI_REDIRECTION
> aren't defined for UP kernels.

Ack, sorry.  I'll change them to #defines.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
