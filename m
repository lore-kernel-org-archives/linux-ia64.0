From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 May 2004 18:09:52 +0000
Subject: Re: Can gcc 3.4 compile 2.6.6 kernel?
Message-Id: <16558.17904.238548.822142@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040521170820.GA5516@lucon.org>
In-Reply-To: <20040521170820.GA5516@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 May 2004 10:08:20 -0700, "H. J. Lu" <hjl@lucon.org> said:

  HJ> Has anyone tried to use gcc 3.4 to compile 2.6.6 kernel? I got many
  HJ> dependency violation messages from assembler and

  HJ> mm/memory.c: In function `copy_page_range':
  HJ> mm/memory.c:391: internal compiler error: in verify_local_live_at_start, at
  HJ> flow.c:546
  HJ> Please submit a full bug report,
  HJ> with preprocessed source if appropriate.
  HJ> See <URL:http://gcc.gnu.org/bugs.html> for instructions.

I have been using a pre-release version of 3.4 with good success.
I haven't had a need to switch to 3.4 final so far, so I haven't really
tried it.

  HJ> Also does 2.6.6 work on bigsur?

I'd certainly expect it to.

	--david
