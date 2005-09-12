From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Sep 2005 03:19:37 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509112014210.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 12 Sep 2005, Keith Owens wrote:

> On Sun, 11 Sep 2005 15:56:28 -0700 (PDT), 
> Linus Torvalds <torvalds@osdl.org> wrote:
> >
> >What's going on? Why would machine check interrupts muck with these 
> >things? Pls explain.. This is a total violation of all layering, and 
> >anybody who uses these things is just going to cause strange oopses etc 
> >crap.
> >
> >Wazzup?
> 
> http://lkml.org/lkml/2005/9/8/315/.

That doesn't explain anything that I can't see in the code.

So let me repeat the question: why the hell does a MCA muck with global 
(and very core) kernel state? Why doesn't it just set perfectly normal 
internal ia64 state? 

The fact that it uses a separate stack is _not_ an explanation. That's 
just throwing words around. Everybody uses a separate stack. x86 does it 
for every single interrupt. That doesn't make x86 change global scheduler 
state.

ia64 is doing something WRONG. Stop it. Or give me a real explanation of
what the f*ck ia64 is doing that makes it want to modify core scheduler
data structures from the machine check handler. It has _no_ business doing 
that.

ia64 does have a perfectly fine pointer to "current": it's the ia64 TP 
register. So change _that_ instead, and if there's some silly unwinder 
that depends on global state, fix it.

			Linus
