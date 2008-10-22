From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 22 Oct 2008 11:30:05 +0000
Subject: Re: [PATCH 2/2] ia64: implement interrupt-enabling rwlocks
Message-Id: <20081022113005.GC26094@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664534.4430.42.camel@elijah.suse.cz>
In-Reply-To: <1224664534.4430.42.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 22, 2008 at 10:35:34AM +0200, Petr Tesarik wrote:
> +#define __raw_read_lock_flags(rw, flags)					\

I appreciate that ia64 is full of overlength lines, but could you not
add more of them?  There's no reason not to delete one of the tabs on
these lines.

> +} while(0)

checkpatch.pl says you need a space between 'while' and '(0)'.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
