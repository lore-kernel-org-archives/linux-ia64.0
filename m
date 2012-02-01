From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 20:53:40 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328129620.15992.6453.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <1328116137.15992.6146.camel@triegel.csb>
	 <CA+55aFyG3EifFPapU6SFYXCjrP+wQOF65hJGs3yyMxCgde5vdg@mail.gmail.com>
In-Reply-To: <CA+55aFyG3EifFPapU6SFYXCjrP+wQOF65hJGs3yyMxCgde5vdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 09:29 -0800, Linus Torvalds wrote:
> On Wed, Feb 1, 2012 at 9:08 AM, Torvald Riegel <triegel@redhat.com> wrote:
> >
> > What do the kernel folks think about the C11 memory model?  If you can
> > spot any issues in there, the GCC community would certainly like to
> > know.
> 
> I don't think this is about memory models except very tangentially.
> 
> Gcc currently accesses fields in a way that affects *independent*
> fields, without checking their memory models at all.
> 
> Even original C already has one memory model: "volatile" data is seen
> outside the virtual C machine. And Jiri reports that even that
> *original* memory model is being violated. We're taling about the one
> from about 40 years ago.

For volatile, I agree.

However, the original btrfs example was *without* a volatile, and that's
why I raised the memory model point.  This triggered an error in a
concurrent execution, so that's memory model land, at least in C
language standard.

The example was a granularity-of-access violation, I agree.
Nonetheless, C11 has rules for that, they have been written down, it
would good to know whether these rules are sufficient for you.

> We do end up doing
> much more aggressive threading, with models that C11 simply doesn't
> cover.

Any specific examples for that would be interesting.


