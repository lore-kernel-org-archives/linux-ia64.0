From: Petr Mladek <pmladek@suse.com>
Date: Fri, 05 Jan 2018 14:42:39 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105144239.i3pc6npgmoi4ddln@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
 <20180105102105.GB471@jagdpanzerIV>
 <20180105102538.GC471@jagdpanzerIV>
In-Reply-To: <20180105102538.GC471@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Fri 2018-01-05 19:25:38, Sergey Senozhatsky wrote:
> On (01/05/18 19:21), Sergey Senozhatsky wrote:
> > On (01/05/18 11:03), Petr Mladek wrote:
> > [..]
> > > Anyway, print_symbol() is an old weird API and it would be nice
> > > to eventually get rid of it. I could take this patches into
> > > printk.git.
> > 
> > no objections from my side if the patch set will go through the printk tree.
> > shall we wait for ACKs or can we move on? do you plan to land it in 4.16?
> > 
> > > Would you mind if I change the commit messages to something like?:
> > > 
> > >     print_symbol() is an old weird API. It has been
> > >     obsoleted by printk() and %pS format specifier.
> > 
> > I wouldn't. let's drop the "weird" part. other than that looks
> > good to me.
> 
> oh, one more thing. one extra patch, which gets rid of
> print_symbol()/__print_symbol().

I am all for it. But I would postpone this removal to 4.17.
The reason is rather ugly. 13th patch is already in arc tree.
We would need to shuffle the patch or coordinate pull requests.
I think that it is not worth it. There is no real hurry.
I doubt that the would be any new user in the meantime.

Best Regards,
Petr

PS: I have just pushed 12 patches into printk.git for-4.16 branch.
I will merge this to linux-next branch on Monday. I will not
be around the computer over the weekend...
