From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 May 2020 19:43:23 +0000
Subject: Re: [PATCH] treewide: Replace zero-length array with flexible-array
Message-Id: <20200507194323.GA9073@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200507185334.GA14456@embeddedor>
In-Reply-To: <20200507185334.GA14456@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 07, 2020 at 01:53:34PM -0500, Gustavo A. R. Silva wrote:
> The current codebase makes use of the zero-length array language
> extension to the C90 standard, but the preferred mechanism to declare
> variable-length types such as these ones is a flexible array member[1][2],
> introduced in C99:
> 
> struct foo {
>         int stuff;
>         struct boo array[];
> };
> 
> By making use of the mechanism above, we will get a compiler warning
> in case the flexible array does not occur last in the structure, which
> will help us prevent some kind of undefined behavior bugs from being
> inadvertently introduced[3] to the codebase from now on.
> 
> Also, notice that, dynamic memory allocations won't be affected by
> this change:
> 
> "Flexible array members have incomplete type, and so the sizeof operator
> may not be applied. As a quirk of the original implementation of
> zero-length arrays, sizeof evaluates to zero."[1]
> 
> sizeof(flexible-array-member) triggers a warning because flexible array
> members have incomplete type[1]. There are some instances of code in
> which the sizeof operator is being incorrectly/erroneously applied to
> zero-length arrays and the result is zero. Such instances may be hiding
> some bugs. So, this work (flexible-array member conversions) will also
> help to get completely rid of those sorts of issues.
> 
> This issue was found with the help of Coccinelle.
> 
> [1] https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
> [2] https://github.com/KSPP/linux/issues/21
> [3] commit 76497732932f ("cxgb3/l2t: Fix undefined behaviour")
> 
> Signed-off-by: Gustavo A. R. Silva <gustavoars@kernel.org>

I'm fine with this specific change ... so

Acked-by: Tony Luck <tony.luck@intel.com>

for anyone picking up all of these treewide: patches
(if they don't, then I can apply this to the ia64 tree)


But a question ... is sizeof still ok on a structure that
contains a flexible-array-member?

E.g. I'd expect:

struct foo {
        int stuff;
        struct boo array[];
};

	printk("size of foo = %d\n", sizeof(struct foo));

To not give any complilation warnings and to tell me that
the size of the structure is 4 bytes.

Is that still true and OK?

-Tony
