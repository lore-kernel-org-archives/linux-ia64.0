From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 24 Apr 2002 05:23:06 +0000
Subject: [Linux-ia64] Re: PAL entry point
Message-Id: <marc-linux-ia64-105590701905505@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger schrieb:

> >>>>> On Tue, 23 Apr 2002 07:28:35 +0200, Christian Hildner <christian.hildner@hob.de> said:
>
>   Christian> The supplied stubs use register stack and
>   Christian> certain registers that I am using too. Furthermore I
>   Christian> cannot rely on this routines beeing unchanged in the
>   Christian> future. So I want to code my own mode switch stub.
>
> I see.  So why don't you grab the PAL entry point from the SAL system table?
> The address of that table is stored in the "efi" table (see asm-ia64/efi.h).
>
>
>         --david

Yes, that's it.

Christian


