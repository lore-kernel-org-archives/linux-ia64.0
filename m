From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 14 Oct 2003 05:53:15 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106611095502328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 13, 2003 at 10:23:39PM -0700, David Mosberger wrote:
> consistency-check.  May want to add a comment about that, though.

A few messages up I added something like 

+ * Return the number of nano-seconds that elapsed since the last
+ * update to jiffy.  It is quite possible that the timer interrupt
+ * will interrupt this and result in a race for any of jiffies,
+ * wall_jiffies or itm_next.  Thus, the xtime_lock must be at least
+ * read-locked when calling this routine.

although read-locked should probably be 'read synchronised' or
something to avoid confusion.

-i
