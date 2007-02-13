From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 13 Feb 2007 22:21:12 +0000
Subject: Re: 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <p737iulhcfb.fsf@bingen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070213184839.GC10031@frankl.hpl.hp.com>
	<20070213140533.a5ca27ad.akpm@linux-foundation.org>
In-Reply-To: <20070213140533.a5ca27ad.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: eranian@hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net

Andrew Morton <akpm@linux-foundation.org> writes:

> > On Tue, 13 Feb 2007 10:48:39 -0800 Stephane Eranian <eranian@hpl.hp.com> wrote:
> > I have released another version of the perfmon new code base package.
> 
> Can we have a bug push to get this merged up please?

Yes, there certainly seems to be user interest in this.

I've been merging the x86 specific infrastructure Stephane sent.
So hopefully the basics are there already.

The big open question was still the review of the syscall interface.
Probably needs some determined reviewers.

I did a review of some of the basic low level code some time ago;
there were some issues but I believe they are probably all resolved
by now (but I haven't verified that recently) 

-Andi
