From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 23:37:44 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436052530373@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 16:15:29 -0700
Andrew Morton <akpm@osdl.org> wrote:

> "David S. Miller" <davem@redhat.com> wrote:
> >
> > > That's not true; they could be avoided by using get_unaligned() and
> >  > put_unaligned().  You just don't want to because they'd make sparc suck.
> > 
> >  Not only sparc would be effected by this.  Using {get,put}_unaligned()
> >  all over the networking would incur a penalty for many platforms, not
> >  just sparc.
> 
> Really?  I'd have thought that get/put_unaligned would be a simple
> load/store for architectures which wish to implement it in that manner.

Only on systems that have the "load upper/lower-unaligned"
instructions.  On others it's a memmove().
