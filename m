From: Keith Owens <kaos@sgi.com>
Date: Sat, 04 Jun 2005 04:18:16 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <20855.1117858696@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 3 Jun 2005 11:50:55 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>This explains why XPC has been so troublesome to load on older systems.
>>Thanks Dean!
>>
>>Tony, can this still get into 2.6.12?
>
>Probably ... but the first hunk of the patch looks like a no-op,
>and contravenes some style guidlines about initializing global
>variables to 0.
>
>-static int shub_1_1_found __initdata;
>+static int __initdata shub_1_1_found = 0;

There is a linker restriction that you must initialise variables that
are to be stored in different sections, which is what __initdata does.
without initialization shub_1_1_found ends up in .bss, with
initialization it ends up in .init.data.

