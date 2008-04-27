From: Robin Holt <holt@sgi.com>
Date: Sun, 27 Apr 2008 11:51:06 +0000
Subject: Re: [PATCH] fix file and descriptor handling in perfmon
Message-Id: <20080427115106.GC19717@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1JpvWk-0003lk-FT@ZenIV.linux.org.uk>
In-Reply-To: <E1JpvWk-0003lk-FT@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ftp.linux.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Not really an objection, just a simple comment.

On Sun, Apr 27, 2008 at 02:18:02AM +0100, Al Viro wrote:
...
> -static int
> -pfm_alloc_fd(struct file **cfile)
> +static struct file *pfm_alloc_file(pfm_context_t *ctx)

ZZZ
You mangle the style.  Not sure how important that is to Stephane, et
al.  They appear to use a two line function name which does make
searching with vi easier because /^pfm_alloc_file finds the function.

Thanks,
Robin Holt
