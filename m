From: "Martin K. Petersen" <mkp@mkp.net>
Date: Sat, 01 Feb 2003 23:57:00 +0000
Subject: Re: [Linux-ia64] clock goes out of sync on itanium
Message-Id: <marc-linux-ia64-105590709805794@msgid-missing>
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

tausq> Have anyone else seen this problem?

Yes.  My i2000s were notoriously bad at keeping time.  I ran xntpd on
all of them for that reason.

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/


