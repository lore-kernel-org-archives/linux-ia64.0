From: Andrew Morton <akpm@osdl.org>
Date: Sun, 29 Feb 2004 05:27:42 +0000
Subject: Re: Oops in pdflush
Message-Id: <20040228212742.60041983.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>
> On Sat, 28 Feb 2004 02:23:23 -0800, 
> Andrew Morton <akpm@osdl.org> wrote:
> >We should use the new kthread infrastructure rather than open-coding it. 
> >It delegates thread startup to keventd and should thus avoid the stack
> >windup.
> 
> Convert pdflush to kthread to avoid stack windup.

Thanks Keith.  Tricky patch ;)

> Rusty, does pdflush() still need to call daemonize() or does kthread
> make that redundant?

It's redundant - threads launched by kthread have a genuine kernel thread
as a parent and hence do not need to perform all that "disassociate me from
my userspace parent" stuff.

