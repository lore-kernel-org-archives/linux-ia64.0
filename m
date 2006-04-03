From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 03 Apr 2006 17:23:51 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <44315A27.2070101@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote:
> On 4/3/06, Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:
>=20
>=20
>>The problem is that the most frequently used trap handler contains
>>the unsafe walk of the
>>
>>        rx =3D IA64_KR_PT_BASE -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]
>>
>>chain...
>=20
>=20
> Please, everybody step back a minute.  Hint: consider that x86 does
> the page-table walk in hardware...

Telling the truth: I'm not an x86 expert :-)=20
What I could dig up in 5 minutes is:

IA-32 Intel=AE Architecture Software Developer=92s Manual Volume 3A:
7.1.2.1 Automatic Locking

"When updating page-directory and page-table entries:
When updating page-directory and page-table entries, the processor uses
locked cycles to set the accessed and dirty flag in the page-directory
and page-table entries."

I guess the TLB load is auto-locked, too.

Anyway, what can we conclude from this for the ia64 architecture?

Can you _prove_ that walking that chain of pointers is safe?

Thanks,

Zoltan
