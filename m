From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 08 Oct 2001 23:54:29 +0000
Subject: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Oct 2001 16:46:41 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> The rate limiting stuff really limits the usefulness of the
  Jesse> code I think.  If you want to get notified of faults, you
  Jesse> probably want all of them, and you want to know the ip for
  Jesse> each occurence.  If you just get some, it doesn't help you
  Jesse> debug your code.  Maybe there could be a NOTIFY option or
  Jesse> something that would get printed only once if the app
  Jesse> generated a fault?

I feel pretty strongly that we should handle fpswa faults the same way
as unaligned faults.  Given that we rate limit the unaligned faults,
I'd prefer to rate limit fpswa as well.  Of course, if you think you'd
want to debug more than 5 faults at a time, you could change the
tuning parameters (allowing for longer bursts, while keeping the
logging rate the same).

	--david

