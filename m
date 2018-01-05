From: Petr Mladek <pmladek@suse.com>
Date: Fri, 05 Jan 2018 10:03:00 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon 2017-12-11 21:50:12, Sergey Senozhatsky wrote:
> 	Hello,
> 
> 	A rather automatic replacement of print_symbol()
> with direct printk() calls. print_symbol() uses extra stack
> buffer (KSYM_SYMBOL_LEN 128 bytes) and, basically, should
> be identical to printk(%pS).

To make it clear, both print_symbol() and printk(%pS)
print the adress using sprint_symbol(). And even printk(%pS)
uses the buffer on the stack, see:

char *symbol_string(char *buf, char *end, void *ptr,
		    struct printf_spec spec, const char *fmt)
{
[...]
	char sym[KSYM_SYMBOL_LEN];
[...]
		sprint_symbol(sym, value);
}

Anyway, print_symbol() is an old weird API and it would be nice
to eventually get rid of it. I could take this patches into
printk.git. Would you mind if I change the commit messages
to something like?:

    print_symbol() is an old weird API. It has been
    obsoleted by printk() and %pS format specifier.

Best Regards,
Petr
