From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 01 May 2004 13:03:13 +0000
Subject: Re: cr.gpta register
Message-Id: <20040501130313.GA8984@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040426123437.GA6567@cse.unsw.EDU.AU>
In-Reply-To: <20040426123437.GA6567@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Amen to that :)  (But thanks for the info Jim, that was sufficient to
answer my question.)

In the meantime I've started to document some of the info I've learned
so far in our Gelato wiki.  This is currently focused on instruction
scheduling, since that's what I was most interested in understanding,
but I'm also interested in collating info on other useful implementation
details [1].

Hopefully other people might find this useful and add to it.

http://www.gelato.unsw.edu.au/IA64wiki/ItaniumInternals

Matt


[1] Something I'd be particularly interested in is details of cache
and TLB replacement algorithms.  (NRU is hardly specific.)


On Fri, Apr 30, 2004 at 04:04:16PM -0700, Chris Wedgwood wrote:
> On Fri, Apr 30, 2004 at 10:36:32AM -0700, Jim Hull wrote:
> 
> > GPTA (CR9) exists solely to support the IA-32 System Environment
> > (see PAL_ENTER_IA_32_ENV in SDM Volume 2, Chapter 11).  All details
> > concerning the format and operation of this register are considered
> > Intel Restricted.
> 
> This is the case with some of the MCE stuff means figuring out various
> things took way longer than it should have.
> 
> I really wish someone would talk Intel into documenting things a bit
> more.
> 
> 
>   --cw
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
