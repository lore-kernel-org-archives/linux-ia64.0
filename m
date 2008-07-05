From: Jan Engelhardt <jengelh@medozas.de>
Date: Sat, 05 Jul 2008 13:24:04 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LNX.1.10.0807051518500.28765@fbirervta.pbzchgretzou.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no>
In-Reply-To: <20080705125230.GA20166@damson.getinternet.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org


On Saturday 2008-07-05 14:52, Vegard Nossum wrote:
>> On Saturday 2008-07-05 00:01, Andrew Morton wrote:
>>>
>>>We don't know how much interest there would be in churning NIPQUAD from
>>>the net guys.  Interestingly, there's also %C (wint_t) which is a
>>>32-bit quantity.  So we could just go and say "%C prints an ipv4
>>>address" and be done with it.  But there's no way of doing that for
>>>ipv6 addresses so things would become asymmetrical there.
>>
>>        struct in6_addr src;
>>        printk("Source address: %p{ipv6}\n", &src);
>>
>> How about %p{feature}?
>
>Something like this?
>
>+static char *custom_format(char *buf, char *end,
>+	const char *fmt, unsigned int fmtlen, void *arg)

I'd use const void *arg here, so nobody gets the idea
that you could modify the argument while printing :)

>+{
>+	if (!strncmp(fmt, "sym", fmtlen)) {
>+		char name[KSYM_SYMBOL_LEN];
>+		int len;
>+		int i;
>+
>+		len = sprint_symbol(name, (unsigned long) arg);
>+		if (len < 0)
>+			return buf;
>+
>+		i = 0;
>+		while (i < len) {
>+			if (buf < end)
>+				*buf = name[i];
>+			++buf;
>+			++i;
>+		}
>+	}

And I assume it's then as simple as

	} else if (strncmp(fmt, "nip6", fmtlen) = 0) {
		snprintf(buf, end - buf (+1?), NIP6_FMT in expanded form,
		         NIP6 in expanded form(arg));
	}

Hm, that's going to get a big function when everyone adds their
fmttypes.

>+
>+	return buf;
>+}
>+
> static char *number(char *buf, char *end, unsigned long long num, int base, int size, int precision, int type)
> {
> 	/* we are called with base 8, 10 or 16, only, thus don't need "G..."  */
>@@ -648,6 +673,25 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
> 				continue;
> 
> 			case 'p':
>+				if (fmt[1] = '{') {
>+					const char *cfmt;
>+
>+					/* Skip the '%{' */
>+					++fmt;
>+					++fmt;
>+

Not this?

	/* Skip the '%p{' */
	fmt += 3;
