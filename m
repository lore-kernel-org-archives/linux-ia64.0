From: Branden Robinson <branden@progeny.com>
Date: Fri, 27 Jul 2001 00:06:44 +0000
Subject: [Linux-ia64] Re: XFree86 4.1.0, Linux/ia64, and various video cards
Message-Id: <marc-linux-ia64-105590693005939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005936@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005936@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 26, 2001 at 05:13:37PM -0400, Bill Nottingham wrote:
> Branden Robinson (branden@progeny.com) said: 
> > The tests were conducted using a patched version of 4.1.0 for Debian and
> > Progeny that works around a problem with PIC symbols being absent in static
> > libraries, which powerpc, ia64, and hppa (among possible others) do not
> > tolerate.  At the same time, PIC symbols in X server modules cause the X
> > server to segfault.  I'll be submitting this patch to XFree86 shortly.
> 
> That's easily fixed with config hackery. I'm surprised this hasn't
> been added yet.

The fix you posted has been tested, but doesn't catch all the cases.  I'll
be posting my patch in a few minutes.

-- 
Branden Robinson          | GPG signed/encrypted mail welcome
branden@progeny.com       | 1024D/9C0BCBFB
Consultant                | D5F6 D4C9 E25B 3D37 068C
Progeny Linux Systems     | 72E8 0F42 191A 9C0B CBFB

