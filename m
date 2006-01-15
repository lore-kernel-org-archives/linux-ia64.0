From: Jes Sorensen <jes@trained-monkey.org>
Date: Sun, 15 Jan 2006 12:34:54 +0000
Subject: Re: [PATCH] SN: Add initial ACPI support
Message-Id: <yq0slrp1xg1.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <28961.1137282162@ocs3.ocs.com.au>
In-Reply-To: <28961.1137282162-1LO6/iIh+iQ0n/F98K4Iww@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos-sJ/iWh9BUns@public.gmane.org>
Cc: John Keller <jpk-sJ/iWh9BUns@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

>>>>> "Keith" = Keith Owens <kaos@sgi.com> writes:

Hi,

Just a general comment on top of Keith's.

Keith> John Keller (on Sat, 14 Jan 2006 11:37:47 -0600 (CST)) wrote:
>> +inline uint64_t +sal_ioif_init(void)

Keith> Make that static with no inline, let gcc decide if it should be
Keith> inlined or not.

Please stick to using the preferred kernel internal types, u64/u32/u16
etc. I noticed you switch u64 to uint64_t in many places which is the
wrong way to go.

Regards,
Jes
