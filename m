From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Sep 2003 17:26:25 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106381981428905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Sep 2003 10:33:47 -0400, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "Nathan" = Nathan Scott <nathans@sgi.com> writes:
  Nathan> Does anyone know why the IA64 platform-specific ino_t
  Nathan> definition is an int and not a long?  Patch below fixes this
  Nathan> problem for me but I wonder if there will be side-effects I
  Nathan> haven't considered (i.e. was there a reason for making this
  Nathan> 32 bits originally?).  If not, could the IA64 maintainers
  Nathan> push this patch around to the official kernel trees for me?
  Nathan> (pretty please)

  Jes> Hi Nathan,

  Jes> I am actually surprised it's still a 32 bit int in the
  Jes> kernel. I deliberately used 64 bit types in glibc so it could
  Jes> be done right. Must have slipped on fixing the kernel for this
  Jes> one.

  Jes> David?

Extending ino_t to 64 bits came up last October [1].  AFAIK, nobody
bothered to investigate & send a patch, so things didn't change since
then.

	--david

[1] http://www.gelato.unsw.edu.au/linux-ia64/0210/3952.html
