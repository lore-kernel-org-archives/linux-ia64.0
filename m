From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Dec 2002 23:42:52 +0000
Subject: Re: [Linux-ia64] fpswa logging redux
Message-Id: <marc-linux-ia64-105590709805550@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805545@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805545@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 11 Dec 2002 14:25:14 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> I'd like to fully decode the information in the isr about
  Jesse> what type of fault occured (whether it be a software assist
  Jesse> fault, some sort of IEEE filter fault, etc.) and print it
  Jesse> along with the ip when faults occur.  While I'm at it, I may
  Jesse> as well the proper SIGFPE subcode into si_info in case of
  Jesse> signal delivery is selected.

Like Keith, I'd like to keep the amount of decoding in the kernel as
minimal as possible.  We already have si_isr in the siginfo structure,
so apps/libraries can decode things themselves.  Having said that, we
ought to decode things sufficiently so that si_code can be set to the
correct value (where this makes sense).  Hopefully, that won't add
tons of code and it would help application portability.

	--david

