From: Andrew Morton <akpm@osdl.org>
Date: Thu, 07 Sep 2006 23:42:07 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060907164207.16745087.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
	<Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
	<44FFF1A0.2060907@openvz.org>
	<Pine.LNX.4.64.0609070816170.27779@g5.osdl.org>
	<20060907200713.GB541@1wt.eu>
In-Reply-To: <20060907200713.GB541@1wt.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Willy Tarreau <w@1wt.eu>
Cc: Linus Torvalds <torvalds@osdl.org>, Kirill Korotaev <dev@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Thu, 7 Sep 2006 22:07:14 +0200
Willy Tarreau <w@1wt.eu> wrote:

> On Thu, Sep 07, 2006 at 08:17:04AM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Thu, 7 Sep 2006, Kirill Korotaev wrote:
> > > 
> > > Does the patch below looks better?
> > 
> > Yes. 
> > 
> > Apart from the whitespace corruption, that is.
> > 
> > I don't know how to get mozilla to not screw up whitespace.

Me either.  I've had a bug report in the mozilla system for maybe four
years concerning space-stuffing.  Occasionally it comes to life but afaict
nothing ever changes.

I expect it'd be pretty easy to undo the space-stuffing in git. 
In extremis I just do s/^  /^ / and it works.  An automated solution would
need to recognise the appropriate headers (Format=Flowed, iirc).

> maybe by using it to download mutt or something saner ? :-)
> 
> More seriously, while we don't like email attachments because they make
> it impossible to comment on a patch, maybe we should encourage people
> with broken mailers to post small patches in both forms :
>   - pure text for human review (spaces are not much of a problem here)
>   - MIME to apply the patch.

argh.  That means that email contains two copies of the patch.  So it
applies with `patch --dry-run' then causes havoc with `patch'


