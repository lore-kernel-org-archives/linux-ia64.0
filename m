From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Nov 2002 18:03:45 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805403@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Nov 2002 09:00:26 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> Note that attribute-aliasing is a problem any architecture
  David> with multiple page-size somehow needs to deal with.

Oops, typed a bit too fast here: I meant to say: "any architecture
with multiple page-sizes and per-translation memory attributes" (as is
the case for ia64 and x86, for example).

	--david

