From: Mark Haverkamp <markh@osdl.org>
Date: Thu, 17 Jun 2004 19:36:54 +0000
Subject: Re: sys_ioctl export
Message-Id: <1087501014.31099.2.camel@markh1.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-06-17 at 12:27, Grant Grundler wrote:
> On Thu, Jun 17, 2004 at 11:50:36AM -0700, David Mosberger wrote:
> >   Andi> I would suggest to export it on IA64 too or everywhere.
> > 
> > Why not export it everywhere then?  It seems strange to allow it to be
> > called from modules on 64-bit platforms but not 32-bit platforms.
> 
> only 64-bit arches need to translate for 32-bit apps making sys_ioctl calls?

I believe that this is true.

> 
> But exporting it for everyone would work too.

Wouldn't there be some reluctance to export a symbol to everyone when it
is only used for a special purpose?

> 
> grant

Mark.
-- 
Mark Haverkamp <markh@osdl.org>

