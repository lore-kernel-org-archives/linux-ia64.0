From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 04 Apr 2006 14:27:34 +0000
Subject: Re: [PATCH] eliminate compiler warning for xpc_channel.c
Message-Id: <20060404142734.GI8315@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
In-Reply-To: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 04, 2006 at 07:23:32AM -0700, Luck, Tony wrote:
> -	struct xpc_msg *msg;
> +	struct xpc_msg *msg = msg;
> 
> Did you mean to say "*msg = NULL"?

this is actually an ANSI-permitted idiom for shutting up compiler
warnings while not actually initialising the variable.
