From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Nov 2002 18:54:31 +0000
Subject: Re: [Linux-ia64] Re: O(1) scheduler fix for 2.5-ia64
Message-Id: <marc-linux-ia64-105590709805335@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 5 Nov 2002 12:35:35 +0100, Erich Focht <efocht@ess.nec.de> said:

  Erich> This can happen when the runqueue lock is held during a
  Erich> context switch which requires wrapping around the context
  Erich> numbers:

Ah, right.  I really dislike the fact that the locking rules for
platform-independent locks will vary from one platform to the other.
Hopefully someone will look into fixing that at some point.

	--david

