From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 12 Feb 2001 23:42:57 +0000
Subject: Re: [Linux-ia64] ia64_get_dcr problem
Message-Id: <marc-linux-ia64-105590693005145@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005143@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005143@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Feb 2001 16:25:38 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  Jack> Is this a GCC problem or a problem with the
  Jack> asm/ia64/processor.h inline functions??


  Jack> I used the ia64_set_dcr & ia64_get_dcr functions in a loop &
  Jack> got bad code. I had references to both ia64_get_dcr in
  Jack> ia64_set_dcr in the loop. The "get" was optimized out of the
  Jack> loop & did not see the result of the "set".

  Jack> If I add "volatile" to the ia64_get_dcr asm statement, I can
  Jack> avoid the problem. But I am not sure whether this is the
  Jack> correct solution. (I hit a similar problem with
  Jack> ia64_get_irr0() earlier too).

Thanks for the report.

I fixed this now, along with a couple of other *get* macros in
processor.h.

	--david

