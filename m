From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Tue, 10 Apr 2001 02:59:31 +0000
Subject: Re: [Linux-ia64] Unresolved symbols when installing modules
Message-Id: <marc-linux-ia64-105590693005383@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005381@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005381@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't know what aci_* does, but as far as isa_* is concerned: DIG64
> does not support ISA, so you can't link in any drivers that try to
> access ISA devices.

Thank you David!!

After removing the necessary modules, everything is working fine. Btw,
I wasn't aware that DIG64 doesn't support ISA.

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

