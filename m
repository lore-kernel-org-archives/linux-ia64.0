From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 29 Oct 2001 15:57:27 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for the X->text->X console crash
Message-Id: <marc-linux-ia64-105590698805405@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805401@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805401@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Oct 2001 10:17:15 -0700, Chris Ahna <christopher.j.ahna@intel.com> said:

  Chris> A patch which should fix the famous X->text->X console switch
  Chris> crashes is appended.

This is excellent news.  Great job!

  Chris> It seems that the kernel was sending a 'console reacquired'
  Chris> signal to X _before_ doing a screen blank operation.  This
  Chris> allowed X to be configuring the video card from one processor
  Chris> while the kernel cleared parts of the VGA range from another.
  Chris> Interleaving these types of accesses apparently caused the
  Chris> system crashes (at least that's what the hardware guys with
  Chris> PCI bus analyzers saw and the problem goes away when running
  Chris> UP :-)

Argh, a generic kernel race condition.  Who would have thought of that.

Any idea why this is crashing on ia64 but not on MP x86s?

In any case, it sounds like we can finally take this bug off the list.
I'm sure lots of people will appreciate this.

Thanks,

	--david

