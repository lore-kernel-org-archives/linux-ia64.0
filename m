From: Chris Wedgwood <cw@f00f.org>
Date: Mon, 02 Jun 2003 23:16:20 +0000
Subject: Re: [Linux-ia64] Re: trailing white space...
Message-Id: <marc-linux-ia64-105590723706119@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706105@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706105@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 02, 2003 at 11:23:51AM -0700, Wichmann, Mats D wrote:

> but in either case this just shows you
> the stuff, it doesn't remove it.

I think that's how it should be... removing it on existing files w/o
care is bad.

> If it's a persistent problem, a simple
> filter is easier to use.

For new files sure, for existing files I would rather people ensure
hunsk they edit and linees they edit contain no/few whitespace
changes.


> I find Python's rstrip string method useful for this, i.e. if you
> have a line of text in 'line',
> 
>     line = line.rstrip()
> 
> saves a new copy of the line with the
> trailing whitespace removed.

What's wrong with sed?


  --cw

