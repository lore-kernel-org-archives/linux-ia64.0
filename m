From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 27 Aug 2002 19:58:28 +0000
Subject: Re: [Linux-ia64] PATCH 2.4.19 ppp_generic.c
Message-Id: <marc-linux-ia64-105590701905988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905985@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905985@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab wrote:
> IMHO <asm/io.h> should be fixed:

yeah - I like that too.

I still think using "out" (and variants) for labels is a Bad Idea (tm).

grant

