From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Apr 2005 20:46:29 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <16982.60837.499698.196202@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Apr 2005 10:48:39 -0700, Matt Mackall <mpm@selenic.com> said:

  Matt>  return ia64_getf_exp(d) & 0x3f;

  Matt> is the right fix. The fact that it's using floating point
  Matt> is... weird.

<rant>

Why is it that so many Linux developers have this knee-jerk "weird"
reaction whenever they see something that they didn't expect?

</rant>

OK, I feel better now, so in the hope that you're curious to know how
this works: if you know about floating-point numbers, you know that
after each operation, the FPU has to normalize the result.  Given
that, it's clearly something that an FPU will do "fast" (in constant
time).  Furthermore, normalization is nothing more than shifting bits
left until the most-significant bit is 1 and counting (in the
exponent) how many shifts you had to do.  Now, if you have an FPU unit
which can represent a full 64-bit value in the mantissa (which is the
case for ia64), presto, you got a very efficient way to do fls().  As
mentioned earlier, there may be reasons why it's not the best
solution, but in my book it certainly counts as an elegant solution.

	--david
