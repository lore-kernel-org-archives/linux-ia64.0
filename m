From: Randolph Chung <randolph@tausq.org>
Date: Sun, 23 Jun 2002 06:28:36 +0000
Subject: Re: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905714@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Even if it's statically linked?  Dynamically linked binaries do not
> work with gprof.  I wasn't aware of any pthread-specific issues.

yup, static works. dynamic binaries not linked against pthread seems to
work too...

randolph
--  
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

