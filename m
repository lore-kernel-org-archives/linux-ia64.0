From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 19 Sep 2001 21:43:26 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Sep 2001 02:02:35 -0400, Jakub Jelinek <jakub@redhat.com> said:

  Jakub> On Tue, Sep 18, 2001 at 01:47:12PM -0700, David Mosberger
  Jakub> wrote:
  >> That would be good.  It might also be good to explicitly state
  >> that these trees are expected to follow the filesystem layout
  >> conventions of the emulated environment (to the degree that this
  >> makes sense).  For example, you could assume that there would be:
  >> 
  >> /emul/ia32-linux/etc/ld.so.conf

  Jakub> Why ld.so.conf? /etc/ld.so.conf should be enough when
  Jakub> ldconfig handles multiple ABI libraries.

I think there is a choice.  You could do it either way (theoretically
at least).  From a user perspective, it's probably better to have just
/etc/ld.so.conf.

	--david

