From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 09 Oct 2004 04:24:10 +0000
Subject: RE: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0226744F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'd really like this issue to be resolved one way or the 
>other. I'm not sure I've heard a convincing argument on why my 
>original patch(which adds a new exec domain unconditionally) 
>should not be applied.
>
>I'm fine with the attached patch to set the altroot via a 
>system call as well.

I think there is a memory leak. It needs a "putname()" call
somewhere to match the

+		emul = getname(altroot);

If we are going this route, the discussion needs to happen on
LKML as this is not an ia64 only kind of patch.  But I'm still
not sure that I understand what's wrong with the existing
method of calling sys_personality() that we've been using for
the past few years.  Christoph ... can you expand a little on
"we said no for qemu, so it's no to you too".

-Tony
