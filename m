From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 26 Sep 2001 22:49:52 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805259@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 25 Sep 2001 17:14:36 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> CONFIG_DISABLE_VHPT=y seems to be broken (does not boot).
  Andreas> How about removing it, since we don't support anything
  Andreas> below B3 anyway?

It's a debugging & performance evaluation feature, so I have no plans
to remove it.  It is listed under the "Kernel debugging" section, so I
think we can leave it there, even if it's broken at the moment.

	--david

