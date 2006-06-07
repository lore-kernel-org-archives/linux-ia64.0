From: Jes Sorensen <jes@sgi.com>
Date: Wed, 07 Jun 2006 09:22:21 +0000
Subject: Re: Montecito processor family
Message-Id: <yq0irnds4ky.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Ken" = Chen, Kenneth W <kenneth.w.chen@intel.com> writes:

Ken> I thought the x86 acronym was taken straight out of SDM, refer to
Ken> CPUID instruction detail there. We should do the same on ia64.

Ken> Section 3.1.11 out of SDM volume 1:

Ken> field bit description lb 0 long branch (brl) instructions.  sd 1
Ken> spontaneous deferral ao 2 16-byte atomic operations rv 63:3
Ken> Reserved.

Ken> It's only my wishful thinking. The acronym should be improved a
Ken> bit to be more creative and meaningful in its current form.  Oh
Ken> well.

IMHO single words are much nicer to read than strange letter
combos. If we take this path, could we at least make sure it gets
documented in Documentation/ somewhere?

Thanks,
Jes
