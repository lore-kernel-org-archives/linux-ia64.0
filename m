From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Feb 2003 16:17:34 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805903@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Feb 2003 08:10:25 -0800, Randolph Chung <randolph@tausq.org> said:

  >> Did you verify that you have write access on /var/ski-disks/sda?

  Randolph> yes, but i didn't read the instructions carefully enough
  Randolph> so i thought if i had simscsi=/var/ski-disks/sd my disk
  Randolph> file is also called /var/ski-disks/sd (instead of .../sda)

  Randolph> it's booting now with 1.30 bogomips :-)

Great!  1.30 bogomips is the right number (it's deterministic and not
dependent on the simulation speed).

	--david

