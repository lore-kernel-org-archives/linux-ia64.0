From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 23:31:17 +0000
Subject: [Linux-ia64] Re: 2.5.69 process.c: cpu_idle() cleanup
Message-Id: <marc-linux-ia64-105590723705738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 11 May 2003 14:33:48 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Hi David.  Looking at the 2.5.69 cpu_idle() code and noticing
  Jes> that it has some SGI specific hooks in it. However I can see
  Jes> other platforms having leds or lcds or something else they want
  Jes> to flash or play little jingles when the box is idle.

  Jes> As such I suggest we make these hooks that any platform can
  Jes> register.  Adding the extra code to the idle loop doesn't seem
  Jes> all that expensive ;-)

Is this a real need or is this just something hypothetical?  If the
latter, I'd rather leave what's there now.

	--david

