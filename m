From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 May 2001 03:26:37 +0000
Subject: Re: [Linux-ia64] Linker error : linking constant-gp files with non-constant gp fil es
Message-Id: <marc-linux-ia64-105590693005548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 08 May 2001 13:22:19 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> All objects that are linked into the kernel must be compiled
  Keith> with -mconstant-gp.  All objects that are linked into modules
  Keith> must not be compiled with -mconstant-gp.  Set your compile
  Keith> flags accordingly.

That's not sufficient.  You need to use pretty much *all* the flags
that normal kernel compiles use, in particular the -mfixed* options
are important.

	--david

