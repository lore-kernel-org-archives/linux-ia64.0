From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 Mar 2004 21:29:29 +0000
Subject: Re: [2.6 PATCH] Altix - console driver calls console_initcall
Message-Id: <200403081429.29622.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403082032.i28KWvuw082582@fsgi900.americas.sgi.com>
In-Reply-To: <200403082032.i28KWvuw082582@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>, davidm@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Monday 08 March 2004 1:32 pm, Pat Gefre wrote:
> -static void __init sn_sal_serial_console_init(void);
> +int __init sn_sal_serial_console_init(void);

I don't see any callers other than the console_initcall(), so
you could lose the declaration altogether.

> -static void __init
> +int __init
>  sn_sal_serial_console_init(void)

console_initcall() works fine with static functions, so you should
be able to keep this static.

Bjorn

