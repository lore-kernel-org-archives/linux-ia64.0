From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 06 Feb 2001 02:48:10 +0000
Subject: Re: [Linux-ia64] kdb v1.7 for IA64 is available
Message-Id: <marc-linux-ia64-105590693005117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005109@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005109@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 06 Feb 2001 13:34:57 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> SGI's version of kdb was redesigned some months ago to better handle
  Keith> SMP, as well as recursion and debugging of kdb itself.  Unless David
  Keith> Mosberger or Stephane Eranian have any objections[*], SGI will take
  Keith> over kdb for IA64 again.

No objections from our side.  Stephane took over only because the
original code was orphaned and we needed a working kdb...

  Keith> [*] Yes David, I _will_ remove the switch_stack change.

Great!  This is the one reason why I'm _not_ using the current version
of Keith's patch.  It modifies the switch stack structure, which is
about as fundamental a data structure as you get in the kernel.  I
don't believe this directly affects kernel functionality in any known
ways, but there is always a risk it could do so in unknown
ways---which isn't ideal when trying to track down a problem...

However, since Keith agreed to fix this in the next version, this
issue will be moot soon and then I, too, will get to enjoy the new
features. ;-)

	--david

