From: Matthew Wilcox <willy@debian.org>
Date: Wed, 19 Nov 2003 19:54:02 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927177600804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 19, 2003 at 11:44:46AM -0800, David Mosberger wrote:
> What's wrong with dmesg -n4?  Those messages are marked KERN_DEBUG for
> a reason.  BTW: Red Hat does this by default, but Debian doesn't.  In
> my opinion, Red Hat does the right thing here: by default, most user's
> don't care about such messages, but they're invaluable when tracking
> down problems.

This is the same thing as printing the user unaligned exceptions.
It's something no other architecture does, and for a reason, which has
been explained to you before, but you don't want to fix it.  *sigh*.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
