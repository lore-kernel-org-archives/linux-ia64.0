From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 28 Apr 2001 02:55:57 +0000
Subject: Re: [Linux-ia64] Cleanup include/asm-ia64/offsets.h
Message-Id: <marc-linux-ia64-105590693005487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Apr 2001 12:49:29 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> As part of my makefile rewrite for 2.5 I am cleaning up
  Keith> problems like this.  The patch below deletes
  Keith> include/asm-ia64/offsets.h from the shipped tree, restricts
  Keith> its use to assembler code only and makes sure that assembler
  Keith> code always gets the latest offset values.  C code is not a
  Keith> problem, the dependency system handles structure and config
  Keith> changes for C code.

There is no way I'm going to duplicate those definitions for asm and C
code.  Please find a way to make the same file work for both C and
asm.

	--david

