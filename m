From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 05 Aug 2003 01:15:58 +0000
Subject: Re: [PATCH] sn2 module (& other misc.) fixes
Message-Id: <marc-linux-ia64-106004619028816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106003174416756@msgid-missing>
In-Reply-To: <marc-linux-ia64-106003174416756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 06:01:42PM -0700, David Mosberger wrote:
> >>>>> On Mon, 4 Aug 2003 17:06:31 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> On Mon, Aug 04, 2003 at 04:31:32PM -0700, David Mosberger
>   Jesse> wrote:
>   >> >>>>> On Mon, 4 Aug 2003 14:14:04 -0700, jbarnes@sgi.com (Jesse
>   >> Barnes) said:
> 
>   Jesse> This one goes on top of the one I sent you last week.  I'm
>   Jesse> shooting for making Linus' tree boot on sn2 as well...
>   >>  This one didn't apply for me.  I just updated the to-linus-2.5
>   >> tree.  Can you rediff against that?
> 
>   Jesse> Sure, does this one work for you?
> 
> Yes, this one worked.  It's in my tree now.

Cool!  Now I only have to apply a couple of patches (one being the
discontig patch) to get the 2.6 tree booting on sn2.
 
What needs to be done to fix the assembler?  It always spews a bunch of
warnings during the build.  The ia64 build would be really quiet if that
was fixed...

Thanks,
Jesse
