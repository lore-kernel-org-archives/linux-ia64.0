From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jan 2004 03:16:51 +0000
Subject: Re: a question about memory access on IA64
Message-Id: <16391.22435.819115.866878@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 Jan 2004 11:03:00 +0800, liuduo <liuduo@sinosoft.com.cn> said:

  liuduo> Dear Sir: nice to see you !  here is a problem about
  liuduo> accessing memory on IA64 as follows, we define a structrue
  liuduo> is : typedef struct b{ unsigned short b1; unsigned short b2;
  liuduo> unsigned char b3; unsigned char b4; unsigned char b5;
  liuduo> unsigned char b6; }B;

  liuduo> typedef struct a{ struct b bb[512]; int c;}A;

  liuduo> when we use the struct A on IA64, the segmentation fault
  liuduo> occurs , and then we modify the struct A as follows :
  liuduo> typedef struct a{ int c; struct b bb[512]; }A; we can use it
  liuduo> normally .  can you explain why ?  thanks a lot , and expect
  liuduo> your reply urgently

The example you posted is not a complete, self-contained program, so
it's impossible to say whats wrong.  Perhaps it's a compiler bug,
perhaps it's a kernel bug, perhaps it's a bug in the program.  Please
post a _minimal_ test program that reproduces the problem you're
trying to solve and state what compiler version, etc. you're using.
Then somebody may be able to help.

	--david
