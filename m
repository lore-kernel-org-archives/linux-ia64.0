From: Matt Mackall <mpm@selenic.com>
Date: Fri, 08 Apr 2005 17:48:39 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050408174839.GB3174@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 10:33:24AM -0700, Andrew Morton wrote:
> 
> I agree that ia64's fls() is broken.
> 
> So the random driver is presently busted on ia64?

Yes. The negative numbers coming out of fls make it discount what
entropy it's collected so far. This works around it, but obviously
it's much better fixed by unbreaking fls. One wonders if:

 return ia64_getf_exp(d) & 0x3f;

is the right fix. The fact that it's using floating point is... weird.

Work around broken IA64 fls.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: mm/drivers/char/random.c
=================================--- mm.orig/drivers/char/random.c	2005-04-07 14:13:23.000000000 -0700
+++ mm/drivers/char/random.c	2005-04-08 10:39:17.000000000 -0700
@@ -622,7 +622,7 @@ static void add_timer_randomness(struct 
 		 * and limit entropy entimate to 12 bits.
 		 */
 		credit_entropy_store(&input_pool,
-				     min_t(int, fls(delta>>1), 11));
+			max_t(int, 0, min_t(int, fls(delta>>1), 11)));
 	}
 
 	if(input_pool.entropy_count >= random_read_wakeup_thresh)


-- 
Mathematics is the supreme nostalgia of our time.
