From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Jan 2002 21:33:16 +0000
Subject: Re: [Linux-ia64] pre-built Mozilla 0.9.7 anyone?
Message-Id: <marc-linux-ia64-105590698805820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805758@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805758@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 12 Jan 2002 12:06:40 +0100 (CET), Gwenole Beauchesne <gbeauchesne@mandrakesoft.com> said:

  Gwenole> On Mon, 7 Jan 2002, David Mosberger wrote:
  >> Does anyone have a pre-built version of Mozilla 0.9.7 somewhere?

  Gwenole> As "usual", you can find them here:
  Gwenole> <https://qa.mandrakesoft.com/~gb/ia64/mozilla/>

  Gwenole> That time, I could not make it work with decent
  Gwenole> optimizations at all. This is likely to be a bug in the
  Gwenole> compiler, but I had tried with both "2.96" and 3.0.3. With
  Gwenole> the latter, packages won't even fully build.

The snapshot built with gcc3.0 fine (using -O as usual).  I just
 started a build with gcc 3.1 (pre-release).

  Gwenole> BTW, David, have you noticed an unaligned access for
  Gwenole> "regxpcom" with your build ? regxpcom issues an unaligned
  Gwenole> access with the 0.9.7 version I have just built but does
  Gwenole> nothing with 0.9.4-4.4mdk that is available on Mandrake
  Gwenole> Linux 8.1/Itanium. Probably nothing critical but that
  Gwenole> sounds a regression in the Mozilla code ?

I haven't seen unaligned accesses with the snapshot, but over time, I
did see such accesses.  My impression is that such errors get
introduced occasionally and then get fixed relatively quickly.
Somewhat odd that such problems would be in 0.9.7 though.

  Gwenole> Sorry but I don't have much time to investigate more so, I
  Gwenole> will move the above mentioned packages to unsupported/ia64.

No problem.  I don't have much time for it either (other than
periodically trying a "make"... ;-).

	--david

