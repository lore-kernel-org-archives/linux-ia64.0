From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Fri, 05 Jan 2018 14:57:15 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105145715.GA409@tigerII.localdomain>
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
[..]
> > oh, one more thing. one extra patch, which gets rid of
> > print_symbol()/__print_symbol().
> 
> I am all for it. But I would postpone this removal to 4.17.
> The reason is rather ugly. 13th patch is already in arc tree.
> We would need to shuffle the patch or coordinate pull requests.
> I think that it is not worth it. There is no real hurry.
> I doubt that the would be any new user in the meantime.
> 
> Best Regards,
> Petr
> 
> PS: I have just pushed 12 patches into printk.git for-4.16 branch.
> I will merge this to linux-next branch on Monday. I will not
> be around the computer over the weekend...

OK. thanks!

	-ss
