From: dann frazier <dannf@hp.com>
Date: Fri, 27 Feb 2004 22:38:15 +0000
Subject: Re: Important NaT-bit bug fix
Message-Id: <20040227223815.GL23315@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16445.8557.274484.443935@napali.hpl.hp.com>
In-Reply-To: <16445.8557.274484.443935@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 26, 2004 at 01:29:48PM -0800, David Mosberger wrote:
> Yes, that's exactly what I meant.  Of course, I'd still advise to
> double-check by running the test program.

I was talking to David privately, and he pointed out that either
2.4 patch (the one willy posted, or the one david posted) applied
to a kernel w/o the streamlined syscall path patch will allow his
test to succeed.

From David:
  "Actually, now that I think about it, the test is fine.  Using the
   patch that works with a stream-lined syscall-path patch also will work
   with an unpatched kernel (just a bit slower than strictly necessary).
   It's the reverse that wouldn't work, but that's not a case that you
   tested."

At what point did the streamlined syscall path go into a 2.4-ia64 release?

-- 
---------------------------
dann frazier
Hewlett-Packard
Linux and Open Source Lab
dannf@hp.com
(970) 898-0800
