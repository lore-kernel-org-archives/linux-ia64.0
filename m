From: Andrew Morton <akpm@osdl.org>
Date: Sat, 28 Feb 2004 12:00:34 +0000
Subject: Re: Oops in pdflush
Message-Id: <20040228040034.0326cf29.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Keith Owens <kaos@sgi.com> wrote:
> >
> >  >So if I'm reading this right, we get a case that looks like unbounded
> >  >recursion:
> >  >
> >  >	pdflush -> start_one_pdflush_thread -> kernel_thread -> pdflush ...
> >  >
> 
> Yes.  Ow.  Thanks.

Having just looked at the code, I don't understand the problem.

If kernel thread A starts kernel thread B and kernel thread B starts
kernel thread C and so on, how does that cause stack windup?

