From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Mar 2003 20:03:02 +0000
Subject: [Linux-ia64] Re: [PATCH] settimeofday() not synchronised with gettimeofday()
Message-Id: <marc-linux-ia64-105590709806082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Mar 2003 17:53:43 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> gettimeofday() gave a time BEFORE the time we set!  First,
  Eric> I've corrected an obvious problem due to the change of the
  Eric> returned value of gettimeoffset() from usec to nsec in
  Eric> settimeofday().

Ah, yes, thanks for catching that.

  Eric> David, I think you can apply it, at least :-)

The patch looks mostly OK, but it compares an "unsigned long" for < 0,
which can't be right.  I can fix that, though (I'll also fix the
comment for gettimeoffset()).

  Eric> However, now, it still gives negative difference: # ./a.out
  Eric> requested: 1047572128s 2564ns new: 1047572128s 1588ns diff is
  Eric> -0.000976000sec

  Eric> That's better but there is still something...  Can anyone
  Eric> reproduce this bug? Any idea about what may cause this shifted
  Eric> results?

Are you running ntp?

On a related topic: there is another strange 2.5 time related bug.  On
2.4:

	$ time sleep 16.02
	real    0m16.027s
	user    0m0.002s
	sys     0m0.001s

On 2.5:

	$ time sleep 16
	real    0m16.002s
	user    0m0.001s
	sys     0m0.002s


	$ time sleep 16.02
	real    0m25.189s
	user    0m0.000s
	sys     0m0.001s

So clearly something very strange is going on.  My suspicion is that
the bug was introduced back when x86 switched from 100Hz to 1000Hz
ticks, but that's just a guess.  Eric, would you be
able/willing/interested to look into this?

	--david

