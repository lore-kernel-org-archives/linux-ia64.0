From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 25 Mar 2001 00:27:08 +0000
Subject: Re: [Linux-ia64] gcc-ia64 latest distributions
Message-Id: <marc-linux-ia64-105590693005351@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 24 Mar 2001 19:13:28 -0500, "thembeka" <thembeka@bellsouth.net> said:

  thembeka> entry.S:1028: Error: Unknown opcode `mov.ret.sptk b7=r28,1f'

Oops, it appears that the old assembler didn't support this
instruction.  I didn't realize that because I didn't start using it
until recently.

An easy workaround would be the following. In
arch/ia64/kernel/entry.h, change the first line of:

	#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPECIFIC)
	# define MOVBR(type,br,gr,lbl)	mov br=gr

to

	#if 1
	# define MOVBR(type,br,gr,lbl)	mov br=gr

I think that should get you around the assembler problem.
Alternatively, you could upgrade the toolchain using the tar ball that
Khalid pointed you to.

	--david

