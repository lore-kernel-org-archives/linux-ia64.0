From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Dec 2000 06:44:29 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2000 22:36:46 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>  Keith> One pointer in struct thread, one pointer in switch_stack, ~
>  Keith> 15 instructions (2-3 extra bundles) to set the pointers
>  Keith> during save_switch_stack, load_switch_stack and copy_thread.
>  Keith> Is that too big a change?
>
>It's not the amount of work the change that's involved, it's that the
>change makes no sense whatsoever.  Surely you can find a better
>solution?

I need to look at an arbitrary process and determine its stack state
accurately.  If you can think of an method which does not require
tracking the switch_stack (or current top of stack, it is almost the
same thing) for all processes, let me know.  I looked at this for a
couple of weeks without finding a better solution.


