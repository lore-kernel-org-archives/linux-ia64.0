From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Apr 2004 23:39:17 +0000
Subject: Re: syscall_linkage
Message-Id: <16501.58021.512759.797754@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <407575C0.840593AC@nospam.org>
In-Reply-To: <407575C0.840593AC@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan,

The quick summary can be found in asm-ia64/ptrace.h.
Also, my book has a fairly extensive discussion of how machine-state
is handled on ia64 linux.

	--david

>>>>> On Thu, 08 Apr 2004 17:54:40 +0200, Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org> said:

  Zoltan> Can somebody explain me, please, what the difference is between an
  Zoltan> __attribute__((syscall_linkage)) call and a regular one ?

  Zoltan> The Itanium Software Conventions & Runtime Architecture Guide does
  Zoltan> not say a word about it, does it mean it is a non standard way to
  Zoltan> pass parameters ?

  Zoltan> What registers need / do not need to be saved with respect to what
  Zoltan> is written in the Intel book ?
