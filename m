From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 02 Oct 2000 21:27:30 +0000
Subject: Re: [Linux-ia64] gcc -O2
Message-Id: <marc-linux-ia64-105590678205536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205531@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205531@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Perhaps someone can fix the link in the www.linuxia64.org homepage to
>point to a this?  The current link points to what appears to be a 010500
>snapshot (http://www.cygnus.com/ia64 which resovles to
>ftp://ftp.cygnus.com/private/intel/).

It isn't clear to me what to do about this.  The www.linuxia64.org page points
to the current release that is in use by all existing linux distributions,
and is known to be OK.

The new release is not ABI compatible with the old release, and there are no
linux distributions yet that use the new release.  Also, the new release is
still getting the bugs worked out, and may not be as reliable as the old
release yet.  Certainly, I'll want the link changes when this becomes the
recommended compiler, but we aren't quite there yet.

Jim

