From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Oct 2003 16:58:14 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106615107610622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Oct 2003 15:53:15 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> On Mon, Oct 13, 2003 at 10:23:39PM -0700, David Mosberger
  Ian> wrote:
  >> consistency-check.  May want to add a comment about that, though.

  Ian> A few messages up I added something like

  Ian> + * Return the number of nano-seconds that elapsed since the
  Ian> last + * update to jiffy.  It is quite possible that the timer
  Ian> interrupt + * will interrupt this and result in a race for any
  Ian> of jiffies, + * wall_jiffies or itm_next.  Thus, the xtime_lock
  Ian> must be at least + * read-locked when calling this routine.

  Ian> although read-locked should probably be 'read synchronised' or
  Ian> something to avoid confusion.

Sounds fine to me.  Do you want to send me a complete patch so you'll
get the proper credit?

Thanks,

	--david
