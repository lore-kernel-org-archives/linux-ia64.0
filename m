From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Mar 2004 23:44:42 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <16484.49258.833848.666518@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Mar 2004 09:16:52 -0800 (PST), markw@osdl.org said:

  Mark> We have 4-way Itanium2 systems here.  Is that large enough for testing?

Bigger is better and of course NUMA is harder than UMA, but certainly
4-way can provide useful data-points.

	--david
