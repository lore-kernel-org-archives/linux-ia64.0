From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 28 Apr 2003 18:30:21 +0000
Subject: [Linux-ia64] Re: gettimeoffset() for sn2
Message-Id: <marc-linux-ia64-105590723705617@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705593@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705593@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 23 Apr 2003 18:08:36 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Argh, you are right, here we go again, now I think I got it all
  Jes> covered. However I think I will stop declaring victory on this
  Jes> one, everytime I do so it comes back to haunt me. This version
  Jes> also fixed a bug where i was scaling the RTC clock twice, not
  Jes> that it was lethal, but it was still a bug.

The patch looks nice and clean to me (didn't try it out myself, though).

	--david

