From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Mon, 02 Jun 2003 18:23:51 +0000
Subject: RE: [Linux-ia64] Re: trailing white space...
Message-Id: <marc-linux-ia64-105590723706111@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706105@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706105@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Emacs users can (and should!)  consider:
> > 
> > 	(setq show-trailing-whitespace t)
> 
> Anything similar for vi and gvim?

:set list

but in either case this just shows you
the stuff, it doesn't remove it.
If it's a persistent problem, a simple
filter is easier to use.  I find Python's
rstrip string method useful for this,
i.e. if you have a line of text in 'line',

    line = line.rstrip()

saves a new copy of the line with the
trailing whitespace removed.


