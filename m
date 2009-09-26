From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 26 Sep 2009 23:16:54 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <20090926231654.GB19892@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 26, 2009 at 01:39:12PM -0700, Linus Torvalds wrote:
> Ok, so x86 has obviously done ticket locks for a while now, and I think 
> it's good that ia64 does too, but I wonder why you made the ticket lock be 
> a full 64-bit thing?

This got brought up earlier, and there isn't a fetchadd4, only a fetchadd8.

I have no comment on your other criticism.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
