From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 20 May 2003 22:58:25 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'd like to make some sort of forward progress on this issue
before releasing a 2.4.21 ia64 patch.  By default this will
be to apply the original patch I posted on May 7.

I'm not trying to railroad anything here, but 2.4.21 is
getting close, and I'd rather not wait until 2.4.22.  So
if there are any major issues with the proposal, please
raise them!  The only real issue so far has been when
the error records should cleared from the firmware log,
and I'm certainly open to more discussion on that.

As for 2.5, I'm willing to turn it into a filesystem if
that's the Right Thing (though it feels like all the
existing /proc/pal, /proc/sal, and /proc/efi stuff should
be converted at the same time, which is more than I really
had in mind).  In any case, it will take me some time to
learn about how that infrastructure works.

Bjorn


