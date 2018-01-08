From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 08 Jan 2018 02:09:42 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180108020942.GB533@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
 <20180105102105.GB471@jagdpanzerIV>
 <20180105102538.GC471@jagdpanzerIV>
 <20180105144239.i3pc6npgmoi4ddln@pathway.suse.cz>
In-Reply-To: <20180105144239.i3pc6npgmoi4ddln@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (01/05/18 15:42), Petr Mladek wrote:
> 
> I am all for it. But I would postpone this removal to 4.17.
> The reason is rather ugly. 13th patch is already in arc tree.
> We would need to shuffle the patch or coordinate pull requests.

JFI, the patch is in Linus's tree as of now (d0729bc6bee797fb).

	-ss
