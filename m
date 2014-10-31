From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 31 Oct 2014 20:33:44 +0000
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound violation information
Message-Id: <alpine.DEB.2.11.1410312133120.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241408360.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1410272135420.5308@nanos> <5453EE0E.8060200@intel.com>
In-Reply-To: <5453EE0E.8060200@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On Fri, 31 Oct 2014, Dave Hansen wrote:

> On 10/27/2014 01:36 PM, Thomas Gleixner wrote:
> > You're repeating yourself. Care to read the discussion about this from
> > the last round of review again?
> 
> OK, so here's a rewritten decoder.  I think it's a lot more robust and
> probably fixes a bug or two.  This ends up saving ~70 lines of code out
> of ~300 or so for the old patch.
> 
> I'll include this in the next series, but I'm posting it early and often
> to make sure I'm on the right track.

Had a short glance. This looks really very well done!

Thanks,

	tglx
