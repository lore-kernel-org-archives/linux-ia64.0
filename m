From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Feb 2003 19:47:59 +0000
Subject: Re: [Linux-ia64] IA64/ecc - Problems with system.h
Message-Id: <marc-linux-ia64-105590709805942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805939@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Feb 2003 11:39:10 -0800, Stephane Eranian <eranian@hpl.hp.com> said:

  Stephane> Manoj, On Thu, Feb 27, 2003 at 11:24:38AM -0800, Siddha,
  Stephane> Suresh B wrote:
  >>  ecc doesn't support asm stmts. We need to replace all asm stmts
  >> into compiler dependent intrinsics. This is work in progress.

  Stephane> I think the other major/source issue isthat the program
  Stephane> includes kernel "private" header files (asm/system.h)
  Stephane> which IT SHOULD NOT!

Unless he's trying to compile the kernel... ;-)

	--david

