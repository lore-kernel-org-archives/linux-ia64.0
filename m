From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 23:57:38 +0000
Subject: Re: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105590709805606@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 17:26:10 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:

  Joel> This can be used for example to run scheduler latencies tests
  Joel> (a way of using amlat) - I've got some more stuff for this,
  Joel> please mail me.

What's wrong with using the PMU for this?  That's something that works
on all ia64 platforms and doesn't depend on legacy hardware.

	--david

