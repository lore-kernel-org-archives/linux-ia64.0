From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 08:03:21 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 09:27:07 +0200, Eric Piel <Eric.Piel@Bull.Net> said:

  >> I see the same thing, but it's only for asm-ia64/offsets.h.  After
  >> that, parallel makes work just fine.  I tend to be able to live with
  >> such "minor" build issues for a loooong time, giving others ample
  >> chance to get impatient first... ;-)

  Eric> Don't wait, do it now:
  Eric> make prepare
  Eric> make -j4 compressed

Ah, yes, I think I've seen that once mentioned in a mail.

BTW: have you gotten any feedback regarding the timer bug you
reported?  I think the same (rounding) bug may have broken the
profil() call in libc.

	--david

