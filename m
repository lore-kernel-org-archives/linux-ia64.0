From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 11 Aug 2000 12:19:01 +0000
Subject: Re: [Linux-ia64] Alignment possible hazard
Message-Id: <marc-linux-ia64-105590678205318@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205317@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205317@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 11 Aug 2000 14:05:20 +0200 (MEST), 
"G\\351raud Krawezik" <gk@scali.no> wrote:
>In the kernels >=2.3, a new function as appeared for drivers,
>
>static int ssci_read_proc(char *page, char **start, off_t off, int count,
>int *eof, void *data)
>
>What I noticed is that we' ve got the following arguments:
>64 bits, 64 b, 64b, 32b, 64b, 64b
>(in the LP64 model)
>
>Isn't this quite hazardous, especially for programs running at the kernel
>level? Wouldn't it be better to put the int at the end of the arguments in
>order to have something aligned correctly? (at least such things crash
>easiely on solaris-sparc)

Intel's IA64 Software Conventions Runtime Architecture Guide
(24535801.pdf) says

"8.5 Parameter Passing

Parameters are passed in a combination of general registers,
floating-point registers, and memory, as described below, and as
illustrated in Figure 8-3.

The parameter list is formed by placing each individual parameter into
fixed-size elements of the parameter list, referred to as parameter
slots. Each parameter slot is 64 bits wide; parameters larger than 64
bits are placed in as many consecutive parameter slots as are needed to
contain the entire parameter. The rules for allocation and alignment of
parameter slots are given later in this section.

The contents of the first eight parameter slots are always passed in
registers, while the remaining parameters are always passed on the
memory stack, beginning at the caller's stack pointer plus 16 bytes.
The caller uses up to eight of the registers in the output region of
its register stack for integer parameters, and up to eight
floating-point registers for floating-point parameters."

So parameter passing is not a problem.  Now if it was a structure with
different sizes ...


