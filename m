From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 16 Jan 2004 17:21:00 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040116172100.GA13553@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040116003224.GF23253@kroah.com> <Pine.LNX.4.58.0401152057380.2631@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401152057380.2631@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Thu, Jan 15, 2004 at 09:00:10PM -0800, Linus Torvalds wrote:
> If you care about machine check errors, use a special interface for that. 
> A _really_ special one. Especially as on many systems you'll likely have 
> to read status registers etc (and clear them before doing the IO) to see 
> the errors.
> 
> So that way you can get errors working, AND it won't actually make normal 
> code any uglier.

How about one that allows you to register an error handling function for
a given address range and/or device?  That would cover both read() and
write() cases, and would be optional so drivers wouldn't be forced to
become more complicated.

Jesse
