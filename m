From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Oct 2003 01:49:33 +0000
Subject: Re: WAW dependency messages
Message-Id: <marc-linux-ia64-106626899327674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106625678318659@msgid-missing>
In-Reply-To: <marc-linux-ia64-106625678318659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Oct 2003 16:51:44 -0700, "H. J. Lu" <hjl@lucon.org> said:

  HJ> Kernel is a totally different issue. You can send me small asm
  HJ> testcases. I will see what I can do.

Here is one that bugs me (adapted from fsys.S):

$ cat t.S
        mov psr.l = r2;;
        mov r25=ar.rnat
$ as -x t.S
/r/wailua/tmp/t.S: Assembler messages:
/r/wailua/tmp/t.S:3: Warning: Use of 'mov.m' violates RAW dependency 'PSR.si' (data)
/r/wailua/tmp/t.S:1: Warning: This is the location of the conflicting usage
$ as --version |head -1
GNU assembler 2.13.90 20030425

I think the warnings shows up because the assembler doesn't detect
that we're reading ar.rnat, not ar.itc.

	--david
