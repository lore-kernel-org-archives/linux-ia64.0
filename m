From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Thu, 26 Jul 2001 16:30:53 +0000
Subject: Re: [Linux-ia64] Re: Reiserfs (was: Re: __ia64_syscall ?)
Message-Id: <marc-linux-ia64-105590693005926@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005924@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005924@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Why does an *endian* patch make reiserfs work on ia64, when
> ia64 is little endian like x86?
>
> Bill, genuinely curious...

I don't know - it works for me, at least I have seen no data corruption
yet.

What the patch does is introduce generic disk<->cpu conversion macros
everywhere. My guess is that they not only provide correct endianness,
but also fix other machine-dependent type issues.

Try it, and call me whatever you want if it fails.

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




