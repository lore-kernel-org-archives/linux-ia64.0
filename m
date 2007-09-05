From: Jes Sorensen <jes@sgi.com>
Date: Wed, 05 Sep 2007 13:35:45 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be
Message-Id: <46DEB0B1.2040402@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Natalie Protasevich wrote:
> On 03 Sep 2007 05:21:41 -0400, Jes Sorensen <jes@sgi.com> wrote:
> The boot option is only temporary, until the SAL/PAL mechanism will be
> shaken up.
> I will digest and use the machvec then, how about that? For now I'd
> like to provide this revived patch as is  for it is proven to be
> working in the past, if you don't mind this first stage.

Hi Natalie,

If the boot option is meant as a temporary measure, then I am game for
it. However I still think it's better to make the boot option decide on
a machine vector rather than doing this as a hack the way it is now.
How about a machvec=dignoptcg option instead? That way once the SAL
interface becomes available, you simply make the SAL call and pick the
machine vector based on that.

>> Who are these large system vendors who want this patch in? I presume
>> it's not the people running gmail? :-)
> 
> No :) those interested are big hardware makers of large scaled out
> boxes, such as HP, UIS. They are using own asics and are not
> necessarily being able to keep chipset native capabilities intact. As
> I said in the preamble, the mechanism has to be there so they can turn
> the ptc.g off and run the OS.

But those vendors only make small boxes :-) SGI has had this isusue from
day one, but we have other things that are non standard too, which is
one of the reasons the machine vectors came into play in the first
place.

So IMHO I think the best solution would still be to introduce a new
machine vector - this will avoid adding code to the current
global_tlb_purge() function and allow you to do an optimized version for
the new systems too.

Cheers,
Jes

