From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sun, 02 Feb 2003 20:04:03 +0000
Subject: Re: [Linux-ia64] clock goes out of sync on itanium
Message-Id: <marc-linux-ia64-105590709805796@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805793@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805793@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "tausq" = Randolph Chung <randolph@tausq.org> writes:
tausq> Hi, I've noticed that my i2000 running 2.4.1[89] kernels is
tausq> pretty poor at keeping time. It seems to drift backwards in
tausq> time ~5-10 minutes a week.

I had that problem --- even ntp couldn't keep the clock in time.
Turns out that there's a bug in early firmware revisions that
misreports the hardware clock time, leading to bad real-time tracking.
After updating the firmware, the problem went away.

I suggest you check to see if your firmware is at the current
revision.

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

