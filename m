From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 15 Mar 2005 16:24:56 +0000
Subject: Re: Export pda_percpu?
Message-Id: <200503150824.56845.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, March 15, 2005 7:37 am, Jack Steiner wrote:
> On Mon, Mar 14, 2005 at 08:44:10PM -0800, Christoph Lameter wrote:
> > In order for mmtimer to properly build as a module, it seems that we need
> > access to the pda structure. This has been discussed before
> > http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg00472.html
> > and was rejected. What else can I do? Define functions as suggested? Do
> > these exist somewhere?
>
> What fields from the pda do you need? I think we need to eliminate the pda.
> The pda made sense in the 2.4 kernels but not in 2.6.
>
> Some of the fields were recently removed as part of a SHUB2 patch.
> The rest should be eliminated or moved.

You can also create accessor functions for the fields you need and export them 
instead.  I'd rather get rid of the PDA though.

Jesse
