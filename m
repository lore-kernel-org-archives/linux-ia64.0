From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Apr 2002 02:00:32 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 13 Apr 2002 03:38:40 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> There is no way for gcc to see the memset macro when it
  Andreas> generates the call to the memset function.  And there isn't
  Andreas> much lost anyway, since the macro is just there to call
  Andreas> __bzero vs. __memset_generic (aka memset), the difference
  Andreas> is just one parameter more or less.

Just fyi: the reason I split it up is because for ia64 its worthwhile
to special-case the memset-to-zero case (think stf.spill).  That code
isn't there yet, but I wanted to get things set up for it.  Of course,
memset can also check for this case dynamically, but from a logical
perspective, I like it better to make the bzero case explicit (and
save a taken branch in those cases where the compiler macro detects
memset-to-zero).

	--david

