From: Robert Love <rml@tech9.net>
Date: Fri, 07 Dec 2001 23:42:10 +0000
Subject: [Linux-ia64] Re: Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805657@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2001-12-07 at 18:32, Keith Owens wrote:
> On 07 Dec 2001 18:27:11 -0500, Robert Love <rml@tech9.net> wrote:

> >For 2.5, there probably is no intention of keeping that around.  But can
> >we honestly ditch it in the middle of a stable kernel?  Personally I
> >don't use it, but its not polite ...

> Linus ditched drm 4.0 months ago.  It only survives in arch add on
> patches like ia64 and in -ac trees.

I know.  I meant we should continue to support the drm-4.0 package. 
It's the usual song ... we shouldn't change interfaces or required tools
in a stable series, and the least we can do is make 4.0 available
somehow, because someone may rely on it.

On the flip side, I don't care, and I suspect the people who actually
are using DRM are on 4.1 now.  Further, if _you_ are maintaining the
cruft and it bothers _you_, then stop :)

	Robert Love


