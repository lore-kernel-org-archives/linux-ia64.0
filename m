From: Andrew Morton <akpm@osdl.org>
Date: Fri, 13 Feb 2004 22:44:04 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <20040213144404.48c12406.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> wrote:
>
> please do a
> 
> 	bk pull http://lia64.bkbits.net/to-linus-2.5

Are these urgent-for-2.6.3 things?

We seem to be converging on a model wherein a new kernel comes out,
everyone pummels Linus with patches for a week, then we have a week of
strict stabilisation and then it repeats.  During the stabilisation week,
everyone is stabilising their next pummeling in external trees.  I think
it's good, and is working well.

This pull request of yours is outside the model ;)

But the model tends to mainly apply to x86: people are used to other
architectures needing additional touchups to work properly.  But it
would be nice if we could fix that up.

