From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 29 Aug 2000 18:09:46 +0000
Subject: Re: [Linux-ia64] cross compile (assembler) error: Unknown pseudo-op:
Message-Id: <marc-linux-ia64-105590678205408@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Joerg Gittinger wrote:

> I have a cross compile environment with the newest (I think) gnopro gcc,gas,...
> tools. When I try to compile a 2.4.0-test4 kernel (+07/28 patch, kdb-test4
> patch), I get lots of the following assembler error message:
>
> entry.S:1040: Error: Unknown pseudo-op:  `.spillsp'

Did you enable new unwind support in the kernel configuration?  Don't -- you need
a toolchain which supports new unwind directives.  AFAIK none of the Linux/IA-64
distributions ship a toolchain with these patches.

Uros


--
Uros Prestor
uros@turbolinux.com




