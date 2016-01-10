From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 19:29:06 +0000
Subject: Re: [PATCH v2 1/3] checkpatch.pl: add missing memory barriers
Message-Id: <20160110212531-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452427000-4520-1-git-send-email-mst@redhat.com>
 <1452427000-4520-2-git-send-email-mst@redhat.com>
 <1452438425.7773.21.camel@perches.com>
 <1452439051.7773.27.camel@perches.com>
In-Reply-To: <1452439051.7773.27.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Tony

On Sun, Jan 10, 2016 at 07:17:31AM -0800, Joe Perches wrote:
> On Sun, 2016-01-10 at 07:07 -0800, Joe Perches wrote:
> > On Sun, 2016-01-10 at 13:56 +0200, Michael S. Tsirkin wrote:
> > > SMP-only barriers were missing in checkpatch.pl
> > > 
> > > Refactor code slightly to make adding more variants easier.
> > []
> > > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
> > If I use a variable called $smp_barriers, I'd expect
> > it to actually be the smp_barriers, not to have to
> > prefix it with smp_ before using it.
> > 
> > 		my $smp_barriers = qr{
> > 			smp_store_release|
> > 			smp_load_acquire|
> > 			smp_store_mb|
> > 			smp_read_barrier_depends
> 
> That's missing (?:barriers) too.

My version has it but need to add ?: to avoid
a capture group.

> btw: shouldn't this also have
> 	smp_mb__(?:before|after)_atomic
> ?

Good catch, included in the next version.

-- 
MST
