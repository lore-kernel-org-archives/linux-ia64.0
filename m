From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Fri, 05 Jan 2018 10:21:05 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105102105.GB471@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
In-Reply-To: <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (01/05/18 11:03), Petr Mladek wrote:
[..]
> Anyway, print_symbol() is an old weird API and it would be nice
> to eventually get rid of it. I could take this patches into
> printk.git.

no objections from my side if the patch set will go through the printk tree.
shall we wait for ACKs or can we move on? do you plan to land it in 4.16?

> Would you mind if I change the commit messages to something like?:
> 
>     print_symbol() is an old weird API. It has been
>     obsoleted by printk() and %pS format specifier.

I wouldn't. let's drop the "weird" part. other than that looks
good to me.

	-ss
