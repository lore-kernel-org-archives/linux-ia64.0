From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 16 Mar 2001 21:38:10 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don Dugger of VA has looked at 64K page support.

	- gcc doesnt support 64K alignment (perhaps I am using
	  an old gcc??)

Don reported an assembler problem.  Is that perhaps what you meant?
In gas/read.c, function s_align, there is a check
  if (align > 15)
    {
      align = 15;
      as_bad (_("Alignment too large: %u assumed"), align);
    }
I don't know why it is there.  I would hypothesize limitations of old object
file formats like aout/coff.  This problem has been reported on the
binutils@sources.redhat.com mailing list, but no one there volunteered to
look into the problem.  This is still on my todo list, along with a lot of
more important stuff.

Jim

