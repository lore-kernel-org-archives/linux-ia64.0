From: Matthew Wilcox <willy@debian.org>
Date: Tue, 23 Sep 2003 19:28:04 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434575813190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 11:52:00AM -0700, David S. Miller wrote:
> On Tue, 23 Sep 2003 20:54:50 +0200
> Andreas Schwab <schwab@suse.de> wrote:
> 
> > Unaligned access are a BUG.
> 
> Wrong, they've been allowed in the kernel networking from day
> one and there is nothing that can be done to avoid the cases
> for which they occur.

That's not true; they could be avoided by using get_unaligned() and
put_unaligned().  You just don't want to because they'd make sparc suck.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
