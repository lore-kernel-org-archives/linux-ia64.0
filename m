From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 05:52:09 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602080552.k185q9g07813@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060208035112.GM3524@stusta.de>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Adrian Bunk' <bunk@stusta.de>
Cc: 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> > > >You patch does more than what you described and is wrong.  Selecting
> > > >platform type should not be tied into selecting SMP nor should it tied
> >...
> > I'm not disagreeing with the SMP bit.  In my very first reply, I
> >...
> 
> It might be related to the fact that I'm not a native English speaker, 
> but for me this reads as if you contradict yourself, and I have 
> therefore problems understanding your emails.

Yeah, I've been flip-flopping on CONFIG_SMP.  I just don't have strong
opinion one way or the other. Having said that, I don't think we should
mix the CONFIG_IA64_GENERIC, which is defined to select platform type
with smp/processor type etc.

But for the bit that this thread started, which disables CONFIG_MCKINLEY
for CONFIG_IA64_GENERIC, it is totally wrong and is the "over my dead
body" type of thing.

- Ken

