From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 18:59:11 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 May 2003 09:33:12 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Do you have some direction for the __imva() macro?  The
  Tony> acronym stands for "Identity Mapped Virtual Address", and its
  Tony> purpose is to provide the region 7 address for an object, so
  Tony> that the existing code can continue to work without a whole
  Tony> lot of run-on changes.  If you just don't like the name, then
  Tony> it's easy to change to something else.  If it's the typecast
  Tony> issue, then I can switch over to void *.  If it just makes
  Tony> your head hurt coping with schizophrenic dual mapping that the
  Tony> kernel gets with this patch, then you'll just have to take a
  Tony> couple of aspirin and look at the patch again in the morning
  Tony> :-)

It's a bit of "all of the above":

 - The name isn't all that great, but since it _is_ doing something
   rather strange, a strange names seems quite appropriate. The patch
   should definitely add a brief (one-liner?)  explanation of what
   __imva() stands for and what it does.  Also, I really dislike the
   underscore silliness; let's just use ia64_imva() or some such, so
   it's obvious that it is ia64-specific (there is no
   namespace-pollution issue as there would be, say, in a user-level
   library, so there is really no reason for using an underscore
   prefix).

 - the casting should be fixed

 - instead of aspirins, it might be good to add the ASCII art you
   posted recently in an appropriate place (either a header-file
   or perhaps a Documentation/ia64 file); of course, the picture
   you drew included text-replication, so we may want to hold off
   with this until that part of the patch is in, too

	--david

