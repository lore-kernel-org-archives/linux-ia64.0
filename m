From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 06:16:21 +0000
Subject: Re: Three random questions
Message-Id: <16609.2357.39317.295491@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40E01743.4060309@octopus.com.au>
In-Reply-To: <40E01743.4060309@octopus.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 28 Jun 2004 23:04:03 +1000, Duraid Madina <duraid@octopus.com.au> said:

  Duraid> 1) Has anyone pondered writing an HPUX-to-Linux ELF64 object
  Duraid> demangler/translator? *damn* that aCC is good sometimes..

It might be easier to generate assembly code.  I have done that
occasionally but the real issue is of course that HP-UX is big-endian,
so only endian-neutral code will work directly that way (and even so
there may be a licensing issue with running HP-UX generated code on a
Linux system; IANAL...).

	--david
