From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 01:10:51 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705815@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 May 2003 09:59:29 +1000, Martin Pool <mbp@samba.org> said:

  Martin> On 14 May 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> 
  >> >> I see the same thing, but it's only for asm-ia64/offsets.h.  After
  >> >> that, parallel makes work just fine.  I tend to be able to live with
  >> >> such "minor" build issues for a loooong time, giving others ample
  >> >> chance to get impatient first... ;-)
  >> 
  Eric> Don't wait, do it now:
  Eric> make prepare
  Eric> make -j4 compressed

  Martin> (Advertorial): Now you've got make -j4, you should try ccache and
  Martin> distcc.  They make development on big trees enormously more
  Martin> enjoyable.  Andrew Morton and other kernel developers love them.

  Martin> http://distcc.samba.org/
  Martin> http://ccache.samba.org/

Actually, Stephane setup distcc here.  Unfortunately it doesn't help
me all that much, because linking is what takes a large part of my
time (because I'm making incremental changes and because I insist on
compiling with -g).

I have to say though I was very impressed with how easy to use distcc
is.  Nice job!

(BTW: still waiting for someone to tell me I need a 64-way SuperDome
to get my kernel compiles done... ;-)

	--david

