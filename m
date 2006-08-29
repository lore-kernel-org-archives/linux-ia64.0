From: Greg KH <gregkh@suse.de>
Date: Tue, 29 Aug 2006 16:08:41 +0000
Subject: Re: [stable] [PATCH] Linux 2.6.17.11 - fix compilation error on IA64 (try #3)
Message-Id: <20060829160841.GB9078@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A72869D@scsmsx411.amr.corp.intel.com> <20060829013137.GA27869@kroah.com> <44F431F5.7020703@sw.ru>
In-Reply-To: <44F431F5.7020703@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@sw.ru>
Cc: Greg KH <greg@kroah.com>, "Luck, Tony" <tony.luck@intel.com>, Fernando Vazquez <fernando@oss.ntt.co.jp>, akpm@osdl.org, dev@openvz.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net, stable@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org

On Tue, Aug 29, 2006 at 04:24:21PM +0400, Kirill Korotaev wrote:
> Probably it is my fault, since I thought that patches which got into -stable
> automatically go into Linus tree.

No they do not.  Usually it's the requirement that they be in his tree
first, but I didn't think it was necessary this time due to my
misunderstanding about the fix.

thanks,

greg k-h
