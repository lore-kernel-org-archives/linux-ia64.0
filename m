From: Gerald Pfeifer <gp@suse.de>
Date: Mon, 22 Aug 2005 13:00:31 +0000
Subject: RE: Simulator bootloader fails with gcc 4
Message-Id: <Pine.LNX.4.61.0508220849580.1311@rana.dbai.tuwien.ac.at>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

On Thu, 18 Aug 2005, Luck, Tony wrote:
> Ah ... but gcc has an unpleasant habit of inlining memcpy() calls.  This
> is really annoying when you have taken the trouble to replace code
> does a structure copy with an explicit call to memcpy() becuase
> you know that one of the source or destination is unaligned, only
> to have gcc generate some inline ld8/st8 instructions.

have you considered using one of the following options in some of these
cases?

  `-fno-builtin-FUNCTION'
      Don't recognize built-in functions that do not begin with
      `__builtin_' as prefix.

  `-mmemcpy'
  `-mno-memcpy'
      The `-mmemcpy' switch makes all block moves call the appropriate
      string function (`memcpy' or `bcopy') instead of possibly
      generating inline code.

(I'm currently offline and only have GCC 3.3 docs available, but I'm
pretty sure GCC 3.4 and 4.x support these as well.)

Gerald

