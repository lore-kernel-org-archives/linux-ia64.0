From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 11 Mar 2005 20:25:26 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <20050311202526.GS21986@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Mar 11, 2005 at 11:40:04AM -0700, Bob Montgomery wrote:
> argument registers and some of the locals for each function leading
> to the oops.  Note: this doesn't capture function arguments per se,

I've been wanting this for a while.  I think it'd be *very* useful.

> The current vs. proposed is shown below.  Thanks for any comments
> and advice.

I know your patch leaaves this unchanged, but I don't think it's helpful
to show the 'show_stack' and 'show_regs' frames.  Can we get rid of them,
or is there a reason they're useful?

> Call Trace:
>  [<a000000100012940>] show_stack+0x80/0xa0
>                                 sp=E0000001200df960 bsp=E0000001200d8fb8
>  [<a0000001000131c0>] show_regs+0x800/0x820
>                                 sp=E0000001200dfb30 bsp=E0000001200d8f60
>     r32 : e0000001200dfc50 r33 : 0000000000000000 r34 : e0000001200dfd08
>     r35 : e0000001200dfcc8 r36 : e0000001200dfce0 r37 : e0000001200dfca0
>     r38 : e0000001200dfc90 r39 : 00000fffffffbfff r40 : a000000100036b50
>     r41 : 000000000000040e r42 : e0000001a00dfbce
>  [<a000000100036b50>] die+0x150/0x280
>                                 sp=E0000001200dfb40 bsp=E0000001200d8f20
>     r32 : e0000001200dfbd0 r33 : e0000001200dfc50 r34 : 0000020200000010
>     r35 : a00000010066a1b8 r36 : a00000010066a1bc r37 : a000000100036cc0
>     r38 : 0000000000000309 r39 : a00000010056ebe8

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
