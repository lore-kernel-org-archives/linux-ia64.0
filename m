From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 17:53:06 +0000
Subject: Re: optimize __gp location
Message-Id: <16885.13826.656458.941185@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Jan 2005 08:51:17 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Did you have benchmarks? Or at least a comparison of the
  Christian> resulting code size. The code size should shrink when
  Christian> more items can be addressed directly. Furthermore the
  Christian> code size should be a good indicator for the performance
  Christian> gain you could achive.

I'm curious about this too.  Ken, do you have a real-world benchmark
where improved GP-relative addressability actually made a significant
difference?

	--david
