From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 Jan 2004 19:19:36 +0000
Subject: RE: segv at strcmp
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FAFE8@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
In-Reply-To: <20040105190848.66033.qmail@web60006.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hi -
>   The gcc version is gcc-3.2-29 and the flags we pass
> to gcc are : -O -ansi -fwritable-strings -fsigned-char
> -D_GNU_SOURCE -D_REENTRANT

I have gcc 3.2.3 ... but it appears to not do anything
strange to my test program with those options.

main()
{
        char *x = "7chars!";

        strcmp(x, "This is 24 chars long!!!");
}

with those options.  Do you have any include files that
might be redefining strcmp as memcmp?

-Tony
