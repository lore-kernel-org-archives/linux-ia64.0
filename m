From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 19:17:21 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479411315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 11:47:44 -0700, "David S. Miller" <davem@redhat.com> said:

  DaveM> No other port is so obstinate about printing out unaligned
  DaveM> kernel access messages, why does ia64 have to be so
  DaveM> different?

Look, this may be difficult for you to understand, but different
people find different policies useful.  I absolutely want to see when
unaligned accesses happen, because it's almost always a performance
issue, if not an outright bug.  If you don't like the current
mechanisms to control the policy for handling unaligned accesses, make
them better.  Don't try to tell me that the policy I want is
"wrong"---that will get you nowhere.

	--david
