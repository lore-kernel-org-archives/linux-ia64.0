From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 02:15:28 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805588@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 13:11:46 +1100, Rusty Russell <rusty@rustcorp.com.au> said:

  Rusty> if (owner = me) should do this.

  Rusty> On top of your patch and my previous, this works!

Good to see that.

For someone who cares about modules and ia64 performance: you might
want to consider to use "brl" in the PLT stub instead of the
standardized code sequence.  That would avoid an indirect branch and
associated mis-prediction penalties.  (Of course, this would be for
McKinley and later CPUs only as Merced doesn't implement "brl" in
hardware).

	--david

