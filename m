From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 11:37:25 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17010.7285.561402.280478@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Apr 2005 13:53:11 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> I thought that a memory barrier was needed to insure that
  Christoph> the clearing of the lock becomes visible after changes
  Christoph> done in the critical section?

With "volatile", the compiler will generate stX.rel...

  Christoph> y is defined in its own block.

Ummh, macros 101: think about what happens for _raw_write_unlock(y)...

	--david
