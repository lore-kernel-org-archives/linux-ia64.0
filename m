From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Mar 2002 17:31:49 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905241@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 08 Mar 2002 11:26:33 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Ok that's true. I changed my program so that before the
  Christian> measuring loop there comes the same loop for filling the
  Christian> cache. Also I had to increase the memory size to a
  Christian> minimum of 128 pages because for itanium there are 32
  Christian> entries for L1-DTLB and 96 entries for L2-DTLB. Now I get
  Christian> values of 42 cycles with VHPT enabled and 180 cycles with
  Christian> VHPT disabled. This values are coming near to the ones
  Christian> you found.

Great!

Two other things you may want to try:

 o Use a stride of PAGE_SIZE+LINE_SIZE.  This reduces the likelihood
   of exceeding the cache associativity.

 o Rather than calling printf() in each iteration, collect the results
   in an array and print them once the test is done.  printf() is a monster
   and will blow away a good portion of the first level caches as well as
   a couple of TLB entries.

	--david

