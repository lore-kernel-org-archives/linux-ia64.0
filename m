From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 01 Mar 2003 08:10:03 +0000
Subject: [Linux-ia64] Re: Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709805949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Eric,

>>>>> On Fri, 28 Feb 2003 10:52:33 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> long v;
  Eric> :
  Eric> :
  Eric> if ( v >= (1 << 56)){
  Eric> :
  Eric> }

  Eric> It seems very strange for me that when compiling this part gcc
  Eric> considers that eveything must be converted to int. I have to
  Eric> write 1UL instead of 1 in order to obtain the correct
  Eric> behaviour of the code. I guess you've already come along with
  Eric> such problem.

As Andreas pointed out, that's just how C works.

  Eric> So, first, do you think it's a bug in gcc?

No, gcc is doing the Right Thing.

  Eric> Second should I convert every 1's I see by 1UL's (there are
  Eric> only few but sounds so strange)?

Yes, you need to make sure that anything that gets shifted more than
32 bits has the proper type.  In portable code, I sometimes prefer
to use explicit type-casts, e.g.:

	((size_t) 1) << 48

if the final value needs to be of type size_t, but that's largely
a matter of taste.

	--david

