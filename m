From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Mar 2003 22:19:51 +0000
Subject: Re: [Linux-ia64] [PATCH] settimeofday() not synchronised with
Message-Id: <marc-linux-ia64-105590723705331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806076@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Mar 2003 13:39:25 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  >> I don't understand what does the line in settimeofday(): nsec -  >> (jiffies - wall_jiffies ) * (1000000000 / HZ);

  Eric> Finally I read the code to do the same thing for i386 (get and
  Eric> settimeofday()). This explains the meaning of this line, in
  Eric> the i386 it's associated with the equivalent line in
  Eric> do_gettimeofday()! On ia64 everything is done inside of
  Eric> gettimeoffset(). Therefore I'm now confident that suppressing
  Eric> this line is a Good Thing ;-) The patch doing it wrt the bk
  Eric> tree is attached.

Good catch.  I applied this patch.

Thanks,

	--david

