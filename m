From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 28 Feb 2002 21:33:39 +0000
Subject: Re: [Linux-ia64] problem with unwind info for .init/.fini sections
Message-Id: <marc-linux-ia64-105590701905203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905179@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905179@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Feb 2002 11:19:30 -0800, Cary Coutant <cary@cup.hp.com> said:

  >> I can think of two approaches:
  >> ...
  >> Anybody else have a better idea or other comments?

  Cary> (3) Use the .init_array and .fini_array sections instead.

This would be by far the cleanest solution.

How well is this supported in binutils at the moment?  I see some
references to it, but am not sure whether there are any holes in its
support.

Are there any reasons *not* to switch to .init_array/.fini_array as
the primary init/fini mechanism?  Besides fixing the unwind problem,
it seems to me it's generally just a much cleaner solution and should
allow us to get rid of some rather ugly hacks in glibc.

	--david

