From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 20 Jan 2004 17:11:02 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <200401201011.02896.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 January 2004 5:45 pm, Matthew Wilcox wrote:
> >  config 64BIT
> > -	def_bool y
> > +	bool
> > +	default y
> 
> Why make this change?  def_bool is shorter and (to my mind ;-) neater.

It could have gone either way; I just wanted to make all those items
consistent.  It seemed like there were five or six "bool/default y" and
only one "def_bool", and def_bool wasn't actually documented, so it lost.

