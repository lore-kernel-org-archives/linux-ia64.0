From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 27 Sep 2001 17:48:41 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Sep 2001 14:57:34 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Some of us are still using gcc 2.96 which does not support
  Keith> --param max-inline-insns.

Oh, I didn't realize this option was added for gcc 3.x.  It certainly
wasn't my intention to break compilation with gcc 2.96.  Anyhow, I
fixed this now in my tree as well (note: option -frename-registers is
already gcc 3.x specific, so there is no need to introduce yet another
test for gcc 3).

Thanks,

	--david

