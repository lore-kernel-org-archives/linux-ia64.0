From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 06:31:55 +0000
Subject: Re: [Linux-ia64] gprof for IA-64
Message-Id: <marc-linux-ia64-105590693005310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005305@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005305@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 19 Mar 2001 19:53:57 -0800, "Ahna, Christopher J" <christopher.j.ahna@intel.com> said:

  Ahna> Does anybody have gprof working on their IA-64 box?  I saw
  Ahna> some 'gprof for IA-64' patches go into binutils recently, but
  Ahna> I can't get things to work right on my BigSur.  Are any steps
  Ahna> other than downloading and building the latest binutils
  Ahna> necessary?  Thanks,

IIRC, the libc that ships with "Fisher" supports profiling.  So if you
applied the gprof patch and have a recent enough version of libc, you
should be all set.

What exactly do you mean by "can't get things to work right"?  What's
failing?  How did you compile/link the program?  I normally use:

	gcc -profile -pg files...

  --david

