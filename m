From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 23 Mar 2002 00:16:27 +0000
Subject: Re: [Linux-ia64] Sym53c8xxx woes
Message-Id: <marc-linux-ia64-105590701905334@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Aaron Burt wrote:
> OK, so I've upgraded our NEC AzusA 16-way to 2.4.18, and ran into a li'l
> problem.  When I've 20GB of RAM or more enabled, the Sym53c8xxx v1 driver
> crases on boot.  The v2 driver won't even compile.

HP ran into a similar problem and crippled the sym53c8xxx to only
register for 32-bit DMA support. Things work fine that way.

grant

