From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 11 Nov 2003 03:20:06 +0000
Subject: Re: [PATCH] fix 256 node machines by increasing NODES_SHIFT value
Message-Id: <marc-linux-ia64-106852087001745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106797223026432@msgid-missing>
In-Reply-To: <marc-linux-ia64-106797223026432@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 10, 2003 at 06:01:53PM -0800, David Mosberger wrote:
> >>>>> On Tue, 4 Nov 2003 10:56:19 -0800, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> We need 8 bits for the NODE_SHIFT otherwise 256 node systems
>   Jesse> fail in weird ways.
> 
> I think I'm going to push back on this one since Linus wants to limit
> patches to stuff that affects (relatively) large number of folks, and
> I don't think there are more than a handful of >256 node systems out
> there (in fact, I've heard only of one).  Otherwise, I'm OK with the
> patch, so we should include it in 2.6.1.  Please retransmit after
> 2.6.1 is out.
> 
> Ditto for Jack's patch.
> 
> OK?

Yep, no problem.  Just posting it for comments more than anything else.

Jesse
