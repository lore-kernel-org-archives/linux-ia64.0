From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 15 Feb 2002 19:58:00 +0000
Subject: Re: [Linux-ia64] csum_ipv6_magic
Message-Id: <marc-linux-ia64-105590701905113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005901@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Niels Christiansen" wrote:
> Can anybody tell me which version of IA64 Linux contains csum_ipv6_magic?
> I'm currently on 2.4.16.

None of them (afaict).

Delete the declaration in include/asm-ia64/checksum.h so it uses
the generic code. We (HP LSO) have a patch but I don't think david
has seen that yet.

grant

